Import-Module dbatools
Import-Module Mailozaurr

## Define the tests to run
[System.Collections.Generic.List[PSObject]] $TestsToRun = @()
$TestsToRun.Add([ordered]@{
        Test     = 'Database files or logs on C drive'
        Query    = 'Database Filenames and Paths'
        property = 'physical_name' 
        operator = '-match' 
        value    = 'C:'
    })
$TestsToRun.Add([ordered]@{
        Test     = 'Database is online'
        Query    = 'Database Properties'
        property = 'state_desc' 
        operator = '-ne' 
        value    = 'ONLINE'
    })
$TestsToRun.Add([ordered]@{
        Test     = 'Recovery Model not set to simple'
        Query    = 'Database Properties'
        property = 'Recovery Model' 
        operator = '-ne' 
        value    = 'SIMPLE'
    })

## Get the unique queries
$QueryName = $TestsToRun | Foreach-Object { $_['Query'] } | Select-Object -Unique
## Run the health check queries
$HealthChecks = Invoke-DbaDiagnosticQuery -SqlInstance $SQLServer -SqlCredential $creds -QueryName $QueryName



Function Get-ResultFilter {
    <#
.SYNOPSIS
Use to create dyanmic filters at run time

.PARAMETER property
The name of the property to filter on

.PARAMETER operator
The operator to filter on
    -eq
    -neq
    -gt
    -ge   
    -lt
    -le
    -Like
    -NotLike
    -Match
    -NotMatch
    -Contains
    -NotContains
    -In
    -NotIn

.PARAMETER value
The vaule to check for
#>
    param (
        [Parameter(Mandatory = $true)]    
        [string]$property,
        [Parameter(Mandatory = $true)]
        [ValidateSet('-eq', '-neq', '-gt', '-ge', '-lt', '-le', '-Like', '-NotLike', '-Match', '-NotMatch', '-Contains', '-NotContains', '-In', '-NotIn')]
        [string]$operator,
        [Parameter(Mandatory = $true)]
        [string]$value
    )
    $sb = [scriptblock]::Create("`$_.'$($property)' $operator '$value'")
    return $sb
}

Function Test-HealthCheckResult {
    <#
    .SYNOPSIS
    Checks the results from a query ran by the Invoke-DbaDiagnosticQuery for a specific condition
    
    .PARAMETER HealthChecks
    The results from the Invoke-DbaDiagnosticQuery cmdlet
    
    .PARAMETER Test
    The name of the test. Used for reporting purposes only
    
    .PARAMETER Query
    The name of the query from the Invoke-DbaDiagnosticQuery cmdlet that contains the results to check
    
    .PARAMETER property
    The name of the result property to filter on

    .PARAMETER operator
    The operator to filter on
        -eq
        -neq
        -gt
        -ge   
        -lt
        -le
        -Like
        -NotLike
        -Match
        -NotMatch
        -Contains
        -NotContains
        -In
        -NotIn

    .PARAMETER value
    The vaule to check for
    #>
    param (
        [object]$HealthChecks,  
        [string]$Test,
        [string]$Query,   
        [string]$property,
        [string]$operator,
        [string]$value
    )

    $testResults = $HealthChecks | Where-Object { $_.Name -eq $Query }
    foreach ($hc in $testResults) {
        $failed = @($hc.Result | Where-Object (Get-ResultFilter $property $operator $value ))
        if ($failed.Count -gt 0) {
            $status = 'Failed'
        }
        else {
            $status = 'Passed'
        }
        $hc | Select-Object -Property SqlInstance, @{l = 'Test'; e = { $Test } }, @{l = 'Query'; e = { $_.Name } }, Description, DatabaseSpecific,
        @{l = 'Status'; e = { $Status } }, @{l = 'Failed'; e = { $failed } }, Result
    }
    
}

[System.Collections.Generic.List[PSObject]] $TestResults = @()
foreach ($test in $TestsToRun) {
    Test-HealthCheckResult -HealthChecks $HealthChecks @test | ForEach-Object { $TestResults.Add($_) }
}

[System.Collections.Generic.List[PSObject]] $EmailTables = @()
foreach ($failure in $TestResults | Where-Object { $_.Status -ne 'Passed' }) {
    $failure | Select-Object -Property SqlInstance, Test, Query, Description, DatabaseSpecific | ConvertTo-Html -Fragment | 
    ForEach-Object { $EmailTables.Add($_) }
    $failure.Failed | ConvertTo-Html -Fragment | ForEach-Object { $EmailTables.Add($_) }
} 

$EmailMessage = @{
    From       = $SmtpFrom
    To         = $SendTo
    Credential = $Credential
    Body       = $EmailTables -join ("`n")
    Priority   = 'High'
    Subject    = "SQL Health Check Failed for $($SQLServer)"
    SendGrid   = $true
}
Send-EmailMessage @EmailMessage
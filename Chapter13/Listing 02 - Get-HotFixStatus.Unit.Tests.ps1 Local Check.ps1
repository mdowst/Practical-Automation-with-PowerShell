# Listing 2 - Get-HotFixStatus.Unit.Tests.ps1 Local Check
BeforeAll {
    # Import your function
    Set-Location -Path $PSScriptRoot
    . .\Get-HotFixStatus.ps1
}

# Pester tests
Describe 'Get-HotFixStatus' {
    It "Hotfix is found on the computer" {
        $KBFound = Get-HotFixStatus -Id 'KB5011493' -Computer 'localhost'
        $KBFound | Should -Be $true
    }

    It "Hotfix is not found on the computer" {
        $KBFound = Get-HotFixStatus -Id 'KB1234567' -Computer 'localhost'
        $KBFound | Should -Be $false
    }

    It "Unable to connect" {
        { Get-HotFixStatus -Id 'KB5011493' -Computer 'Bad' } | Should -Throw
    }
}
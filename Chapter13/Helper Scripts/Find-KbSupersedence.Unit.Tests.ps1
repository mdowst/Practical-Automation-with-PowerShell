# Listing 8 - Find-KbSupersedence.Unit.Tests.ps1 in-depth with Mocks
BeforeAll {
    Set-Location -Path $PSScriptRoot
    . ".\Find-KbSupersedence.ps1"
}

Describe 'Find-KbSupersedence' {
    BeforeAll {
        # Build the Mock for ConvertFrom-Html
        Mock ConvertFrom-Html -ParameterFilter{ 
            $URI } -MockWith {
            $File = "$($URI.AbsoluteUri.Split('=')[-1]).html"
            $Path = Join-Path $PSScriptRoot $File
            ConvertFrom-Html -Path $Path
        }

        Mock Invoke-WebRequest -MockWith {
            $File = "$($URI.AbsoluteUri.Split('=')[-1]).html"
            $Path = Join-Path $PSScriptRoot $File
            $Content = Get-Content -Path $Path -Raw
            [pscustomobject]@{
                Content = $Content
            }
        }
    }

    # Find-KbSupersedence should use the Mock
    It "KB Article is found" {
        $KBSearch = Find-KbSupersedence -KbArticle 'KB4521858'
        $KBSearch | Should -Not -Be $null
        $KBSearch | Should -HaveCount 3

        # Confirm the Mocks were called the expected number of time
        $cmd = 'ConvertFrom-Html'
        Should -Invoke -CommandName $cmd -Times 1
        $cmd = 'Invoke-WebRequest'
        Should -Invoke -CommandName $cmd -Times 3
    }

    It "In Depth Search results" {
        $KBSearch = Find-KbSupersedence -KbArticle 'KB4521858'
        $KBSearch.Id | 
            Should -Contain '250bfd45-b92c-49af-b604-dbdfd15061e6'
        $KBSearch | 
            Where-Object{ $_.Products -contains 'Windows 10' } | 
            Should -HaveCount 2
        $KBSearch | 
            Where-Object{ $_.Architecture -eq 'AMD64' }  | 
            Should -HaveCount 2
        $KB = $KBSearch | 
            Where-Object{ $_.Id -eq '83d7bc64-ff39-4073-9d77-02102226aff6' }
        $KB.Products  | Should -Be 'Windows Server 2016'
        ($KB.SupersededBy | Measure-Object).Count | Should -Be 9
    }

    # Run the Find-KbSupersedence for the not superseded update
    It "SupersededBy results" {
        $KBMock = Find-KbSupersedence -KbArticle 'KB5008295'
        
        # Confirm there are no superseding updates for both updates returned
        $KBMock.SupersededBy | 
            Should -Be @($null, $null)

        # Confirm the Mocks were called the expected number of time
        $cmd = 'ConvertFrom-Html'
        Should -Invoke -CommandName $cmd -Times 1
        $cmd = 'Invoke-WebRequest'
        Should -Invoke -CommandName $cmd -Times 2
    }
}
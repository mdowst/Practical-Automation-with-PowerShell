# Listing 7 - Find-KbSupersedence.Unit.Tests.ps1 with Mock test files
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

        # Build the Mock for Invoke-WebRequest
        Mock Invoke-WebRequest -MockWith {
            $File = "$($URI.AbsoluteUri.Split('=')[-1]).html"
            $Path = Join-Path $PSScriptRoot $File
            $Content = Get-Content -Path $Path -Raw
            # Build a custom PowerShell Object to mock what the cmdlet would return
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

        # Confirm the Mocks were called the expected number of times
        $cmd = 'ConvertFrom-Html'
        Should -Invoke -CommandName $cmd -Times 1
        $cmd = 'Invoke-WebRequest'
        Should -Invoke -CommandName $cmd -Times 3
    }
}
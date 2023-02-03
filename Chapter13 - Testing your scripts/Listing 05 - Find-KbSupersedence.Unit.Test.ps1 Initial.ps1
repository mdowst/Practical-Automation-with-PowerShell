# Listing 5 - Find-KbSupersedence.Unit.Test.ps1 Initial
BeforeAll {
    Set-Location -Path $PSScriptRoot
    . ".\Listing 04 - Find-KbSupersedence.ps1"
}

Describe 'Find-KbSupersedence' {
    It "KB Article is found" {
        $KBSearch = Find-KbSupersedence -KbArticle 'KB4521858'
        $KBSearch | Should -Not -Be $null
        $KBSearch | Should -HaveCount 3
    }
}
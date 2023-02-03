# Listing 11 - Find-KbSupersedence.Integration.Tests.ps1 integration tests
BeforeAll {
    Set-Location -Path $PSScriptRoot
    . ".\Find-KbSupersedence.ps1"
}

Describe 'Find-KbSupersedence' {
    It "KB Article is found" {
        # Find-KbSupersedence without a Mock
        $KBSearch = 
            Find-KbSupersedence -KbArticle 'KB4521858'
        $KBSearch | Should -Not -Be $null
        $KBSearch | Should -HaveCount 3
        # Confirm the ID is a GUID
        $GuidRegEx = '(\{){0,1}[0-9a-fA-F]{8}\-' +
            '[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\' +
            '-[0-9a-fA-F]{12}(\}){0,1}'
        $KBSearch.Id | Should -Match $GuidRegEx
        # Confirm products are populating
        $KBSearch.Products | Should -Not -Be $null
        # Confirm the number of results that have the expected architecture matches the number of results.
        $KBSearch | 
            Where-Object{ $_.Architecture -in 'x86','AMD64','ARM' } | 
            Should -HaveCount $KBSearch.Count
        # Confirm there are at least nine SupersededBy KB articles
        $KB = $KBSearch | Select-Object -First 1
        ($KB.SupersededBy | Measure-Object).Count | 
            Should -BeGreaterOrEqual 9
    }
}
# Listing 1 - Get-SystemInfo Test before updating
# Import the module
$ModulePath = Split-Path $PSScriptRoot
Import-Module (Join-Path $ModulePath 'PoshAutomator.psd1') -Force

# Set the module scope to the module you are testing
InModuleScope -ModuleName PoshAutomator {
  Describe 'Get-SystemInfo' {
    # Test Get-SystemInfo generic results to ensure data is returned
    Context "Get-SystemInfo works" {
      It "Get-SystemInfo returns data" {
        $Info = Get-SystemInfo
        $Info.Caption | Should -Not -BeNullOrEmpty
        $Info.InstallDate | Should -Not -BeNullOrEmpty
        $Info.ServicePackMajorVersion | Should -Not -BeNullOrEmpty
        $Info.OSArchitecture | Should -Not -BeNullOrEmpty
        $Info.BootDevice | Should -Not -BeNullOrEmpty
        $Info.BuildNumber | Should -Not -BeNullOrEmpty
        $Info.CSName | Should -Not -BeNullOrEmpty
        $Info.Total_Memory | Should -Not -BeNullOrEmpty
      }
    }

    # Test Get-SystemInfo results with mocking to ensure data that is returned matches the expected values
    Context "Get-SystemInfo returns data" {
      BeforeAll {
        Mock Get-CimInstance {
          Import-Clixml -Path ".\Get-CimInstance.Windows.xml"
        }
      }
      It "Get-SystemInfo Windows 11" {
        $Info = Get-SystemInfo
        $Info.Caption | Should -Be 'Microsoft Windows 11 Enterprise'
        $Date = Get-Date '10/21/2021 5:09:00 PM'
        $Info.InstallDate | Should -Be $Date
        $Info.ServicePackMajorVersion | Should -Be 0
        $Info.OSArchitecture | Should -Be '64-bit'
        $Info.BootDevice | Should -Be '\Device\HarddiskVolume3'
        $Info.BuildNumber | Should -Be 22000
        $Info.CSName | Should -Be 'MyPC'
        $Info.Total_Memory | Should -Be 32
      }
    }
  }
}
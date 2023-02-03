# Listing 3 - Get-SystemInfo Test after the updates
# Import the module
$ModulePath = Split-Path $PSScriptRoot
Import-Module (Join-Path $ModulePath 'PoshAutomator.psd1') -Force

# Set the module scope to the module you are testing
InModuleScope -ModuleName PoshAutomator {
  # The tests from before you made any changes
  Describe 'Get-SystemInfo v1' {
    <#
      Copy Tests from Listing 1 here to ensure they all still pass
    #>
  }

  # New Tests for the Linux distros
  Describe 'Get-SystemInfo v2' {
    Context "Get-SystemInfo for Linux" {
      BeforeAll {
        # Mock the Get-Variable command to return true if IsLinux variable
        Mock Get-Variable -MockWith { $true }

        # Mock each on the Linux system commands to control the data that is returned
        Mock Select-String -ParameterFilter { 
          $Path -eq '/proc/meminfo' } -MockWith {
          [pscustomobject]@{line = 'MemTotal:    8140600 kB' }
        }
        Mock Invoke-Expression -ParameterFilter { 
            $Command -eq 'df /boot' } -MockWith { 
          Get-Content -Path (Join-Path $PSScriptRoot 'test.df.txt')
        }
        Mock Invoke-Expression -ParameterFilter { 
            $Command -eq 'stat /' } -MockWith { 
          Get-Content -Path (Join-Path $PSScriptRoot 'test.stat.txt')
        }
        Mock Invoke-Expression -ParameterFilter { 
            $Command -eq 'uname -m' } -MockWith { 
          'x86_64'
        }
        Mock Invoke-Expression -ParameterFilter { 
            $Command -eq 'uname -n' } -MockWith { 
          'localhost.localdomain'
        }
      }

      # Test the different Linux distros using a foreach so you do not need to recreate the It block for each distro
      It "Get-SystemInfo Linux (<Caption>)" -ForEach @(
        # Build hashtables with the values needed to test each distro
        @{ File = 'test.rhel.txt'; 
           Caption = "Red Hat Enterprise Linux 8.2 (Ootpa)";
           ServicePackMajorVersion = '8.2 (Ootpa)'; 
           BuildNumber = '8.2' 
        }
        @{ File = 'test.Ubuntu.txt'; 
           Caption = "Ubuntu 20.04.4 LTS";
           ServicePackMajorVersion = '20.04.4 LTS (Focal Fossa)'; 
           BuildNumber = '20.04' 
        }
        @{ File = 'test.SUSE.txt'; 
           Caption = "SUSE Linux Enterprise Server 15 SP3";
           ServicePackMajorVersion = '15-SP3'; 
           BuildNumber = '15.3' 
        }
      ) {
        Mock Get-Content -ParameterFilter { 
            $Path -eq '/etc/os-release' } -MockWith {
          Get-Content -Path (Join-Path $PSScriptRoot $File)
        }
        
        # Run the Get-SystemInfo while mocking the Linux results
        $Info = Get-SystemInfo
        
        # Confirm the expected mocks are being called
        $cmd = 'Get-Content'
        Should -Invoke -CommandName $cmd -ParameterFilter { 
            $Path -eq '/etc/os-release' } -Times 1
        Should -Invoke -CommandName 'Get-Variable' -ParameterFilter { 
            $Name -eq 'IsLinux' -and $ValueOnly } -Times 1
        Should -Invoke -CommandName 'Select-String' -ParameterFilter { 
            $Path -eq '/proc/meminfo' } -Times 1
        Should -Invoke -CommandName 'Invoke-Expression' -ParameterFilter { 
            $Command -eq 'df /boot' } -Times 1
        Should -Invoke -CommandName 'Invoke-Expression' -ParameterFilter { 
            $Command -eq 'stat /' } -Times 1
        Should -Invoke -CommandName 'Invoke-Expression' -ParameterFilter { 
            $Command -eq 'uname -m' } -Times 1
        Should -Invoke -CommandName 'Invoke-Expression' -ParameterFilter { 
            $Command -eq 'uname -n' } -Times 1

        # Confirm the results match the expected values
        $Info.Caption | Should -Be $Caption
        $Date = Get-Date '2021-10-01 13:57:20.213260279 -0500'
        $Info.InstallDate | Should -Be $Date
        $Info.ServicePackMajorVersion | Should -Be $ServicePackMajorVersion
        $Info.OSArchitecture | Should -Be 'x86_64'
        $Info.BootDevice | Should -Be '/dev/sda2'
        $Info.BuildNumber | Should -Be $BuildNumber
        $Info.CSName | Should -Be 'localhost.localdomain'
        $Info.Total_Memory | Should -Be 8
      }
    }

  }
}
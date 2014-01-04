$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "PsGitHubNuspecTools" {

    Context "New-Icon" {
    
        It "should create a png in current path given no path argument" {
            $cd= Get-Location
            cd $TestDrive
            new-icon "txt"
            (test-path "$TestDrive/icon.png").should.be.$True
            
            cd  $cd;    
        }

        It "should create a png in specified path"{

            new-icon "txt" "$TestDrive/dir/lol.png"
            (test-path "$TestDrive/dir/lol.png").should.be.$True
        }
    }

    Context "Scaffold-Nuspec-Package"{

        It "should create default files"{
            mkdir "$TestDrive/pack"
            scaffold-nuspec-package "$TestDrive/pack"


            (test-path "$TestDrive/pack/pack.nuspec").should.be.$False
            (test-path "$TestDrive/pack/readme.md").should.be.$True
            (test-path "$TestDrive/pack/tools").should.be.$True

        }
    }

}
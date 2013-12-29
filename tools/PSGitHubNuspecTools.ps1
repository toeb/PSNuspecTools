function New-NuspecRepository{
  param(
  [Parameter( Mandatory = $true, Position=0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
  [Alias("name")]
  [String]
  $repoName
  )


  write-host -NoNewline "creating project "
  write-host -ForegroundColor "yellow" "$repoName"

  New-GitHubRepository $repoName
  
  
  

  git status
  if($LASTEXITCODE -eq 0){
    echo "current directory is not a repository"
  }else{
    echo "current directory is a repository"
  }

}
function new-nuspec($filename, $projectName, $version, $owner, $author, $description,$summary){
 $templatePath =  join-path $PSScriptRoot "../templates"
 $nuspecTemplate = join-path $templatePath template.nuspec
 [xml]$templateXml = Get-Content $nuspecTemplate


 $templateXml.package.metadata.id= "$projectName";
 $templateXml.package.metadata.title = "$projectName";
 $templateXml.package.metadata.version  = "$version";
 $templateXml.package.metadata.description = "$description";
 $templateXml.package.metadata.tags ="$tags";
 $templateXml.package.metadata.projectUrl ="$projectUrl";
 $templateXml.package.metadata.iconUrl = "$iconUrl"; 
 $templateXml.package.metadata.summary = "$summary";
 
 
 $currentPath = Get-Location;
 $targetPath = join-path $currentPath "$filename.nuspec"
 $templateXml.Save($targetPath);
}

function new-empty-nuspec($targetpath){
if($targetpath -eq $Null -or $targetpath -eq ""){
    $targetpath = Get-Location;
}
 $templatePath =  join-path $PSScriptRoot "../templates";
 $nuspecTemplate = join-path $templatePath "template.nuspec";
 cp $nuspecTemplate $targetpath
}



function update-nuspec($path, $id, $title, $version, $owners, $authors, $description,$summary){
    if(test-path $path){
       
    }else{
      new-empty-nuspec $path
    }
    [xml]$templateXml = Get-Content $path

    if($id -ne $Null){
     $templateXml.package.metadata.id= "$id";
     if($title -eq $Null){
      $title = $id;
     }
    }
    
    if($title -ne $Null){
     $templateXml.package.metadata.title = "$title";
    }
    if($version -ne $Null){
     $templateXml.package.metadata.version  = "$version";
    }
 
    if($description -ne $Null){
     $templateXml.package.metadata.description = "$description";
    }
 
    if($authors -ne $Null){
     $templateXml.package.metadata.authors = "$authors";
    }
 
    if($tags -ne $Null){
     $templateXml.package.metadata.tags ="$tags";
    }
 
    if($projectUrl -ne $Null){
     $templateXml.package.metadata.projectUrl ="$projectUrl";
    }
 
    if($iconUrl -ne $Null){
     $templateXml.package.metadata.iconUrl = "$iconUrl"; 
    }
    if($owners -ne $Null){
     $templateXml.package.metadata.owners = "$owners"; 
    }

 
    if($summary -ne $Null){
     $templateXml.package.metadata.summary = "$summary";
    }
    $path = get-item($path)
    $templateXml.Save($path.FullName);
    less $path 
}
function new-githubnuget($projectname){
 New-GitHubRepository $projectname;
}

function update-git-nuspec($path){
    git status

    if($LASTEXITCODE -ne 0){
        throw  "current directory is not a repository"
    }



    if($path -eq $Null){
        $path = Get-Item *.nuspec 
        if($path -is [System.Array] -and $files.Length -ne 1){
            throw "need a single nuspec file in directory"
        }
    }


    $version = Get-CurrentVersion


    update-nuspec -path $path -version "$version"
}



function testtest(){
 write hello
 write $PSScriptRoot 
 $templatePath =  join-path $PSScriptRoot "../templates"
 $nuspecTemplate = join-path $templatePath template.nuspec
 [xml]$templateXml = Get-Content $nuspecTemplate
 write $templateXml
 $currentPath = Get-Location;
 $targetPath = join-path $currentPath "test.nuspec"
 write $targetPath
 $templateXml.Save($targetPath)
 return $templateXml;
}
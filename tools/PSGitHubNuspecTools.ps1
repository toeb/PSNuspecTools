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

function new-chocoinstallscript($targetPath){
$templatePath =  join-path $PSScriptRoot "../templates";
 $installScriptPath = join-path $templatePath "chocolateyInstall.ps1";
 cp $installScriptPath $targetpath
 
}
function get-parentdirname($path){
if($path -eq $Null){
 $path = Get-Location
}
 $result = Split-Path $path -Leaf
 return $result;
}
function get-userfullname(){
$Computername = $env:COMPUTERNAME
$username = (Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Computername).UserName 
$fullname = (get-WmiObject -Class Win32_UserAccount | Where-Object -FilterScript {$_.Caption -eq "$username"}).FullName 
$vorname = $fullname.Split(" ")[0] 
$nachname = $fullname.Split(" ")[1]
return $fullname;
}
function get-userfirstname(){

$Computername = $env:COMPUTERNAME
$username = (Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Computername).UserName 
$fullname = (get-WmiObject -Class Win32_UserAccount | Where-Object -FilterScript {$_.Caption -eq "$username"}).FullName 
$vorname = $fullname.Split(" ")[0] 
$nachname = $fullname.Split(" ")[1]
return $vorname
}
function get-userlastname(){

$Computername = $env:COMPUTERNAME
$username = (Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Computername).UserName 
$fullname = (get-WmiObject -Class Win32_UserAccount | Where-Object -FilterScript {$_.Caption -eq "$username"}).FullName 
$vorname = $fullname.Split(" ")[0] 
$nachname = $fullname.Split(" ")[1]
return $nachname;
}

function new-png($path){
Add-Type -AssemblyName System.Drawing
if(test-path($path)){
    $img = [System.Drawing.Image]::FromFile($path);
    
}
$filename = $path 
$bmp = new-object System.Drawing.Bitmap 250,61 
$font = new-object System.Drawing.Font Consolas,24 
$brushBg = [System.Drawing.Brushes]::Yellow 
$brushFg = [System.Drawing.Brushes]::Black 
$graphics = [System.Drawing.Graphics]::FromImage($bmp) 
$graphics.FillRectangle($brushBg,0,0,$bmp.Width,$bmp.Height) 
$graphics.DrawString('Hello World',$font,$brushFg,10,10) 
$graphics.Dispose() 
$bmp.Save($filename) 

}
#returns a property of the nuspec file
function get-nuspec-property($name, $path){
    $path = get-nuspec-path $path
    [xml] $xml = get-content $path
    return $xml.package.metadata[$name];
}

# creates a new icon for a package 
function new-icon($text, $path){
    Add-Type -AssemblyName System.Drawing
    $templatePath =  join-path $PSScriptRoot "../templates"
    $templatePngPath = join-path $templatePath "icon.png"
    $img =  [System.Drawing.Image]::FromFile($templatePngPath);    
    $font = new-object System.Drawing.Font Consolas,24 
    $brushFg = [System.Drawing.Brushes]::Black 
    $graphics = [System.Drawing.Graphics]::FromImage($img) 
    $rect = new-object System.Drawing.RectangleF;
    $rect.Width = $img.Width ;
    $rect.Height = $img.Height; 
    center-text $graphics $rect $text $font $brushFg;
    $graphics.Dispose() 
    if($path -eq $Null){
        $path = Get-Location
    }
    if(!(test-path -PathType Leaf $path)){
        $path = join-path $path "icon.png"
    }

    new-item -force -ItemType file  $path
    
    $img.Save($path)
}

function center-text([System.Drawing.Graphics] $graphics, [System.Drawing.RectangleF] $rect, [string]$text, [System.Drawing.Font] $font, [System.Drawing.Brush]$brush){

Add-Type -AssemblyName System.Drawing

[System.Drawing.StringFormat] $format = New-Object System.Drawing.StringFormat;
$format.Alignment = [System.Drawing.StringAlignment]::Center;
$format.LineAlignment = [System.Drawing.StringAlignment]::Center;

if($font -eq $Null){
  $font = new-object System.Drawing.Font Consolas,24 
}
if($brush -eq $Null){
    $brush = [System.Drawing.Brushes]::Black;
}


 $size = $graphics.MeasureString($text, $font);
[float] $scale = [Math]::Max($size.Width / $rect.Width, $size.Height / $rect.Height);
[float] $sizeInPoint = $font.SizeInPoints;
[float] $newSize = $sizeInPoint / $scale;
$font = New-Object -TypeName System.Drawing.Font -ArgumentList ($font.FontFamily, $newSize,[System.Drawing.GraphicsUnit]::Point);
$graphics.DrawString($text,$font, $brush, $rect, $format);
}
function new-chocopackage($name){
 # create folder structure
 $cd = Get-Location
 $basePath =  Join-Path $cd $name;
 $toolsPath = Join-Path $basePath "tools"
 if($name -eq $Null){
    $name = get-parentdirname;

 }
 
 $nuspecPath = Join-Path $basePath "$name.nuspec"
 
 
 write-host -NoNewline "creating new chocolatey '$name' package @ "
 write-host -ForegroundColor Yellow $basePath

 new-item  -ItemType directory -Force $basePath
 new-item -ItemType directory -Force $toolsPath
 



 # copy templates
 new-empty-nuspec -targetpath $nuspecPath
 new-chocoinstallscript $toolsPath
 new-icon $name;

 $author = get-userfullname
 $version = "0.1"
 $id = $name;
 $title = $title;
 $description = "description"
 update-nuspec -path $nuspecPath -authors $author -version $version -title $title -id $id 

}
#scaffold nuspec package
# .nuspec file
# icon.png
# readme.md
# 
function scaffold-nuspec-package($path){
  $nuspecPath = scaffold-nuspec  -path $path;
    
}
#scaffolds the package structure for a nuget package 
function scaffold-package-structure($path, $type){
    
    Invoke-Expression "scaffold-package-structure-$type $path";
     
}


function scaffold-package-structure-chocolatey($path){

}
function scaffold-package-structure-library($path){

}


# scaffolds nuspec package file for the specified path
function scaffold-nuspec($path){
      
    $name = get-parentdirname;

    if($path -eq $Null){
        $path = Get-Item *.nuspec 
        if($path -is [System.Array] -and $files.Length -ne 1){
            $path = "$name.nuspec"
        }
        if($path -eq $Null){
            $path = "$name.nuspec"
        }
    } 
   
   if(test-path $path){
       
    }else{
      new-empty-nuspec $path
    }
    $path = get-item $path
    [xml]$templateXml = Get-Content $path  

    if($templateXml.package.metadata.id -eq ""){
        update-nuspec -path $path -id $name
    }
    if($templateXml.package.metadata.title -eq ""){
        update-nuspec -path $path -title $name
    }
    if($templateXml.package.metadata.authors -eq ""){
        $author = get-userfullname;
       update-nuspec -path $path -authors $author
    }

    if($templateXml.package.metadata.owners -eq ""){
        $owner= get-userfullname;
       update-nuspec -path $path -owners $owner
        
    }

    $nuspecPath = (get-item $path).Directory;
    $readmeSearchPath = "$nuspecPath\readme*"
    write-host "searching for readme in $readmeSearchPath"
    $readmePath = get-item "$nuspecPath\readme*";

   
   if($templateXml.package.metadata.description -eq ""){
    if($readmePath -ne $Null -and (test-path $readmePath)){
         $description = cat $readmePath;
         update-nuspec -path $path -description $description
    }
   }
    
    write-host "nuspec now contains:  "
    write-host (cat $path )

    return $path;
}


# updates the nuspec files's version to the next git tag version
function update-nuspec-version($path){
    $path = get-nuspec-path $path

    [xml]$templateXml = Get-Content $path  

    $lastVersion = $templateXml.package.metadata.version;
    if($lastVersion -eq $Null -or $lastVersion -eq ""){
        $lastVersion = "0.0.0.0";
    } 

    [version]$version = [version]::Parse($lastVersion);

    [version]$sourceVersion = Get-CurrentVersion;

    if($version -lt $sourceVersion){
        update-nuspec -path $path -version "$sourceVersion"
    }

}

# returns the path of the nuspec file in the specified direcotry
function get-nuspec-path($path){
    $loc =get-item( get-location);
    
    # if path is not set, set it to curretn directory

    if($path -eq $Null){
        $path = Get-Location
    }

    if(test-path $path){
    }else{
        throw "path does not exist";
    }
    
    $path = get-item $path;
    
    
    if("$path".EndsWith(".nuspec")){
     if(test-path $path){
        return $path;
     }   
    }
    
    $path = @(get-item "$path\*.nuspec");

    if($path.count -gt 1){
        throw "multiple nuspec files found: $path"
    }
    if($path.Count -eq 1){

        return $path[0];
    }


    throw "no nuspec file found"
}
# returns the content of section identified by $sectionName
# a sectin is identified # SECTIONNAME
function get-markdown-section($path, $sectionName){  
   $matches = get-content -raw $path| select-String -Pattern "(?s)# $sectionName(?<content>.*?)(#|$)" | select -expand Matches
   [string]$sectionContent = $matches.Groups["content"].Value;
   return $sectionContent.Trim();
}
function update-nuspec-summary($path){
    $path = get-nuspec-path
    [xml]$templateXml = Get-Content $path  
    $nuspecPath = (get-item $path).Directory;
    $readmeSearchPath = "$nuspecPath\readme*"
    $readmePath = get-item $readmeSearchPath;
    if($readmePath -ne $Null -and (test-path $readmePath)){
          $content = get-markdown-section -path $readmePath -sectionName "Summary";
         update-nuspec -path $path -summary $content
    }
}
# updates the description of the nuspec file to by parsing the readme file in the same directory
function update-nuspec-description($path){
    $path = get-nuspec-path $path
    [xml]$templateXml = Get-Content $path  
    $nuspecPath = (get-item $path).Directory;
    $readmeSearchPath = "$nuspecPath\readme*"
    $readmePath = get-item $readmeSearchPath;
    if($readmePath -ne $Null -and (test-path $readmePath)){     
         $content = get-markdown-section -path $readmePath Description;
         update-nuspec -path $path -description $content
    }

    
   

}

# scaffolds a nuspec file by using the info from github
function scaffold-nuspec-github($path){
    $path = scaffold-nuspec($path)

    
    [xml]$templateXml = Get-Content $path  
    $version = Get-CurrentVersion
    
    update-nuspec-version $path
}

# sets the properties of the nuspec file
function update-nuspec($path, $id, $title, $version, $owners, $authors, $description,$summary ){
   
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
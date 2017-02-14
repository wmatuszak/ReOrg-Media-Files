# Process-Media-Files.ps1

Import-Module -Force ($PSScriptRoot + "\lib\Reorg-Media-Files.psm1")

$MediaLibraryCache = "D:\Users\walt\Pictures\MediaLibrary.xml"

$allMediaLibraryFiles = New-Object System.Collections.ArrayList;
$allMediaImportFiles = New-Object System.Collections.ArrayList;

$allMediaLibraryFolders = @(
                    "D:\Users\walt\Pictures\Family Photo Gallery"
                    )

$allMediaImportFolders = @(
                    "D:\Users\walt\Pictures\_Import"
                    )

$mediaLibraryTarget = "D:\Users\walt\Pictures\Family Photo Gallery"

if(Test-Path $MediaLibraryCache) 
{ 
    # Load media file cache
    $allMediaLibraryFiles = Import-Clixml -Path $MediaLibraryCache

    # Update file cache for removed files
    $filesRemovedFromCache = New-Object System.Collections.ArrayList;
    foreach($cacheFile in $allMediaLibraryFiles) { if(-not(Test-Path $cacheFile.FullName)){ $filesRemovedFromCache.Add($cacheFile) } } 
    foreach($removed in $filesRemovedFromCache) { $allMediaLibraryFiles.Remove($removed) }
}
else
{
    # Cache not found, rebuilding...
    foreach($folder in $allMediaLibraryFolders)
    {
        foreach($file in Get-ChildItem -Recurse -File $folder)
        {
            $m = New-Media $file
            $allMediaLibraryFiles.Add($m)
        }
    }
}

# Build List of Files to Import 
foreach($folder in $allMediaImportFolders)
{
    foreach($file in Get-ChildItem -Recurse -File $folder)
    {
        $m = New-Media $file
        $allMediaImportFiles.Add($m)
    }
}
# Process each Import File 
foreach($newfile in $allMediaImportFiles)
{
    $flag = $true
    # Check for MD5 Hash Collision (dup)
    if($allMediaLibraryFiles.Where({$_.MD5 -eq $newfile.MD5}) -ne $null){ $flag = $false }

    # TODO: Add other checks

    if($flag)
    {
        # Find Best Date for New File
        $newdate = Date-Media $newfile
        if($newdate -ne $null)
        {
            # Generate File Name and Path
            do
            {
                # Build Folder Target
                $newpath = $mediaLibraryTarget + "\" + $newdate.Year + "\" + $newdate.Month + "_" + (Get-Culture).DateTimeFormat.GetMonthName($newdate.Month)
                if(-not(Test-Path $newpath)) { New-Item -ItemType Directory -Path $newpath -Force }
                
                # Build File Name
                $newname = Build-NewFileName $newdate $newfile.Extension
                $newtarget = $newpath + "\" + $newname
            }
            while(Test-Path $newtarget)
            
            # Relocate New File 
            Move-Item -Path $newfile.FullName -Destination $newtarget
            $msg = $newfile.FullName + " -> " + $newtarget
            Write-Host $msg

            # Add New File to Media Library
            $relocatefile = Get-ChildItem $newtarget
            $m = New-Media $relocatefile
            $allMediaLibraryFiles.Add($m)
        }
    }
    else
    {
        Write-Host "Skipped: Duplicate Already in Library..."
        Write-Host $newfile.FullName
        Remove-Item $newfile.FullName

    }
}

# Update Media Library Cache File
Export-Clixml -InputObject $allMediaLibraryFiles -Path $MediaLibraryCache

# ReOrg Media Files

This project is a Powershell tool that processes, reorganizes, and deduplicates 
your media files.

This is a rewrite and consolidation of several old scripts I have been using for 
several years.

## Download Latest Version

Code located in the `master` branch is under development.

- [Download [zip]](https://github.com/wmatuszak/ReOrg-Media-Files/archive/master.zip)

## Usage

Enable execution of PowerShell scripts:

    PS> Set-ExecutionPolicy Unrestricted

Unblock PowerShell scripts and modules within this directory:

    PS > ls -Recurse *.ps1 | Unblock-File
    PS > ls -Recurse *.psm1 | Unblock-File
	
Edit the paths in the main Process-Media-Files.ps1:
	
    $allMediaLibraryFolders > All the folders containing processed media files
	$allMediaImportFolders > All the folders containing unprocessed media files
	$MediaLibraryCache > The path to the MediaCache.xml cache file
	$mediaLibraryTarget > The target for newly processed media files

Execute the main script:

    PS > Process-Media-Files.ps1
	
Processed files will be organized in the target library as follows:

    LibraryRoot\Year\Month\yyyy-mm-dd_hh-mm-ss_xxx.jpg
	
## Liability

**All scripts are provided as is and you use them at your own risk.**

## Contribute

I would be happy to extend this tool. Just open an issue or
send me a pull request.

### Thanks to the people and projects leveraged by this tool:

- [Color Summarizer](http://mkweb.bcgsc.ca/color-summarizer/)
- [ImageMagick](https://www.imagemagick.org)
- [MediaInfo](https://mediaarea.net/en/MediaInfo)
- [PSImage](https://gallery.technet.microsoft.com/scriptcenter/PowerShell-Image-module-caa4405a)

## License

    "THE BEER-WARE LICENSE" (Revision 42):

    As long as you retain this notice you can do whatever you want with this
    stuff. If we meet some day, and you think this stuff is worth it, you can
    buy us a beer in return.

    This project is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
    FITNESS FOR A PARTICULAR PURPOSE.

# Reorg-Media-Files.psm1

Import-Module -Force ($PSScriptRoot + "\Image-PSM\Image.psd1")

$ImageMagickIdentifyPath = $PSScriptRoot + "\ImageMagick\identify.exe";
$ImageMagickIdentifyArgs = ""

$ColorSummarizerPath = $PSScriptRoot + "\ColorSummarizer\colorsummarizer.exe";
$ColorSummarizerArgs = "-stats -xml -image" 

$MediaInfoPath = $PSScriptRoot + "\MediaInfo\MediaInfo.exe";
$MediaInfoArgs = "--Output=XML"

$ImageFileExtensions = @(".bmp",".jpg",".cr2",".png")
$VideoFileExtensions = @(".avi",".mp4",".m4v",".mov",".3gp",".3g2")

$ImageMagickComparePath = $PSScriptRoot + "\ImageMagick\compare.exe";
$ImageMagickCompareArgsPre = "-metric RMSE"
$ImageMagickCompareArgsPost = "NULL:"

function New-Media($file)
{
  if(($file -ne $null) -AND (Test-Path $file.FullName))
  {
      $exif = $null
      $imgCheck = $null
      $imgRGBAvg = $null
      $vidCheck = $null
      
      $media = new-object PSObject;

      $media | add-member -type NoteProperty -Name Name -Value $file.Name; 
      $media | add-member -type NoteProperty -Name FullName -Value $file.FullName;
      $media | add-member -type NoteProperty -Name CreatedDate -Value $file.CreationTime;
      $media | add-member -type NoteProperty -Name ModifiedDate -Value $file.LastWriteTime;
      $media | add-member -type NoteProperty -Name AccessedDate -Value $file.LastAccessTime;
      $media | add-member -type NoteProperty -Name MD5 -Value (Get-FileHash -Path $file.FullName -Algorithm MD5).Hash;
      $media | add-member -type NoteProperty -Name Extension -Value $file.Extension;
      if($ImageFileExtensions.Contains($file.Extension.ToLower())) { $exif = Get-Exif $file.FullName; }
      $media | add-member -type NoteProperty -Name EXIF -Value $exif;
      if($ImageFileExtensions.Contains($file.Extension.ToLower())) { $imgCheck = "ERROR"; $imgCheckCmd = $ImageMagickIdentifyPath + " " + $ImageMagickIdentifyArgs + " " + ("'" + $file.FullName.Replace("'","''") + "'"); $imgCheck = Invoke-Expression $imgCheckCmd };
      $media | add-member -type NoteProperty -Name ImageCheck -Value $imgCheck
      if($ImageFileExtensions.Contains($file.Extension.ToLower())) { $imgRGBAvgCmd = $ColorSummarizerPath + " " + $ColorSummarizerArgs + " " + ("'" + $file.FullName.Replace("'","''") + "'"); $imgRGBAvgRaw = Invoke-Expression $imgRGBAvgCmd; $imgRGBAvg = ([System.Xml.XmlDocument]$imgRGBAvgRaw).imgdata.stats.rgb.avg };
      $media | add-member -type NoteProperty -Name ImageSummary -Value $imgRGBAvg
      if($VideoFileExtensions.Contains($file.Extension.ToLower())) { $vidCheckCmd = $MediaInfoPath + " " + $MediaInfoArgs + " " + ("'" + $file.FullName.Replace("'","''") + "'"); $vidCheck = Invoke-Expression $vidCheckCmd };
      $media | add-member -type NoteProperty -Name VideoCheck -Value $vidCheck;
  }
  else { $media = $null }

  return $media;
}

function Compare-Media($media1,$media2)
{
    $compareCheck = $null
    $compareCmd = $ImageMagickComparePath + " " + $ImageMagickCompareArgsPre + " " + ("'" + $media1.FullName.Replace("'","''") + "'") + " " + ("'" + $media2.FullName.Replace("'","''") + "'") + " " + $ImageMagickCompareArgsPost
    $compareCheck = (Invoke-Expression $compareCmd) 2>&1
    $compareCheck = $compareCheck.ToString().Substring(0,$compareCheck.ToString().IndexOf(" "))
    if($compareCheck -eq "compare.exe:") { $compareCheck = "ERROR"; }
    return $compareCheck
}

function Date-Media($media)
{
    $randomGenerator = New-Object System.Random
    $possibleDates = New-Object System.Collections.ArrayList;

    $nameDate = $null
    $nameString = $media.Name
    try
    {
        if([int]($nameString.Substring(0,4)) -ge 2000 -AND [int]($nameString.Substring(0,4)) -le 2100)
        {
        
            $nameString = $nameString.Substring(0,$nameString.LastIndexOfAny("_"))
            $dstring = $nameString.Substring(0,$nameString.LastIndexOfAny("_"))
            $tstring = $nameString.Substring($nameString.LastIndexOfAny("_")+1).Replace("-",":")
            $nameDate = Get-Date -Date ($dstring + " " + $tstring)
        }
    } catch {}
    
    if($nameDate -ne $null){$output = $possibleDates.Add($nameDate)}

    $output = $possibleDates.Add($media.CreatedDate)
    $output = $possibleDates.Add($media.ModifiedDate)
    $output = $possibleDates.Add($media.AccessedDate)
    if($media.EXIF -ne $null) { $output = $possibleDates.Add($media.EXIF.DateTaken) }

    try { $possibleDates.Sort() } catch { }
    if($possibleDates.Count -gt 0) { $date = $possibleDates[0] }
    else { $date = $null }

    return $date
}

function Build-NewFileName($Date, $Extension) {
    $RandomGenerator = New-Object System.Random
	return [String]::Format("{0}_{1}{2}", $Date.ToString("yyyy-MM-dd_HH-mm-ss"), $RandomGenerator.Next(100, 1000).ToString(), $Extension)
}
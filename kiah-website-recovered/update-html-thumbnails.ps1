param(
    [string]$HtmlFile,
    [switch]$AllFiles = $false,
    [switch]$DryRun = $false
)

Write-Host ""
Write-Host "=== HTML Image to Thumbnail Updater ===" -ForegroundColor Cyan
Write-Host ""

$rootPath = "f:\Kiah Website Backup\kiah-website-recovered"

if ($AllFiles) {
    $htmlFiles = Get-ChildItem -Path $rootPath -Filter "*.html" -File
    Write-Host "Processing all HTML files: $($htmlFiles.Count) files" -ForegroundColor Green
} elseif ($HtmlFile) {
    if (-not (Test-Path $HtmlFile)) {
        Write-Host "ERROR: File not found: $HtmlFile" -ForegroundColor Red
        exit
    }
    $htmlFiles = @(Get-Item $HtmlFile)
    Write-Host "Processing single file: $HtmlFile" -ForegroundColor Green
} else {
    Write-Host "ERROR: Please specify either -HtmlFile or -AllFiles" -ForegroundColor Red
    Write-Host "Example: .\update-html-thumbnails.ps1 -AllFiles" -ForegroundColor Yellow
    Write-Host "Example: .\update-html-thumbnails.ps1 -HtmlFile friends.html" -ForegroundColor Yellow
    exit
}

Write-Host "Dry Run: $DryRun"
Write-Host ""

$totalUpdated = 0
$totalFiles = 0

foreach ($file in $htmlFiles) {
    Write-Host "Processing: $($file.Name)" -ForegroundColor Cyan
    
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    $updated = 0
    
    # Pattern to match img tags with data-gallery attribute
    # Supports both old extensions (jpg, png, etc.) and webp
    
    $pattern = '<img\s+([^>]*?)src="(Images/[^"]+?\.(jpg|jpeg|png|gif|bmp|webp|JPG|JPEG|PNG|GIF|BMP|WEBP))"([^>]*?data-gallery[^>]*?)>'
    
    $matches = [regex]::Matches($content, $pattern)
    
    foreach ($match in $matches) {
        $beforeSrc = $match.Groups[1].Value
        $imagePath = $match.Groups[2].Value
        $extension = $match.Groups[3].Value
        $afterSrc = $match.Groups[4].Value
        $fullMatch = $match.Value
        
        # Skip if already has data-full or _thumb
        if ($imagePath -like "*_thumb.webp" -or $fullMatch -like '*data-full=*') {
            continue
        }
        
        # Convert extension to .webp if needed and create thumbnail path
        $webpPath = $imagePath -replace '\.(jpg|jpeg|png|gif|bmp|JPG|JPEG|PNG|GIF|BMP)$', '.webp'
        $thumbPath = $webpPath -replace '\.webp$', '_thumb.webp'
        
        # Build new img tag with thumbnail src and data-full attribute
        $newImgTag = "<img $beforeSrc" + "src=`"$thumbPath`" data-full=`"$webpPath`"$afterSrc>"
        
        $content = $content.Replace($fullMatch, $newImgTag)
        $updated++
    }
    
    if ($updated -gt 0) {
        if ($DryRun) {
            Write-Host "  Would update $updated images" -ForegroundColor Yellow
        } else {
            Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
            Write-Host "  Updated $updated images" -ForegroundColor Green
            $totalFiles++
        }
        $totalUpdated += $updated
    } else {
        Write-Host "  No changes needed" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "=== Update Complete ===" -ForegroundColor Cyan
Write-Host "Files updated: $totalFiles"
Write-Host "Total images updated: $totalUpdated"
Write-Host ""

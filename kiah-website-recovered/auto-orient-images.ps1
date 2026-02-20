# Auto-orient all images based on EXIF orientation data
$ErrorActionPreference = "SilentlyContinue"
$imagick = "C:\Program Files\ImageMagick-7.1.2-Q16-HDRI\magick.exe"
$baseImagePath = "e:\Kiah Website Backup\kiah-website-recovered\Images"

$folders = @('Friends', 'Eagle', 'Round Table', 'TrinidadTobago')
$totalProcessed = 0
$totalFixed = 0

Write-Host "`n=== Auto-Orienting Images ===" -ForegroundColor Yellow
Write-Host "This will fix any sideways or upside-down images`n"

foreach($folder in $folders) {
    $path = Join-Path $baseImagePath $folder
    if (Test-Path $path) {
        Write-Host "Processing $folder..." -ForegroundColor Cyan
        $images = Get-ChildItem $path -Filter "*.webp" -Recurse
        
        $folderFixed = 0
        foreach($img in $images) {
            # Check current orientation
            $orientation = & $imagick identify -format "%[EXIF:Orientation]" $img.FullName 2>$null
            
            # Auto-orient if needed (orientation values other than 1 or empty)
            if($orientation -and $orientation -ne "1" -and $orientation -ne "") {
                & $imagick $img.FullName -auto-orient $img.FullName 2>$null
                $folderFixed++
            }
            
            $totalProcessed++
            if($totalProcessed % 200 -eq 0) {
                Write-Host "  Processed $totalProcessed images..." -ForegroundColor Gray
            }
        }
        
        $totalFixed += $folderFixed
        Write-Host "  $folder`: Fixed $folderFixed images" -ForegroundColor Green
    }
}

Write-Host "`nCompleted!" -ForegroundColor Green
Write-Host "Total images processed: $totalProcessed"
Write-Host "Total images fixed: $totalFixed"

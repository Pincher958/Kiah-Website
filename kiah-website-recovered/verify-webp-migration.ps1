param(
    [string]$ImagesPath = "f:\Kiah Website Backup\kiah-website-recovered\Images"
)

Write-Host ""
Write-Host "=== WebP Migration Safety Check ===" -ForegroundColor Cyan
Write-Host ""

# Get all original images
$originalExtensions = @('.jpg', '.jpeg', '.png', '.gif', '.bmp', '.tif', '.jfif', '.THM')
$originalImages = Get-ChildItem -Path $ImagesPath -Recurse -File | Where-Object {
    $originalExtensions -contains $_.Extension
}

Write-Host "Checking $($originalImages.Count) original images..." -ForegroundColor Yellow
Write-Host ""

$safe = 0
$missing = 0
$missingThumb = 0
$missingFiles = @()
$missingThumbFiles = @()

foreach ($original in $originalImages) {
    # Check for WebP version
    $webpPath = [System.IO.Path]::ChangeExtension($original.FullName, '.webp')
    $thumbPath = $webpPath -replace '\.webp$', '_thumb.webp'
    
    $hasWebP = Test-Path $webpPath
    $hasThumb = Test-Path $thumbPath
    
    if ($hasWebP -and $hasThumb) {
        $safe++
    } elseif (-not $hasWebP) {
        $missing++
        $missingFiles += $original.FullName
        Write-Host "MISSING WebP: $($original.FullName)" -ForegroundColor Red
    } elseif (-not $hasThumb) {
        $missingThumb++
        $missingThumbFiles += $original.FullName
        Write-Host "MISSING Thumbnail: $($original.FullName)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== Results ===" -ForegroundColor Cyan
Write-Host "Total original images: $($originalImages.Count)"
Write-Host "Safe to delete (has WebP + Thumbnail): $safe" -ForegroundColor Green
Write-Host "Missing WebP conversion: $missing" -ForegroundColor $(if ($missing -eq 0) { "Green" } else { "Red" })
Write-Host "Missing Thumbnail: $missingThumb" -ForegroundColor $(if ($missingThumb -eq 0) { "Green" } else { "Yellow" })
Write-Host ""

if ($missing -eq 0 -and $missingThumb -eq 0) {
    Write-Host "✓ ALL ORIGINAL IMAGES HAVE BEEN SUCCESSFULLY CONVERTED!" -ForegroundColor Green
    Write-Host "✓ It is SAFE to delete all original non-WebP images." -ForegroundColor Green
    Write-Host ""
    $totalSize = ($originalImages | Measure-Object -Property Length -Sum).Sum
    $sizeMB = [math]::Round($totalSize / 1MB, 2)
    $sizeGB = [math]::Round($totalSize / 1GB, 2)
    Write-Host "Deleting original images would free up: $sizeMB MB ($sizeGB GB)" -ForegroundColor Cyan
} else {
    Write-Host "⚠ WARNING: Some images are missing conversions!" -ForegroundColor Red
    Write-Host "DO NOT delete original images yet." -ForegroundColor Red
}

Write-Host ""

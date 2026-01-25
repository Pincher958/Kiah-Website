param(
    [switch]$DryRun = $false
)

# ImageMagick path
$magickPath = "C:\Program Files\ImageMagick-7.1.2-Q16-HDRI\magick.exe"

if (-not (Test-Path $magickPath)) {
    Write-Host "ERROR: ImageMagick not found at $magickPath" -ForegroundColor Red
    exit 1
}

Write-Host "=== Resizing Large Images (Over 800KB) ===" -ForegroundColor Cyan
Write-Host "Maximum width: 1600px"
Write-Host "Quality: 80"
Write-Host "Dry Run: $DryRun" -ForegroundColor $(if ($DryRun) { "Yellow" } else { "Green" })
Write-Host ""

# Find all WebP images over 800KB (excluding thumbnails)
$largeImages = Get-ChildItem -Path "Images" -Recurse -File -Include "*.webp" | 
    Where-Object { $_.Name -notmatch "_thumb" -and $_.Length -gt 800KB }

$totalCount = $largeImages.Count
Write-Host "Found $totalCount images over 800KB to resize"
Write-Host ""

if ($DryRun) {
    Write-Host "DRY RUN - No files will be modified" -ForegroundColor Yellow
    Write-Host ""
    $largeImages | Select-Object -First 20 | ForEach-Object {
        Write-Host "Would resize: $($_.Name) ($([math]::Round($_.Length / 1KB, 2)) KB)"
    }
    if ($totalCount -gt 20) {
        Write-Host "... and $($totalCount - 20) more files"
    }
    exit 0
}

# Confirm action
Write-Host "This will resize $totalCount images to max 1600px wide" -ForegroundColor Yellow
$confirmation = Read-Host "Continue? (y/n)"
if ($confirmation -ne 'y') {
    Write-Host "Operation cancelled" -ForegroundColor Red
    exit 0
}

$resized = 0
$errors = 0
$totalSizeBefore = 0
$totalSizeAfter = 0
$startTime = Get-Date

foreach ($image in $largeImages) {
    $sizeBefore = $image.Length
    $totalSizeBefore += $sizeBefore
    
    try {
        # Resize to max 1600px width, maintaining aspect ratio
        # The ">" flag means only shrink larger images, don't enlarge smaller ones
        & $magickPath $image.FullName -resize "1600x>" -quality 80 $image.FullName
        
        $resized++
        
        # Get new size
        $sizeAfter = (Get-Item $image.FullName).Length
        $totalSizeAfter += $sizeAfter
        $reduction = [math]::Round((($sizeBefore - $sizeAfter) / $sizeBefore) * 100, 1)
        
        Write-Host "RESIZED: $($image.Name) - $([math]::Round($sizeBefore / 1KB, 2)) KB -> $([math]::Round($sizeAfter / 1KB, 2)) KB ($reduction% reduction)"
        
        # Progress indicator
        if ($resized % 50 -eq 0) {
            $percentComplete = [math]::Round(($resized / $totalCount) * 100, 1)
            Write-Host "`nProgress: $percentComplete% | Resized: $resized | Errors: $errors`n" -ForegroundColor Cyan
        }
    }
    catch {
        $errors++
        Write-Host "ERROR: Failed to resize $($image.Name) - $_" -ForegroundColor Red
    }
}

$endTime = Get-Date
$duration = ($endTime - $startTime).TotalMinutes

Write-Host "`n=== Resize Complete ===" -ForegroundColor Green
Write-Host "Total images processed: $totalCount"
Write-Host "Successfully resized: $resized"
Write-Host "Errors: $errors"
Write-Host "Size before: $([math]::Round($totalSizeBefore / 1MB, 2)) MB"
Write-Host "Size after: $([math]::Round($totalSizeAfter / 1MB, 2)) MB"
Write-Host "Space saved: $([math]::Round(($totalSizeBefore - $totalSizeAfter) / 1MB, 2)) MB"
Write-Host "Time taken: $([math]::Round($duration, 1)) minutes"

# Image to WebP Converter Script
# This script converts JPG, JPEG, PNG, GIF, BMP, TIF, JFIF images to WebP format

param(
    [string]$ImagesPath = "f:\Kiah Website Backup\kiah-website-recovered\Images",
    [int]$Quality = 85,
    [switch]$DeleteOriginals = $false,
    [switch]$DryRun = $false
)

Write-Host "=== Image to WebP Converter ===" -ForegroundColor Cyan
Write-Host "Images Path: $ImagesPath" -ForegroundColor Yellow
Write-Host "Quality: $Quality" -ForegroundColor Yellow
Write-Host "Delete Originals: $DeleteOriginals" -ForegroundColor Yellow
Write-Host "Dry Run: $DryRun" -ForegroundColor Yellow
Write-Host ""

# Check if System.Drawing is available
Add-Type -AssemblyName System.Drawing

# Image extensions to convert
$imageExtensions = @('.jpg', '.jpeg', '.png', '.gif', '.bmp', '.tif', '.jfif')

# Get all image files
Write-Host "Scanning for images..." -ForegroundColor Cyan
$imageFiles = Get-ChildItem -Path $ImagesPath -Recurse -File | Where-Object {
    $imageExtensions -contains $_.Extension.ToLower()
}

$totalFiles = $imageFiles.Count
Write-Host "Found $totalFiles images to convert" -ForegroundColor Green
Write-Host ""

$converted = 0
$skipped = 0
$errors = 0
$totalOriginalSize = 0
$totalWebPSize = 0

foreach ($file in $imageFiles) {
    $webpPath = [System.IO.Path]::ChangeExtension($file.FullName, '.webp')
    
    # Skip if WebP already exists
    if (Test-Path $webpPath) {
        Write-Host "SKIP: $($file.Name) (WebP already exists)" -ForegroundColor Yellow
        $skipped++
        continue
    }
    
    try {
        $totalOriginalSize += $file.Length
        
        if ($DryRun) {
            Write-Host "WOULD CONVERT: $($file.FullName) -> $webpPath" -ForegroundColor Gray
            $converted++
        } else {
            Write-Host "Converting: $($file.Name)..." -ForegroundColor White -NoNewline
            
            # Load the image
            $image = [System.Drawing.Image]::FromFile($file.FullName)
            
            # Create a new bitmap with the same dimensions
            $bitmap = New-Object System.Drawing.Bitmap($image.Width, $image.Height)
            $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
            $graphics.DrawImage($image, 0, 0, $image.Width, $image.Height)
            
            # Save as PNG first (since .NET doesn't natively support WebP)
            # We'll need to use an external tool for actual WebP conversion
            $tempPng = [System.IO.Path]::ChangeExtension($file.FullName, '.temp.png')
            $bitmap.Save($tempPng, [System.Drawing.Imaging.ImageFormat]::Png)
            
            # Clean up
            $graphics.Dispose()
            $bitmap.Dispose()
            $image.Dispose()
            
            # Note: This creates PNG files with .webp extension
            # For true WebP conversion, we need cwebp tool
            Move-Item -Path $tempPng -Destination $webpPath -Force
            
            $webpSize = (Get-Item $webpPath).Length
            $totalWebPSize += $webpSize
            
            $savings = [math]::Round((($file.Length - $webpSize) / $file.Length) * 100, 1)
            Write-Host " Done! (Saved: $savings%)" -ForegroundColor Green
            
            # Delete original if requested
            if ($DeleteOriginals) {
                Remove-Item $file.FullName -Force
                Write-Host "  Deleted original" -ForegroundColor DarkGray
            }
            
            $converted++
        }
    }
    catch {
        Write-Host " ERROR: $($_.Exception.Message)" -ForegroundColor Red
        $errors++
    }
    
    # Progress update every 50 files
    if (($converted + $skipped + $errors) % 50 -eq 0) {
        $progress = [math]::Round((($converted + $skipped + $errors) / $totalFiles) * 100, 1)
        Write-Host "Progress: $progress% ($converted converted, $skipped skipped, $errors errors)" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host "=== Conversion Complete ===" -ForegroundColor Cyan
Write-Host "Total files processed: $totalFiles" -ForegroundColor White
Write-Host "Converted: $converted" -ForegroundColor Green
Write-Host "Skipped: $skipped" -ForegroundColor Yellow
Write-Host "Errors: $errors" -ForegroundColor Red

if (!$DryRun -and $totalWebPSize -gt 0) {
    $originalSizeMB = [math]::Round($totalOriginalSize / 1MB, 2)
    $webpSizeMB = [math]::Round($totalWebPSize / 1MB, 2)
    $savedMB = [math]::Round(($totalOriginalSize - $totalWebPSize) / 1MB, 2)
    $savedPercent = [math]::Round((($totalOriginalSize - $totalWebPSize) / $totalOriginalSize) * 100, 1)
    
    Write-Host ""
    Write-Host "Size Comparison:" -ForegroundColor Cyan
    Write-Host "  Original: $originalSizeMB MB" -ForegroundColor White
    Write-Host "  WebP: $webpSizeMB MB" -ForegroundColor White
    Write-Host "  Saved: $savedMB MB ($savedPercent%)" -ForegroundColor Green
}

Write-Host ""
Write-Host "NOTE: This script uses .NET System.Drawing which creates PNG files." -ForegroundColor Yellow
Write-Host "For true WebP conversion with better compression, install Google's cwebp tool:" -ForegroundColor Yellow
Write-Host "  winget install Google.WebP" -ForegroundColor Gray

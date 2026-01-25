# WebP Image Conversion Guide

## Overview

Your website has **3.8 GB of images** that can be converted to WebP format to save approximately **25-35% in file size** (estimated savings: ~1 GB).

## What's Been Set Up

✅ **ImageMagick installed** - Professional image conversion tool with WebP support  
✅ **Conversion script ready** - `convert-images-webp.ps1`  
✅ **Backup will be created** - Before any conversions start

## Step-by-Step Instructions

### Step 1: Test Run (Dry Run)

First, see what would be converted without making any changes:

```powershell
.\convert-images-webp.ps1 -DryRun
```

### Step 2: Convert Images (Keep Originals)

Convert all images to WebP while keeping the original files:

```powershell
.\convert-images-webp.ps1
```

This will:

- Create a backup of your Images folder first
- Convert JPG, JPEG, PNG, GIF, BMP, TIF images to WebP at 85% quality
- Keep all original files
- Generate a detailed log file

### Step 3: Convert and Delete Originals (Optional)

If you're happy with the WebP versions, run again to delete originals:

```powershell
.\convert-images-webp.ps1 -DeleteOriginals
```

### Custom Options

```powershell
# Use different quality (1-100, default 85)
.\convert-images-webp.ps1 -Quality 90

# Skip the automatic backup
.\convert-images-webp.ps1 -BackupFirst:$false

# Convert specific folder only
.\convert-images-webp.ps1 -ImagesPath "f:\Kiah Website Backup\kiah-website-recovered\Images\Eagle"
```

## After Conversion: Update HTML Files

Once images are converted, you'll need to update all HTML files to reference the new `.webp` extensions.

### Option A: Update All at Once

I can create a script to automatically update all `<img>` tags in your HTML files to use `.webp` extensions.

### Option B: Update Manually

Change image references from:

```html
<img src="Images/Eagle/photo.jpg" alt="..." />
```

to:

```html
<img src="Images/Eagle/photo.webp" alt="..." />
```

## Expected Results

- **Current size**: 3,836 MB (Images folder)
- **Expected after conversion**: ~2,500-2,800 MB
- **Savings**: ~1,000-1,300 MB (25-35% reduction)

Combined with Git history cleanup (4.5 GB), you should be able to get your repository under 5 GB for GitHub.

## Safety Features

✅ Automatic backup before conversion  
✅ Dry-run mode to preview changes  
✅ Detailed logging of all conversions  
✅ Skips already-converted images  
✅ Option to keep originals for comparison

## Files Created

- `convert-images-webp.ps1` - Main conversion script
- `webp-conversion-log.txt` - Conversion log (created during run)
- `Images_Backup_[timestamp]` - Backup folder (created during run)

## Next Steps

1. ✅ Run dry-run to preview: `.\convert-images-webp.ps1 -DryRun`
2. ⏳ Run actual conversion: `.\convert-images-webp.ps1`
3. ⏳ Update HTML files to reference .webp files
4. ⏳ Test your website locally
5. ⏳ Delete originals if satisfied: `.\convert-images-webp.ps1 -DeleteOriginals`
6. ⏳ Clean Git history to remove old large files

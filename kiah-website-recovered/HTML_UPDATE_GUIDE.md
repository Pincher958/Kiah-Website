# HTML Update Script - Guide

## Overview

This script automatically updates all HTML and CSS files to reference the new `.webp` image files instead of the original formats (JPG, PNG, GIF, BMP, etc.).

## What It Does

The script updates image references in:

- ✅ `<img src="...">` tags
- ✅ `background-image: url(...)` CSS properties
- ✅ `background: url(...)` CSS properties
- ✅ `<a href="...">` links to images

## Usage

### Step 1: Preview Changes (Dry Run)

See what would be changed without modifying any files:

```powershell
.\update-html-to-webp.ps1 -DryRun
```

This shows you:

- Which files will be updated
- How many changes per file
- What types of references will be updated

### Step 2: Apply Changes

Update all HTML and CSS files:

```powershell
.\update-html-to-webp.ps1
```

This will:

- Create a backup of all HTML and CSS files first
- Update all image references to use `.webp` extensions
- Generate a detailed log file
- Preserve all formatting and encoding

### Step 3: Test Your Website

After updating, test locally to ensure all images load correctly:

```powershell
# Open index.html in a browser to test
start index.html
```

## Examples of What Gets Updated

**Before:**

```html
<img src="Images/Eagle/photo.jpg" alt="Eagle" />
<img src="Images/Malta/sunset.png" alt="Sunset" />
```

**After:**

```html
<img src="Images/Eagle/photo.jpg.webp" alt="Eagle" />
<img src="Images/Malta/sunset.png.webp" alt="Sunset" />
```

**CSS Before:**

```css
background-image: url("Images/backgrounds/ocean.jpg");
```

**CSS After:**

```css
background-image: url("Images/backgrounds/ocean.jpg.webp");
```

## Safety Features

✅ Automatic backup of all HTML/CSS files before changes  
✅ Dry-run mode to preview all changes  
✅ Detailed logging of every change  
✅ Case-insensitive matching (handles .jpg, .JPG, .Jpg, etc.)  
✅ UTF-8 encoding preserved  
✅ Skips backup folders automatically

## Files Created

- `update-html-to-webp.ps1` - Main update script
- `html-update-log.txt` - Detailed log of all changes
- `HTML_Backup_[timestamp]` - Backup folder with original HTML/CSS files

## Custom Options

```powershell
# Skip automatic backup (not recommended)
.\update-html-to-webp.ps1 -BackupFirst:$false

# Process specific directory only
.\update-html-to-webp.ps1 -WebsitePath "f:\Kiah Website Backup\kiah-website-recovered\specific-folder"
```

## Complete Workflow

1. ✅ **WebP Conversion**: Run `convert-images-webp.ps1` (in progress)
2. ⏳ **Preview HTML Updates**: Run `.\update-html-to-webp.ps1 -DryRun`
3. ⏳ **Apply HTML Updates**: Run `.\update-html-to-webp.ps1`
4. ⏳ **Test Website**: Open and test all pages
5. ⏳ **Verify Images**: Check that all images display correctly
6. ⏳ **Clean Originals**: Run `.\convert-images-webp.ps1 -DeleteOriginals` (optional)
7. ⏳ **Commit to Git**: Stage and commit changes
8. ⏳ **Clean Git History**: Remove old large files from Git history

## Troubleshooting

**Q: Some images aren't loading after the update?**  
A: Check that the corresponding `.webp` file exists in the Images folder. The conversion script may have skipped some files.

**Q: Can I revert the changes?**  
A: Yes! Use the backup folder `HTML_Backup_[timestamp]` to restore original files.

**Q: What if I add more images later?**  
A: Convert them with the conversion script, then run the HTML updater again. It will only update files that need changes.

## Notes

- The script appends `.webp` to existing filenames (e.g., `photo.jpg` → `photo.jpg.webp`)
- This matches how ImageMagick converts the files
- All original file references are preserved in the backup
- The log file shows every single change made for verification

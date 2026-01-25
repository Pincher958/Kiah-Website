# Complete WebP Migration Workflow

## Current Status: ✅ Ready

### Scripts Created

1. ✅ `convert-images-webp.ps1` - Converts images to WebP format
2. ✅ `update-html-to-webp.ps1` - Updates HTML/CSS to reference WebP files
3. ✅ ImageMagick installed and configured

### Currently Running

🔄 **WebP Conversion** - Creating backup, then converting ~3,800 MB of images

- Expected time: 30-60 minutes total
- This includes backup creation and conversion

---

## Complete Step-by-Step Workflow

### Phase 1: Image Conversion (IN PROGRESS)

```powershell
# Already running - wait for completion
# Watch for "=== Conversion Complete ===" message
```

**What's happening:**

- Creating backup of Images folder
- Converting all JPG, PNG, GIF, BMP, TIF images to WebP
- Original files are kept
- Expected savings: ~1 GB (25-35% reduction)

### Phase 2: Update HTML Files (READY)

```powershell
# Preview what will change
.\update-html-to-webp.ps1 -DryRun

# Apply the updates
.\update-html-to-webp.ps1
```

**What this does:**

- Backs up all HTML and CSS files
- Updates image references to use .webp extensions
- Updates: <img src>, background-image, background, <a href> tags

### Phase 3: Test Website (AFTER PHASE 2)

```powershell
# Open website locally
start index.html
```

**Test checklist:**

- [ ] All images display correctly
- [ ] Lightbox/galleries work
- [ ] Background images load
- [ ] Check multiple pages
- [ ] Test on different browsers

### Phase 4: Clean Up Original Images (OPTIONAL)

```powershell
# Only after confirming WebP images work!
.\convert-images-webp.ps1 -DeleteOriginals
```

**This will:**

- Delete all original JPG, PNG, GIF, BMP, TIF files
- Keep only the WebP versions
- Free up ~1 GB of space

### Phase 5: Git Cleanup (REQUIRED FOR GITHUB)

Your Git repository is currently **8.18 GB** total:

- .git folder: 4.5 GB (Git history with old files)
- Images: 3.8 GB (will be reduced to ~2.8 GB after cleanup)
- Other files: minimal

**To get under GitHub's 5GB limit:**

```powershell
# Install git filter-repo (if not installed)
pip install git-filter-repo

# Clean large files from Git history
git filter-repo --strip-blobs-bigger-than 10M

# Force push to GitHub (if already pushed)
git push origin main --force
```

---

## Expected Final Results

### Before Migration:

- Total size: 8.18 GB
- Images: 3.8 GB (original formats)
- Git history: 4.5 GB
- ❌ Too large for GitHub

### After Migration:

- Total size: ~4-5 GB
- Images: ~2.5-2.8 GB (WebP format)
- Git history: ~2 GB (after cleanup)
- ✅ Acceptable for GitHub

**Space Savings:**

- Image conversion: ~1 GB saved
- Git history cleanup: ~2.5 GB saved
- **Total savings: ~3.5 GB**

---

## Monitor Progress

### Check Conversion Status

```powershell
# View conversion log (after backup completes)
Get-Content .\webp-conversion-log.txt -Tail 20

# Check backup progress
if (Test-Path ".\Images_Backup_*") {
    Get-ChildItem ".\Images_Backup_*" -Recurse -File |
    Measure-Object -Property Length -Sum |
    Select-Object @{Name='Size_GB';Expression={[math]::Round($_.Sum/1GB,2)}}
}

# Count converted WebP files
(Get-ChildItem .\Images -Recurse -Filter *.webp).Count
```

### Check HTML Update Status

```powershell
# View HTML update log
Get-Content .\html-update-log.txt
```

---

## Backup Locations

All backups are created automatically:

- **Images**: `Images_Backup_[timestamp]`
- **HTML/CSS**: `HTML_Backup_[timestamp]`

To restore from backup:

```powershell
# Restore images
Copy-Item ".\Images_Backup_20260124_231640\*" ".\Images\" -Recurse -Force

# Restore HTML/CSS
Copy-Item ".\HTML_Backup_[timestamp]\*" ".\" -Recurse -Force
```

---

## Troubleshooting

### Conversion Failed or Stopped

```powershell
# Check what happened
Get-Content .\webp-conversion-log.txt

# Resume conversion (skips already converted files)
.\convert-images-webp.ps1
```

### Some Images Not Loading After Update

```powershell
# Find images that weren't converted
$originals = Get-ChildItem .\Images -Recurse -Include *.jpg,*.png,*.gif
$webps = Get-ChildItem .\Images -Recurse -Filter *.webp

# Convert remaining images
$originals | ForEach-Object {
    $webpPath = [System.IO.Path]::ChangeExtension($_.FullName, '.webp')
    if (-not (Test-Path $webpPath)) {
        Write-Host "Missing: $($_.Name)"
    }
}
```

### Need to Revert Everything

```powershell
# Restore from backups
Copy-Item ".\Images_Backup_[timestamp]\*" ".\Images\" -Recurse -Force
Copy-Item ".\HTML_Backup_[timestamp]\*" ".\" -Recurse -Force

# Delete WebP files if needed
Get-ChildItem .\Images -Recurse -Filter *.webp | Remove-Item
```

---

## Next Steps

1. ⏳ **Wait for conversion to complete** (check terminal)
2. ⏳ **Run HTML updater in dry-run mode**
3. ⏳ **Apply HTML updates**
4. ⏳ **Test website thoroughly**
5. ⏳ **Delete originals** (optional, saves ~1 GB)
6. ⏳ **Clean Git history** (required to get under 5 GB)
7. ⏳ **Push to GitHub**

---

## Files Created

- `convert-images-webp.ps1` - Image converter
- `update-html-to-webp.ps1` - HTML/CSS updater
- `WEBP_CONVERSION_GUIDE.md` - Image conversion guide
- `HTML_UPDATE_GUIDE.md` - HTML update guide
- `COMPLETE_WORKFLOW.md` - This file
- `webp-conversion-log.txt` - Conversion log (created during run)
- `html-update-log.txt` - HTML update log (created during run)

## Support

All scripts have built-in help and safety features:

- Automatic backups
- Dry-run modes
- Detailed logging
- Error handling

# Image Gallery Guide for All Pages

## Overview
Every page on your Kiah website now supports **clickable image galleries** with comments, navigation, and responsive design. The lightbox system is already loaded on all pages.

---

## Quick Start: Adding Images to Any Page

### Step 1: Find or Create a Gallery Section
All pages have a `<div class="gallery-grid">` container ready for images. Look for it in your HTML:

```html
<div class="gallery-grid">
    <!-- Add images here -->
</div>
```

If a page doesn't have one, add this snippet where you want images:

```html
<div class="gallery-grid">
    <!-- Add images here with data-gallery="page-name" -->
</div>
```

### Step 2: Add Images with Lightbox Attributes

```html
<img src="Images/path/to/image.jpg" 
     alt="Short description" 
     data-gallery="gallery-name" 
     data-caption="Your detailed comment about this image"
     width="200" 
     height="150">
```

---

## Complete Examples by Page Type

### 🏠 Homepage (index.html)
```html
<div class="gallery-grid">
    <img src="Images/Antigua/Nelsons/Antigua1.jpg" 
         alt="KIAH at anchor" 
         data-gallery="home" 
         data-caption="Our beautiful KIAH anchored in Antigua" 
         width="200" height="150">
    
    <img src="Images/Antigua/Nelsons/Antigua10.jpg" 
         alt="Sunset view" 
         data-gallery="home" 
         data-caption="Sunset over the Caribbean" 
         width="200" height="150">
</div>
```

### 🧭 Place Pages (place-*.html)
Each place page already has a gallery-grid. Example for `place-azores.html`:

```html
<div class="gallery-grid">
    <!-- Azores Images -->
    <img src="Images/Azores/Fial/Horta/Azores2.jpg" 
         alt="Horta Marina" 
         data-gallery="azores" 
         data-caption="Beautiful Horta Marina with colorful buildings" 
         width="200" height="150">
    
    <img src="Images/Azores/Flores/Flores2.JPG" 
         alt="Flores island" 
         data-gallery="azores" 
         data-caption="Stunning cliffs of Flores island" 
         width="200" height="150">
    
    <img src="Images/Azores/Terceira/Angra/Angra (1).JPG" 
         alt="Angra harbor" 
         data-gallery="azores" 
         data-caption="Historic harbor of Angra" 
         width="200" height="150">
</div>
```

### 👥 Friends Page (friends.html)
Already populated with Jan & Max and Jim & Sharon galleries. Add more:

```html
<h2>New Friends Gallery</h2>
<div class="gallery-grid">
    <img src="Images/Friends/NewFriends/photo1.jpg" 
         alt="New friends" 
         data-gallery="new-friends" 
         data-caption="Meeting wonderful people in [Location]" 
         width="200" height="150">
    
    <img src="Images/Friends/NewFriends/photo2.jpg" 
         alt="Group photo" 
         data-gallery="new-friends" 
         data-caption="Great times with our sailing friends" 
         width="200" height="150">
</div>
```

### 🦅 Eagle Page (eagle.html)
Already has gallery-grid ready:

```html
<div class="gallery-grid">
    <img src="Images/Eagle/The Lads/01 Alan & Tex on Flag Deck.jpg" 
         alt="The lads on deck" 
         data-gallery="eagle" 
         data-caption="Alan and Tex on the Flag Deck" 
         width="200" height="150">
    
    <img src="Images/Eagle/The Lads/another-photo.jpg" 
         alt="HMS Eagle crew" 
         data-gallery="eagle" 
         data-caption="Our time aboard the magnificent HMS Eagle" 
         width="200" height="150">
</div>
```

### 🛥️ Route Pages (routes-*.html)
```html
<div class="gallery-grid">
    <!-- Mediterranean highlights -->
    <img src="Images/Atlantic/Atlantic (3).jpg" 
         alt="Mediterranean sunset" 
         data-gallery="mediterranean-route" 
         data-caption="Sailing through the beautiful Mediterranean" 
         width="200" height="150">
    
    <img src="Images/Azores/Fial/Horta/Horta1.JPG" 
         alt="Horta welcome" 
         data-gallery="mediterranean-route" 
         data-caption="Arriving at our first Mediterranean stop" 
         width="200" height="150">
</div>
```

### ⛳ Toddington Page (toddington.html)
Already has gallery-grid:

```html
<div class="gallery-grid">
    <img src="Images/Round Table/photo1.jpg" 
         alt="Round Table event" 
         data-gallery="toddington" 
         data-caption="Toddington Round Table gathering" 
         width="200" height="150">
    
    <img src="Images/Round Table/photo2.jpg" 
         alt="Community event" 
         data-gallery="toddington" 
         data-caption="Supporting our local community" 
         width="200" height="150">
</div>
```

---

## Attribute Reference

| Attribute | Required | Purpose | Example |
|-----------|----------|---------|---------|
| `src` | ✅ Yes | Image file path | `src="Images/Azores/photo.jpg"` |
| `alt` | ✅ Yes | Accessibility text | `alt="Harbor view"` |
| `data-gallery` | ✅ Yes | Gallery grouping | `data-gallery="azores"` |
| `data-caption` | ✅ Yes | Comment/description | `data-caption="Beautiful sunset"` |
| `width` | ⭕ Optional | Image display width | `width="200"` |
| `height` | ⭕ Optional | Image display height | `height="150"` |

---

## Gallery Naming Convention

Use consistent, descriptive names for `data-gallery`:

| Page Type | Gallery Name | Example |
|-----------|--------------|---------|
| Homepage | `home` | `data-gallery="home"` |
| Place pages | place name (lowercase) | `data-gallery="azores"` `data-gallery="malta"` |
| Routes | route name | `data-gallery="mediterranean-route"` |
| Friends | friend name | `data-gallery="jan-max"` `data-gallery="jim-sharon"` |
| Special pages | page name | `data-gallery="eagle"` `data-gallery="toddington"` |

---

## User Features (What Visitors Can Do)

✅ **Click** any image to open in fullscreen lightbox  
✅ **Navigate** with Previous/Next buttons or arrow keys (← →)  
✅ **Close** with X button, ESC key, or click background  
✅ **Read** image captions/comments displayed below each image  
✅ **See** image position counter (e.g., "3 of 12")  
✅ **Add comments** directly in the lightbox (saved in their browser)  
✅ **Works on** desktop, tablet, and mobile devices  
✅ **Keyboard accessible** for accessibility features  

---

## Lightbox Controls

### Mouse
- **Click image** → Opens lightbox
- **Click X button** → Closes
- **Click ❮ or ❯** → Previous/Next image
- **Click dark background** → Closes

### Keyboard
- **← Arrow Key** → Previous image
- **→ Arrow Key** → Next image
- **ESC Key** → Close lightbox

---

## Tips for Best Results

### Image Size & Quality
- **Recommended dimensions**: 200-400px wide, 150-300px tall
- **File format**: JPG (best for photos), PNG (for graphics)
- **Quality**: Use high-quality originals; they'll resize automatically
- **File size**: Keep under 2MB per image for faster loading

### Captions
- **Be descriptive**: "Sunset in Horta harbor" rather than "Beach"
- **Include context**: Location, date, people, or event
- **Personal touch**: Share your feelings: "Beautiful moment with Jan & Max"
- **Keep it reasonable**: 2-3 sentences max for readability

### Gallery Organization
- **One gallery per location/event**: Don't mix Mediterranean and Atlantic
- **Consistent naming**: Use lowercase, hyphens for multi-word names
- **Logical order**: Arrange images chronologically or by importance
- **Title it**: Add an `<h2>` above each gallery group

---

## Example: Complete Page with Multiple Galleries

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Places I've Been</title>
    <link rel="stylesheet" href="css/global.css">
    <link rel="stylesheet" href="css/routes.css">
    <script src="js/global.js" defer></script>
    <script src="js/lightbox.js" defer></script>
</head>
<body>
    <div id="header"></div>

    <h1>Our Mediterranean Journey</h1>
    
    <!-- Gallery 1: Gibraltar -->
    <h2>Gibraltar - Gateway to the Mediterranean</h2>
    <div class="gallery-grid">
        <img src="Images/Gibraltar/rock.jpg" alt="The Rock" 
             data-gallery="gibraltar" data-caption="The iconic Rock of Gibraltar" 
             width="200" height="150">
        <img src="Images/Gibraltar/harbor.jpg" alt="Harbor" 
             data-gallery="gibraltar" data-caption="Gibraltar's bustling harbor" 
             width="200" height="150">
    </div>

    <!-- Gallery 2: Malta -->
    <h2>Malta - Island Paradise</h2>
    <div class="gallery-grid">
        <img src="Images/Malta/harbor.jpg" alt="Valletta" 
             data-gallery="malta" data-caption="Beautiful harbor of Valletta" 
             width="200" height="150">
        <img src="Images/Malta/blue-lagoon.jpg" alt="Comino" 
             data-gallery="malta" data-caption="The famous Blue Lagoon" 
             width="200" height="150">
    </div>

    <div id="footer"></div>
</body>
</html>
```

---

## Troubleshooting

**Images not clickable?**
- Verify `data-gallery` attribute is present
- Check that `js/lightbox.js` is loaded in `<head>`

**Comments not saving?**
- Comments are saved in browser storage (not online)
- Different browsers = different stored comments
- Clearing browser data will erase comments

**Images not displaying?**
- Check `src` path is correct (use forward slashes: `Images/path/image.jpg`)
- Verify image file exists in the specified folder
- Check file extension matches (`.jpg`, `.png`, etc.)

**Captions not showing?**
- Ensure `data-caption` attribute is present
- Check caption text is between quotes

---

## Summary

✨ **Every page is ready for images!** Just add `<img>` tags with the four required attributes:
1. `src` - where the image is
2. `alt` - accessibility text
3. `data-gallery` - gallery grouping name
4. `data-caption` - your comment/description

That's all you need. The lightbox handles the rest! 🎉

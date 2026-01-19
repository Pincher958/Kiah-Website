# Lightbox Gallery Implementation Guide

## Overview
Your website now has a fully functional Lightbox gallery system that allows visitors to click on images to view them in a modal overlay with navigation controls.

## Features
- ✅ Click images to open in fullscreen lightbox
- ✅ Next/Previous buttons for gallery navigation
- ✅ Keyboard navigation (arrow keys, ESC to close)
- ✅ Large, readable comment/caption fonts (1.5rem)
- ✅ Image counter showing current position (e.g., "2 / 15")
- ✅ Smooth animations and hover effects
- ✅ Mobile responsive
- ✅ Prevents page scrolling when lightbox is open

## How to Use

### Adding Images to a Gallery

To make an image clickable and part of a lightbox gallery, add these attributes to your `<img>` tags:

```html
<img src="path/to/image.jpg" 
     alt="Image description" 
     data-gallery="gallery-name" 
     data-caption="Your comment or description here"
     width="200" 
     height="150">
```

### Attribute Explanations

| Attribute | Purpose | Example |
|-----------|---------|---------|
| `data-gallery` | Groups images into galleries | `data-gallery="jan-max"` |
| `data-caption` | Large text shown below image | `data-caption="Jan & Max on their yacht"` |
| `alt` | Accessibility text (also used if no caption) | `alt="Friends"` |

### Example: Multiple Galleries

```html
<!-- Gallery 1: Jan & Max photos -->
<img src="Images/Friends/Jan&Max/photo1.jpg" 
     data-gallery="jan-max" 
     data-caption="Jan & Max at dinner">

<img src="Images/Friends/Jan&Max/photo2.jpg" 
     data-gallery="jan-max" 
     data-caption="Sailing with Jan & Max">

<!-- Gallery 2: Jim & Sharon photos -->
<img src="Images/Friends/Jim&Sharon/photo1.jpg" 
     data-gallery="jim-sharon" 
     data-caption="Jim & Sharon with their children">

<img src="Images/Friends/Jim&Sharon/photo2.jpg" 
     data-gallery="jim-sharon" 
     data-caption="Happy moments on Wendreda">
```

Each gallery is independent - users navigate within galleries but can't switch between them via the Next/Previous buttons.

## Controls

### Mouse
- **Click image**: Opens lightbox
- **Click X button**: Closes lightbox
- **Click < or > buttons**: Previous/Next image
- **Click dark background**: Closes lightbox

### Keyboard
- **← Arrow**: Previous image
- **→ Arrow**: Next image
- **ESC**: Close lightbox

## Customization

### Change Caption Font Size
Edit `css/global.css` and find `.lightbox-caption`:
```css
.lightbox-caption {
	font-size: 1.5rem;  /* Change this value (1.2rem to 2rem recommended) */
	line-height: 1.6;
	margin-bottom: 10px;
	word-wrap: break-word;
	text-align: center;
}
```

### Change Overlay Darkness
Find `.lightbox-overlay` in `css/global.css`:
```css
.lightbox-overlay {
	background: rgba(0, 0, 0, 0.9);  /* Change 0.9 to 0.7 for lighter or 1 for darker */
}
```

### Change Image Max Size
Find `.lightbox-image` in `css/global.css`:
```css
.lightbox-image {
	max-width: 85vw;      /* Width percentage of viewport */
	max-height: 70vh;     /* Height percentage of viewport */
}
```

## Files Modified/Created

- ✅ `js/lightbox.js` - New file with gallery logic
- ✅ `css/global.css` - Added lightbox styling
- ✅ `index.html` - Added lightbox.js script
- ✅ `friends.html` - Added lightbox.js script and data-gallery attributes to images
- ✅ `routes.html` - Added lightbox.js script
- ✅ `global.html` - Added lightbox.js script

## Tips

1. **Gallery Names**: Use descriptive names like `"jan-max"`, `"malta-trip"`, `"eagle-ship"`, etc.

2. **Image Quality**: Use good quality photos for best appearance when enlarged

3. **Caption Text**: Keep captions concise but descriptive (they appear in large 1.5rem font)

4. **Mobile Friendly**: The lightbox automatically adjusts for mobile screens

5. **Adding More Pages**: Simply include the lightbox script and add `data-gallery` attributes to any images

## Example: Updating All Pages with Images

For each page that has images, follow this checklist:

- [ ] Add `<script src="js/lightbox.js" defer></script>` in the `<head>` section
- [ ] Add `data-gallery="gallery-name"` to each `<img>` tag
- [ ] Add `data-caption="Your description"` to each `<img>` tag
- [ ] Test by clicking an image to open the lightbox

That's it! The Lightbox will handle the rest automatically.

# Individual CSS Stylesheets Guide

## Overview

Each route page and place page now has its own individual CSS stylesheet that controls the background image. This allows you to customize the background for each page independently.

## CSS Files Created

### Route Pages (3 files):

- `css/routes-uk-med.css` - UK to the Mediterranean route page
- `css/routes-mediterranean.css` - The Mediterranean route page
- `css/routes-atlantic.css` - The Atlantic route page

### Place Pages (9 files):

**UK to Mediterranean:**

- `css/place-dover.css`
- `css/place-portsmouth.css`
- `css/place-plymouth.css`
- `css/place-falmouth.css`
- `css/place-brest.css`
- `css/place-concarneau.css`

**Mediterranean:**

- `css/place-almerimar.css`
- `css/place-gibraltar.css`
- `css/place-malta.css`

**Atlantic:**

- `css/place-canary-islands.css`
- `css/place-azores.css`
- `css/place-trinidad-tobago.css`

## How to Change Background Images

Each CSS file contains a simple background-image property. To change the background:

1. Open the CSS file for the page you want to customize
2. Update the `url()` path to point to your desired image

### Example:

In `css/place-dover.css`:

```css
/* Dover Place Page */
body.routes-page {
	background: url("../Images/backgrounds/dover.jpg") no-repeat center center
		fixed;
	background-size: cover;
}
```

Change it to:

```css
body.routes-page {
	background: url("../Images/Dover/my-dover-photo.jpg") no-repeat center center
		fixed;
	background-size: cover;
}
```

## Image Path Guidelines

- Use relative paths starting with `../` to go up from the `css/` folder
- Common image folders available:
  - `../Images/backgrounds/` - for background images
  - `../Images/Dover/`, `../Images/Brest/`, etc. - location-specific folders
  - `../Images/Almerimar/`, `../Images/Malta/`, etc. - Mediterranean locations
  - `../Images/Azores/`, `../Images/Trinidad\ &\ Tobago/`, etc. - Atlantic locations

## Adding New Places

When adding a new place:

1. Create a new place HTML file (copy from an existing one)
2. Create a corresponding CSS file: `css/place-placename.css`
3. Link it in the HTML: `<link rel="stylesheet" href="css/place-placename.css">`
4. Update the background image URL in the CSS

## File Format

Each CSS file follows this simple template:

```css
/* [Page Name] */
body.routes-page {
	background: url("[YOUR-IMAGE-PATH]") no-repeat center center fixed;
	background-size: cover;
}
```

The `no-repeat center center fixed` settings ensure the image:

- Appears only once (no-repeat)
- Is centered both horizontally and vertically
- Stays fixed while page content scrolls
- Covers the entire background

## Tips

- Use high-quality images (at least 1920x1080px recommended)
- Ensure images aren't too dark so content remains readable
- Test on different screen sizes to ensure the image looks good
- Consider using complementary images for related locations

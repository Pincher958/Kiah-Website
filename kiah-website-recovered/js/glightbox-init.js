// GLightbox Gallery System Initialization
// Initialize GLightbox for all galleries on the page

document.addEventListener("DOMContentLoaded", function () {
	// First, wrap all gallery images in anchor tags
	const galleryImages = document.querySelectorAll("img[data-gallery]");
	galleryImages.forEach((img) => {
		// Wrap images in anchor tags if not already wrapped
		if (img.parentElement.tagName !== "A") {
			const wrapper = document.createElement("a");
			wrapper.href = img.src;
			wrapper.classList.add("glightbox");
			wrapper.setAttribute("data-gallery", img.getAttribute("data-gallery"));

			// Copy alt attribute to data-title for captions
			if (img.alt) {
				wrapper.setAttribute("data-title", img.alt);
			}

			// Copy rotate-90 class to wrapper for GLightbox to detect
			if (img.classList.contains("rotate-90")) {
				wrapper.setAttribute("data-rotate", "90");
			}

			img.parentNode.insertBefore(wrapper, img);
			wrapper.appendChild(img);
		}
	});

	// Initialize GLightbox after wrapping images
	const lightbox = GLightbox({
		touchNavigation: true,
		loop: true,
		autoplayVideos: true,
		closeButton: true,
		zoomable: true,
		draggable: true,
		dragToleranceX: 100,
		dragToleranceY: 50,
		preload: true,
		selector: "a.glightbox",
		skin: "clean",
		keyboardNavigation: true,
		onSlideLoad: function (slide) {
			// Apply rotation to images that have data-rotate attribute
			if (
				slide.slideConfig.sourceNode &&
				slide.slideConfig.sourceNode.getAttribute("data-rotate") === "90"
			) {
				const lightboxImg = slide.slideNode.querySelector("img");
				if (lightboxImg) {
					lightboxImg.classList.add("rotate-90");
				}
			}
		},
		plyr: {
			css: "https://cdn.plyr.io/3.6.8/plyr.css",
			js: "https://cdn.plyr.io/3.6.8/plyr.js",
			config: {
				ratio: "16:9",
				youtube: {
					noCookie: true,
					rel: 0,
					showinfo: 0,
					iv_load_policy: 3,
				},
				vimeo: {
					byline: false,
					portrait: false,
					title: false,
					transparent: false,
				},
			},
		},
	});
});

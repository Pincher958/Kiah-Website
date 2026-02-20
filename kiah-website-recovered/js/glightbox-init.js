// GLightbox Gallery System Initialization
// Initialize GLightbox for all galleries on the page

document.addEventListener("DOMContentLoaded", function () {
	// First, wrap all gallery images in anchor tags and add visible captions
	const galleryImages = document.querySelectorAll("img[data-gallery]");
	galleryImages.forEach((img) => {
		let anchor = img.parentElement;
		const grid = img.closest(".gallery-grid");
		const defaultCaption = grid
			? grid.getAttribute("data-default-caption")
			: "";
		const rawCaption = img.getAttribute("data-caption") || img.alt || "";
		const trimmedCaption = rawCaption.trim();
		const useDefaultCaption =
			defaultCaption && (!trimmedCaption || /^DSC/i.test(trimmedCaption));
		const finalCaption = useDefaultCaption ? defaultCaption : trimmedCaption;

		// Wrap images in anchor tags if not already wrapped
		if (anchor.tagName !== "A") {
			const wrapper = document.createElement("a");
			let fullSrc = img.getAttribute("data-full") || img.src;
			if (!img.getAttribute("data-full") && fullSrc.includes("_thumb")) {
				fullSrc = fullSrc.replace("_thumb", "");
			}
			wrapper.href = fullSrc;
			wrapper.classList.add("glightbox");
			wrapper.setAttribute("data-gallery", img.getAttribute("data-gallery"));

			// Prefer data-caption for GLightbox caption, fall back to alt
			if (finalCaption) {
				wrapper.setAttribute("data-title", finalCaption);
			}

			// Copy rotate-90 class to wrapper for GLightbox to detect
			if (img.classList.contains("rotate-90")) {
				wrapper.setAttribute("data-rotate", "90");
			}

			img.parentNode.insertBefore(wrapper, img);
			wrapper.appendChild(img);
			anchor = wrapper;
		} else {
			// Ensure GLightbox metadata is applied even when already wrapped
			if (!anchor.classList.contains("glightbox")) {
				anchor.classList.add("glightbox");
			}
			if (!anchor.getAttribute("data-gallery")) {
				anchor.setAttribute("data-gallery", img.getAttribute("data-gallery"));
			}
			if (finalCaption && !anchor.getAttribute("data-title")) {
				anchor.setAttribute("data-title", finalCaption);
			}
			if (
				img.classList.contains("rotate-90") &&
				!anchor.getAttribute("data-rotate")
			) {
				anchor.setAttribute("data-rotate", "90");
			}
		}

		// Wrap anchor in a gallery item container for captions
		let container = anchor.parentElement;
		if (!container.classList.contains("gallery-item")) {
			const item = document.createElement("div");
			item.classList.add("gallery-item");
			anchor.parentNode.insertBefore(item, anchor);
			item.appendChild(anchor);
			container = item;
		}

		// Caption display disabled - captions only shown in lightbox, not below thumbnails
		// if (finalCaption && !container.querySelector(".gallery-caption")) {
		// 	const captionEl = document.createElement("p");
		// 	captionEl.classList.add("gallery-caption");
		// 	captionEl.textContent = finalCaption;
		// 	container.appendChild(captionEl);
		// }
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

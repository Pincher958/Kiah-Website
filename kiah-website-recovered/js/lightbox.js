// Lightbox Gallery System
// Allows image galleries with next, previous, and close functionality
// Includes comment/caption display for each image

document.addEventListener("DOMContentLoaded", function () {
	initializeLightbox();
});

function initializeLightbox() {
	// Create lightbox HTML structure if it doesn't exist
	if (!document.getElementById("lightbox-overlay")) {
		createLightboxHTML();
	}

	// Add click handlers to all images with data-gallery attribute
	const galleryImages = document.querySelectorAll("img[data-gallery]");
	galleryImages.forEach((img) => {
		img.style.cursor = "pointer";
		img.addEventListener("click", function (e) {
			openLightbox(this);
		});
	});

	// Keyboard navigation
	document.addEventListener("keydown", function (e) {
		const overlay = document.getElementById("lightbox-overlay");
		if (overlay && overlay.classList.contains("active")) {
			if (e.key === "ArrowLeft") showPrevious();
			if (e.key === "ArrowRight") showNext();
			if (e.key === "Escape") closeLightbox();
		}
	});
}

function createLightboxHTML() {
	const lightboxHTML = `
        <div id="lightbox-overlay" class="lightbox-overlay">
            <div class="lightbox-container">
                <button class="lightbox-close" onclick="closeLightbox()" title="Close (ESC)">✕</button>
                <button class="lightbox-prev" onclick="showPrevious()" title="Previous image (←)">❮</button>
                <img id="lightbox-image" src="" alt="" class="lightbox-image">
                <button class="lightbox-next" onclick="showNext()" title="Next image (→)">❯</button>
                <div class="lightbox-caption-container">
                    <p id="lightbox-caption" class="lightbox-caption"></p>
                    <p id="lightbox-counter" class="lightbox-counter"></p>
                </div>
                <div class="lightbox-comments">
                    <textarea id="lightbox-comments" class="lightbox-comment-box" placeholder="Add your comments about this image..."></textarea>
                    <button onclick="saveImageComment()" class="lightbox-save-btn">Save Comment</button>
                </div>
            </div>
        </div>
    `;

	const body = document.body;
	body.insertAdjacentHTML("beforeend", lightboxHTML);
}

let currentGallery = null;
let currentImageIndex = 0;
let galleryImages = [];
let imageComments = {}; // Store comments per image

function openLightbox(imgElement) {
	const gallery = imgElement.getAttribute("data-gallery");

	// Get all images in this gallery
	galleryImages = Array.from(
		document.querySelectorAll(`img[data-gallery="${gallery}"]`),
	);
	currentImageIndex = galleryImages.indexOf(imgElement);
	currentGallery = gallery;

	// Load comments from localStorage
	loadImageComments();

	showCurrentImage();

	const overlay = document.getElementById("lightbox-overlay");
	overlay.classList.add("active");
	document.body.style.overflow = "hidden"; // Prevent page scrolling
}

function showCurrentImage() {
	if (galleryImages.length === 0) return;

	const img = galleryImages[currentImageIndex];
	const lightboxImg = document.getElementById("lightbox-image");
	const captionEl = document.getElementById("lightbox-caption");
	const counterEl = document.getElementById("lightbox-counter");
	const commentsEl = document.getElementById("lightbox-comments");

	// Set image and caption
	// Use data-full for full-size image if available (for thumbnails), otherwise use src
	const fullSizeImage = img.getAttribute("data-full") || img.src;
	lightboxImg.src = fullSizeImage;
	lightboxImg.alt = img.alt;

	const caption =
		img.getAttribute("data-caption") || img.alt || "No description";
	captionEl.textContent = caption;

	// Show counter
	counterEl.textContent = `${currentImageIndex + 1} / ${galleryImages.length}`;

	// Load or initialize comments for this image
	const imgKey = `${currentGallery}_${currentImageIndex}`;
	commentsEl.value = imageComments[imgKey] || "";
	commentsEl.dataset.key = imgKey;

	// Update button states
	updateButtonStates();
}

function updateButtonStates() {
	const prevBtn = document.querySelector(".lightbox-prev");
	const nextBtn = document.querySelector(".lightbox-next");

	if (currentImageIndex === 0) {
		prevBtn.style.opacity = "0.5";
		prevBtn.style.pointerEvents = "none";
	} else {
		prevBtn.style.opacity = "1";
		prevBtn.style.pointerEvents = "auto";
	}

	if (currentImageIndex === galleryImages.length - 1) {
		nextBtn.style.opacity = "0.5";
		nextBtn.style.pointerEvents = "none";
	} else {
		nextBtn.style.opacity = "1";
		nextBtn.style.pointerEvents = "auto";
	}
}

function showNext() {
	if (currentImageIndex < galleryImages.length - 1) {
		currentImageIndex++;
		showCurrentImage();
	}
}

function showPrevious() {
	if (currentImageIndex > 0) {
		currentImageIndex--;
		showCurrentImage();
	}
}

function closeLightbox() {
	const overlay = document.getElementById("lightbox-overlay");
	overlay.classList.remove("active");
	document.body.style.overflow = "auto"; // Restore page scrolling
	galleryImages = [];
}

function saveImageComment() {
	const commentsEl = document.getElementById("lightbox-comments");
	const key = commentsEl.dataset.key;
	imageComments[key] = commentsEl.value;

	// Save to localStorage
	localStorage.setItem("kiahImageComments", JSON.stringify(imageComments));

	// Show confirmation
	const btn = document.querySelector(".lightbox-save-btn");
	const originalText = btn.textContent;
	btn.textContent = "Comment Saved!";
	setTimeout(() => {
		btn.textContent = originalText;
	}, 2000);
}

function loadImageComments() {
	const saved = localStorage.getItem("kiahImageComments");
	if (saved) {
		imageComments = JSON.parse(saved);
	}
}

// Close lightbox when clicking the close button
document.addEventListener("click", function (e) {
	const overlay = document.getElementById("lightbox-overlay");
	// Only close if the close button is clicked, not the overlay background
	if (overlay && e.target.classList.contains("lightbox-close")) {
		closeLightbox();
	}
});

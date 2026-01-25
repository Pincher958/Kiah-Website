// Global JavaScript for Kiah Website
// Load header and footer
function loadFromGlobal(elementId, callback) {
	fetch("global.html")
		.then((response) => response.text())
		.then((html) => {
			const temp = document.createElement("div");
			temp.innerHTML = html;
			// Extract the header or footer element from the fetched HTML
			let content;
			if (elementId === "header") {
				content = temp.querySelector("header");
			} else if (elementId === "footer") {
				content = temp.querySelector("footer");
			}
			if (content) {
				const target = document.getElementById(elementId);
				if (target) {
					target.innerHTML = content.innerHTML;
				}
			}
			if (callback) callback();
		})
		.catch((err) => console.error("Error loading global HTML:", err));
}

// Hamburger Menu Toggle
function setupHamburgerMenu() {
	const hamburger = document.getElementById("hamburger");
	const mainMenu = document.getElementById("main-menu");

	if (!hamburger || !mainMenu) {
		console.error("Hamburger or main menu not found");
		return;
	}

	// Simple toggle hamburger menu open/close
	hamburger.addEventListener("click", function () {
		mainMenu.classList.toggle("active");
		hamburger.classList.toggle("active");
	});
}

// Load header and footer when page loads
document.addEventListener("DOMContentLoaded", function () {
	loadFromGlobal("header", setupHamburgerMenu);
	loadFromGlobal("footer");
});

// Text box scroll behavior for home page
function setupTextBoxScroll() {
	const textBox = document.querySelector(".text-box-container");
	if (!textBox) return;

	const initialTop = textBox.offsetTop;

	window.addEventListener("scroll", function () {
		if (window.scrollY > initialTop) {
			textBox.classList.add("scrolled");
		} else {
			textBox.classList.remove("scrolled");
		}
	});
}

document.addEventListener("DOMContentLoaded", setupTextBoxScroll);

// Navigate to place function
function navigateToPlace(url) {
	if (url) {
		window.location.href = url;
	}
}

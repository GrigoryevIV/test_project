// ===== Theme Toggle =====
const themeToggle = document.getElementById('themeToggle');
const html = document.documentElement;

// Load saved theme or default to light
const savedTheme = localStorage.getItem('theme') || 'light';
html.setAttribute('data-theme', savedTheme);

themeToggle.addEventListener('click', () => {
    const currentTheme = html.getAttribute('data-theme');
    const newTheme = currentTheme === 'light' ? 'dark' : 'light';

    html.setAttribute('data-theme', newTheme);
    localStorage.setItem('theme', newTheme);
});

// ===== Navigation =====
const navLinks = document.querySelectorAll('.nav-link');
const sections = document.querySelectorAll('.content-section');

// Function to show section
function showSection(sectionId) {
    // Hide all sections
    sections.forEach(section => {
        section.classList.remove('active');
    });

    // Remove active class from all nav links
    navLinks.forEach(link => {
        link.classList.remove('active');
    });

    // Show target section
    const targetSection = document.getElementById(sectionId);
    if (targetSection) {
        targetSection.classList.add('active');
    }

    // Add active class to clicked nav link
    const activeLink = document.querySelector(`a[href="#${sectionId}"]`);
    if (activeLink && activeLink.classList.contains('nav-link')) {
        activeLink.classList.add('active');
    }

    // Scroll to top
    window.scrollTo({ top: 0, behavior: 'smooth' });
}

// Handle navigation clicks
navLinks.forEach(link => {
    link.addEventListener('click', (e) => {
        e.preventDefault();
        const sectionId = link.getAttribute('href').substring(1);
        showSection(sectionId);

        // Update URL without page reload
        history.pushState(null, '', `#${sectionId}`);
    });
});

// Handle card clicks
document.querySelectorAll('.card-link').forEach(link => {
    link.addEventListener('click', (e) => {
        e.preventDefault();
        const sectionId = link.getAttribute('href').substring(1);
        showSection(sectionId);
        history.pushState(null, '', `#${sectionId}`);
    });
});

// Handle browser back/forward
window.addEventListener('popstate', () => {
    const hash = window.location.hash.substring(1) || 'home';
    showSection(hash);
});

// Show initial section based on URL hash
window.addEventListener('DOMContentLoaded', () => {
    const hash = window.location.hash.substring(1) || 'home';
    showSection(hash);
});

// ===== Search Functionality =====
const searchInput = document.getElementById('searchInput');
let searchTimeout;

searchInput.addEventListener('input', (e) => {
    clearTimeout(searchTimeout);
    const query = e.target.value.toLowerCase().trim();

    if (query.length < 2) {
        clearHighlights();
        return;
    }

    searchTimeout = setTimeout(() => {
        performSearch(query);
    }, 300);
});

function performSearch(query) {
    clearHighlights();

    if (!query) return;

    // Search through all sections
    sections.forEach(section => {
        const content = section.textContent.toLowerCase();
        if (content.includes(query)) {
            highlightText(section, query);
        }
    });
}

function highlightText(element, query) {
    const walker = document.createTreeWalker(
        element,
        NodeFilter.SHOW_TEXT,
        null,
        false
    );

    const nodesToReplace = [];
    let node;

    while (node = walker.nextNode()) {
        if (node.nodeValue.toLowerCase().includes(query)) {
            nodesToReplace.push(node);
        }
    }

    nodesToReplace.forEach(node => {
        const parent = node.parentNode;
        if (parent.tagName === 'SCRIPT' || parent.tagName === 'STYLE') return;

        const text = node.nodeValue;
        const regex = new RegExp(`(${query})`, 'gi');
        const parts = text.split(regex);

        const fragment = document.createDocumentFragment();
        parts.forEach(part => {
            if (part.toLowerCase() === query.toLowerCase()) {
                const mark = document.createElement('mark');
                mark.textContent = part;
                mark.style.background = '#fef08a';
                mark.style.color = '#000';
                mark.style.padding = '2px 4px';
                mark.style.borderRadius = '3px';
                fragment.appendChild(mark);
            } else {
                fragment.appendChild(document.createTextNode(part));
            }
        });

        parent.replaceChild(fragment, node);
    });
}

function clearHighlights() {
    document.querySelectorAll('mark').forEach(mark => {
        const parent = mark.parentNode;
        parent.replaceChild(document.createTextNode(mark.textContent), mark);
        parent.normalize();
    });
}

// ===== Code Block Copy Button =====
document.querySelectorAll('pre code').forEach((codeBlock) => {
    const pre = codeBlock.parentElement;
    const button = document.createElement('button');
    button.className = 'copy-button';
    button.textContent = 'Copy';
    button.style.cssText = `
        position: absolute;
        top: 8px;
        right: 8px;
        padding: 6px 12px;
        background: rgba(255, 255, 255, 0.1);
        border: 1px solid rgba(255, 255, 255, 0.2);
        border-radius: 6px;
        color: #fff;
        font-size: 12px;
        cursor: pointer;
        transition: all 0.2s;
    `;

    pre.style.position = 'relative';
    pre.appendChild(button);

    button.addEventListener('click', async () => {
        const code = codeBlock.textContent;
        try {
            await navigator.clipboard.writeText(code);
            button.textContent = 'Copied!';
            button.style.background = 'rgba(16, 185, 129, 0.3)';

            setTimeout(() => {
                button.textContent = 'Copy';
                button.style.background = 'rgba(255, 255, 255, 0.1)';
            }, 2000);
        } catch (err) {
            console.error('Failed to copy:', err);
            button.textContent = 'Error';
        }
    });

    button.addEventListener('mouseenter', () => {
        button.style.background = 'rgba(255, 255, 255, 0.2)';
    });

    button.addEventListener('mouseleave', () => {
        if (button.textContent === 'Copy') {
            button.style.background = 'rgba(255, 255, 255, 0.1)';
        }
    });
});

// ===== Syntax Highlighting =====
document.addEventListener('DOMContentLoaded', () => {
    if (typeof hljs !== 'undefined') {
        document.querySelectorAll('pre code').forEach((block) => {
            hljs.highlightElement(block);
        });
    }
});

// ===== Smooth Scroll for Anchor Links =====
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        const href = this.getAttribute('href');

        // Skip if it's a section navigation link (handled above)
        if (this.classList.contains('nav-link') || this.classList.contains('card-link')) {
            return;
        }

        // Handle in-page anchor links
        const targetId = href.substring(1);
        const targetElement = document.getElementById(targetId);

        if (targetElement && targetElement.tagName !== 'SECTION') {
            e.preventDefault();
            targetElement.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});

// ===== Active Section Highlighting on Scroll =====
let ticking = false;

window.addEventListener('scroll', () => {
    if (!ticking) {
        window.requestAnimationFrame(() => {
            updateActiveNavOnScroll();
            ticking = false;
        });
        ticking = true;
    }
});

function updateActiveNavOnScroll() {
    const scrollPosition = window.scrollY + 100;

    // Find which section is currently visible
    const activeSection = document.querySelector('.content-section.active');
    if (!activeSection) return;

    const headings = activeSection.querySelectorAll('h2[id], h3[id]');
    let currentHeading = null;

    headings.forEach(heading => {
        if (heading.offsetTop <= scrollPosition) {
            currentHeading = heading;
        }
    });

    // Update TOC if exists
    if (currentHeading) {
        const tocLinks = activeSection.querySelectorAll('.toc a');
        tocLinks.forEach(link => {
            link.style.fontWeight = 'normal';
            link.style.color = 'var(--text-secondary)';
        });

        const activeLink = activeSection.querySelector(`.toc a[href="#${currentHeading.id}"]`);
        if (activeLink) {
            activeLink.style.fontWeight = '600';
            activeLink.style.color = 'var(--accent-primary)';
        }
    }
}

// ===== Mobile Menu Toggle =====
const createMobileMenuButton = () => {
    if (window.innerWidth <= 768) {
        const menuButton = document.createElement('button');
        menuButton.id = 'mobileMenuToggle';
        menuButton.innerHTML = '☰';
        menuButton.style.cssText = `
            position: fixed;
            top: 20px;
            left: 20px;
            z-index: 1001;
            background: var(--bg-secondary);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            width: 48px;
            height: 48px;
            font-size: 24px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 4px 6px var(--shadow);
        `;

        document.body.appendChild(menuButton);

        const sidebar = document.querySelector('.sidebar');
        menuButton.addEventListener('click', () => {
            sidebar.classList.toggle('open');
        });

        // Close sidebar when clicking outside
        document.addEventListener('click', (e) => {
            if (!sidebar.contains(e.target) && e.target !== menuButton) {
                sidebar.classList.remove('open');
            }
        });
    }
};

// Create mobile menu on load and resize
window.addEventListener('DOMContentLoaded', createMobileMenuButton);
window.addEventListener('resize', () => {
    const existingButton = document.getElementById('mobileMenuToggle');
    if (window.innerWidth <= 768 && !existingButton) {
        createMobileMenuButton();
    } else if (window.innerWidth > 768 && existingButton) {
        existingButton.remove();
    }
});

// ===== Details/Summary Animation =====
document.querySelectorAll('details').forEach(details => {
    details.addEventListener('toggle', () => {
        if (details.open) {
            const summary = details.querySelector('summary');
            const content = Array.from(details.children).filter(el => el !== summary);
            content.forEach(el => {
                el.style.animation = 'fadeIn 0.3s ease-in-out';
            });
        }
    });
});

// ===== Keyboard Shortcuts =====
document.addEventListener('keydown', (e) => {
    // Ctrl/Cmd + K to focus search
    if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
        e.preventDefault();
        searchInput.focus();
    }

    // Escape to clear search
    if (e.key === 'Escape' && document.activeElement === searchInput) {
        searchInput.value = '';
        clearHighlights();
        searchInput.blur();
    }
});

console.log('🚀 QazTech Documentation loaded successfully!');

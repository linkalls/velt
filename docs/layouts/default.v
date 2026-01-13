module layouts

pub fn default(content string, title string, nav_html string) string {
	page_title := if title.len > 0 { '${title} - Velt' } else { 'Velt Docs' }
	return '
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${page_title}</title>
    <link rel="stylesheet" href="/assets/style.css">
    <script>
        // Check local storage or preference
        const savedTheme = localStorage.getItem("theme");
        if (savedTheme === "dark" || (!savedTheme && window.matchMedia("(prefers-color-scheme: dark)").matches)) {
            document.documentElement.classList.add("dark");
        } else {
            document.documentElement.classList.remove("dark");
        }
    </script>
</head>
<body>
    <div class="layout">
        <aside class="sidebar">
            <a href="/index.html" class="brand">
                <span class="brand-icon">🚀</span> Velt
            </a>
            <nav>
                ${nav_html}
            </nav>
        </aside>
        <div class="main-content">
            <header class="topbar">
                <button class="mobile-menu-toggle" aria-label="Toggle Menu">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 12h18M3 6h18M3 18h18"/></svg>
                </button>
                <div class="search-placeholder">Search documentation...</div>
                <div class="topbar-actions">
                    <div class="lang-switcher">
                        <button class="lang-btn" aria-label="Switch Language">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M2 12h20M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>
                            <span>EN</span>
                        </button>
                        <div class="lang-dropdown">
                            <a href="/docs.html" class="lang-option">🇬🇧 English</a>
                            <a href="/ja/docs.html" class="lang-option">🇯🇵 日本語</a>
                        </div>
                    </div>
                    <button id="theme-toggle" aria-label="Toggle Dark Mode">
                        <!-- Sun Icon -->
                        <svg class="sun-icon" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="5"/><path d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"/></svg>
                        <!-- Moon Icon -->
                        <svg class="moon-icon" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>
                    </button>
                </div>
            </header>
            <main class="content-area">
                ${content}
            </main>
            <footer>
                Powered by <a href="https://github.com/linkalls/velt">Velt</a>
            </footer>
        </div>
    </div>
    <script>
        const toggleBtn = document.getElementById("theme-toggle");
        toggleBtn.addEventListener("click", () => {
            document.documentElement.classList.toggle("dark");
            const isDark = document.documentElement.classList.contains("dark");
            localStorage.setItem("theme", isDark ? "dark" : "light");
        });

        // Mobile menu toggle
        const menuToggle = document.querySelector(".mobile-menu-toggle");
        const sidebar = document.querySelector(".sidebar");
        if (menuToggle) {
            menuToggle.addEventListener("click", () => {
                sidebar.classList.toggle("open");
            });
        }
    </script>
</body>
</html>
    '
}

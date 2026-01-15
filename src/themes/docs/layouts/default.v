module layouts

pub fn default(content string, title string, nav_html string, lang string, page_path string) string {
	page_title := if title.len > 0 { '${title} - Velt' } else { 'Velt Docs' }

	// Silence unused warnings
	_ = lang
	_ = page_path

	return '
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${page_title}</title>
    <link rel="stylesheet" href="/assets/style.css">
    <script>
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
            <div class="brand">Velt Docs</div>
            <nav>
                ${nav_html}
            </nav>
        </aside>
        <div class="main-content">
            <header class="topbar">
                <div class="search-placeholder">Search documentation...</div>
                <button id="theme-toggle" aria-label="Toggle Dark Mode">
                    <svg class="sun-icon" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="5"/><path d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"/></svg>
                    <svg class="moon-icon" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>
                </button>
            </header>
            <main class="content-area">
                ${content}
            </main>
            <footer>
                Powered by <a href="https://github.com/vlang/v">Velt</a>
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
    </script>
</body>
</html>
    '
}

module layouts

pub fn landing(content string, title string, nav_html string) string {
    _ = title   // unused but kept for API consistency
    _ = nav_html
    return '
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Velt - Static Site Generator</title>
    <link rel="stylesheet" href="assets/landing.css">
    <script>
        const savedTheme = localStorage.getItem("theme");
        if (savedTheme === "dark" || (!savedTheme && window.matchMedia("(prefers-color-scheme: dark)").matches)) {
            document.documentElement.classList.add("dark");
        }
    </script>
</head>
<body>
    <nav class="navbar">
        <a href="index.html" class="navbar-brand">
            <span>🚀</span> Velt
        </a>
        <div class="navbar-links">
            <a href="./docs.html">Docs</a>
            <a href="#features">Features</a>
            <a href="https://github.com">GitHub</a>
        </div>
        <div class="navbar-actions">
            <button id="theme-toggle" aria-label="Toggle theme">
                <svg class="sun-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="5"/><path d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"/></svg>
                <svg class="moon-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>
            </button>
        </div>
    </nav>
    
    ${content}
    
    <footer class="landing-footer">
        <p>Built with <a href="https://github.com/vlang/v">V</a> • Powered by <a href="https://github.com/linkalls/velt">Velt</a></p>
    </footer>
    
    <script>
        document.getElementById("theme-toggle").addEventListener("click", () => {
            document.documentElement.classList.toggle("dark");
            localStorage.setItem("theme", document.documentElement.classList.contains("dark") ? "dark" : "light");
        });
    </script>
</body>
</html>
    '
}

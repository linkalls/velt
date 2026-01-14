module layouts

pub fn post(content string, title string, date string, author string) string {
    return '
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${title} - Blog</title>
    <link rel="stylesheet" href="/assets/blog.css">
    <script>
        const savedTheme = localStorage.getItem("theme");
        if (savedTheme === "dark" || (!savedTheme && window.matchMedia("(prefers-color-scheme: dark)").matches)) {
            document.documentElement.classList.add("dark");
        }
    </script>
</head>
<body>
    <nav class="navbar">
        <a href="/" class="navbar-brand">📝 Blog</a>
        <div class="navbar-actions">
            <button id="theme-toggle" aria-label="Toggle theme">
                <svg class="sun-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="5"/><path d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"/></svg>
                <svg class="moon-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>
            </button>
        </div>
    </nav>

    <main class="blog-main">
        <article class="post">
            <header class="post-header">
                <h1 class="post-title">${title}</h1>
                <div class="post-meta">
                    <time>${date}</time>
                    <span class="author">by ${author}</span>
                </div>
            </header>
            <div class="post-content">
                ${content}
            </div>
        </article>
    </main>

    <footer class="blog-footer">
        <p>Powered by <a href="https://github.com/linkalls/velt">Velt</a></p>
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

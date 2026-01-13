module main

import os

// Embed scaffold files using v embed mechanism or just strings if small.
// For a robust tool, we might want to use `import embed`.
// But for this MVP, I'll write strings or read from `src/scaffold` if I can.
// Since I am running as a source tool, I can rely on relative paths for now, or embed them.
// V's `$embed_file` is good.

fn cmd_new(project_name string) ! {
    if os.exists(project_name) {
        println('Error: Directory ${project_name} already exists.')
        return
    }

    println('Creating new Velt project: ${project_name}...')

    os.mkdir(project_name) or { panic(err) }
    os.mkdir_all('${project_name}/components') or { panic(err) }
    os.mkdir_all('${project_name}/content') or { panic(err) }
    os.mkdir_all('${project_name}/layouts') or { panic(err) }
    os.mkdir_all('${project_name}/assets') or { panic(err) }

    // Create v.mod
    os.write_file('${project_name}/v.mod', "Module {
    name: '${project_name}'
    description: 'My Velt Documentation Site'
    version: '0.0.1'
    license: 'MIT'
    dependencies: []
}")!

    // Create config
    os.write_file('${project_name}/velt.config.v', "module main

pub struct Config {
pub:
    title string = 'My Docs'
}")!

    // Create default layout
    // We will populate this in the next step with the stylish layout
    os.write_file('${project_name}/layouts/default.v', get_default_layout_code())!

    // Create sample component
    os.write_file('${project_name}/components/Callout.v', get_callout_component_code())!

    // Create sample content
    os.write_file('${project_name}/content/index.vdx', get_index_vdx_code())!

    // Create CSS
    os.write_file('${project_name}/assets/style.css', get_default_css())!

    println('Done! Now run:\n  cd ${project_name}\n  velt dev')
}

fn get_default_layout_code() string {
    return "module layouts

pub fn default(content string) string {
    return '
<!DOCTYPE html>
<html lang=\"en\">
<head>
    <meta charset=\"UTF-8\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
    <title>Velt Docs</title>
    <link rel=\"stylesheet\" href=\"assets/style.css\">
    <script>
        // Check local storage or preference
        const savedTheme = localStorage.getItem(\"theme\");
        if (savedTheme === \"dark\" || (!savedTheme && window.matchMedia(\"(prefers-color-scheme: dark)\").matches)) {
            document.documentElement.classList.add(\"dark\");
        } else {
            document.documentElement.classList.remove(\"dark\");
        }
    </script>
</head>
<body>
    <div class=\"layout\">
        <aside class=\"sidebar\">
            <div class=\"brand\">Velt Docs</div>
            <nav>
                <a href=\"index.html\" class=\"active\">Introduction</a>
                <a href=\"#\">Getting Started</a>
                <a href=\"#\">Components</a>
            </nav>
        </aside>
        <div class=\"main-content\">
            <header class=\"topbar\">
                <div class=\"search-placeholder\">Search documentation...</div>
                <button id=\"theme-toggle\" aria-label=\"Toggle Dark Mode\">
                    <!-- Sun Icon -->
                    <svg class=\"sun-icon\" xmlns=\"http://www.w3.org/2000/svg\" width=\"20\" height=\"20\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><circle cx=\"12\" cy=\"12\" r=\"5\"/><path d=\"M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42\"/></svg>
                    <!-- Moon Icon -->
                    <svg class=\"moon-icon\" xmlns=\"http://www.w3.org/2000/svg\" width=\"20\" height=\"20\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z\"/></svg>
                </button>
            </header>
            <main class=\"content-area\">
                \${content}
            </main>
            <footer>
                Powered by <a href=\"https://github.com/vlang/v\">Velt</a>
            </footer>
        </div>
    </div>
    <script>
        const toggleBtn = document.getElementById(\"theme-toggle\");
        toggleBtn.addEventListener(\"click\", () => {
            document.documentElement.classList.toggle(\"dark\");
            const isDark = document.documentElement.classList.contains(\"dark\");
            localStorage.setItem(\"theme\", isDark ? \"dark\" : \"light\");
        });
    </script>
</body>
</html>
    '
}
"
}

fn get_callout_component_code() string {
    return "module components

pub struct Callout {
pub:
    type_ string = 'info'
    content string
}

pub fn (c Callout) render() string {
    return '
    <div class=\"callout callout-\${c.type_}\">
        \${c.content}
    </div>
    '
}
"
}

fn get_index_vdx_code() string {
    return "# Welcome to Velt

Velt is a **blazingly fast** static site generator powered by V.

<Callout type_=\"info\">
This is a V component running inside Markdown!
</Callout>

## Features

- Zero Runtime JS
- Type Safe Props
- Millisecond builds

<Callout type_=\"warning\">
**Note:** This is an experimental version.
</Callout>

## Getting Started

Edit `content/index.vdx` to see changes instantly.
"
}

fn get_default_css() string {
    return "/* Fumadocs-inspired simple theme */
:root {
    --bg-color: #09090b;
    --sidebar-bg: #101012; // slightly lighter than bg
    --text-color: #e4e4e7;
    --muted-color: #a1a1aa;
    --border-color: #27272a;
    --primary-color: #3b82f6;
    --accent-bg: #27272a;

    --font-sans: system-ui, -apple-system, sans-serif;
}

/* Light Mode Defaults */
:root {
   --bg-color: #ffffff;
   --sidebar-bg: #f4f4f5;
   --text-color: #18181b;
   --muted-color: #71717a;
   --border-color: #e4e4e7;
   --accent-bg: #f4f4f5;
}

/* Dark Mode Overrides */
html.dark {
    --bg-color: #09090b;
    --sidebar-bg: #101012;
    --text-color: #e4e4e7;
    --muted-color: #a1a1aa;
    --border-color: #27272a;
    --accent-bg: #27272a;
}

body {
    margin: 0;
    font-family: var(--font-sans);
    background-color: var(--bg-color);
    color: var(--text-color);
    line-height: 1.6;
    transition: background-color 0.3s, color 0.3s;
}

.layout {
    display: flex;
    min-height: 100vh;
}

/* Sidebar */
.sidebar {
    width: 260px;
    background-color: var(--sidebar-bg);
    border-right: 1px solid var(--border-color);
    display: flex;
    flex-direction: column;
    position: sticky;
    top: 0;
    height: 100vh;
}

.brand {
    padding: 1.5rem;
    font-weight: bold;
    font-size: 1.2rem;
    border-bottom: 1px solid var(--border-color);
}

.sidebar nav {
    padding: 1rem;
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
}

.sidebar a {
    color: var(--muted-color);
    text-decoration: none;
    padding: 0.5rem;
    border-radius: 6px;
    transition: all 0.2s;
}

.sidebar a:hover, .sidebar a.active {
    color: var(--text-color);
    background-color: var(--accent-bg);
}

/* Main Content */
.main-content {
    flex: 1;
    display: flex;
    flex-direction: column;
}

.topbar {
    height: 60px;
    border-bottom: 1px solid var(--border-color);
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 2rem;
    backdrop-filter: blur(10px);
}

.search-placeholder {
    color: var(--muted-color);
    font-size: 0.9rem;
    background: var(--accent-bg);
    padding: 0.4rem 1rem;
    border-radius: 999px;
    width: 200px;
}

#theme-toggle {
    background: none;
    border: none;
    color: var(--text-color);
    cursor: pointer;
    padding: 0.5rem;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
}

#theme-toggle:hover {
    background-color: var(--accent-bg);
}

/* Hide sun in light mode, show moon */
html:not(.dark) .sun-icon { display: none; }
html:not(.dark) .moon-icon { display: block; }

/* Hide moon in dark mode, show sun */
html.dark .sun-icon { display: block; }
html.dark .moon-icon { display: none; }

.content-area {
    flex: 1;
    max-width: 800px;
    margin: 0 auto;
    width: 100%;
    padding: 3rem 2rem;
}

/* Typography */
h1, h2, h3 {
    letter-spacing: -0.025em;
    margin-top: 2rem;
}

h1 { font-size: 2.5rem; font-weight: 800; margin-top: 0; }
h2 { font-size: 1.8rem; border-bottom: 1px solid var(--border-color); padding-bottom: 0.5rem; }

p { margin-bottom: 1.5rem; }

code {
    background: var(--accent-bg);
    padding: 0.2rem 0.4rem;
    border-radius: 4px;
    font-family: monospace;
    font-size: 0.9em;
}

/* Components */
.callout {
    padding: 1rem;
    border-radius: 8px;
    margin: 1.5rem 0;
    border-left: 4px solid var(--primary-color);
    background: rgba(59, 130, 246, 0.1);
}

.callout-warning {
    border-color: #eab308;
    background: rgba(234, 179, 8, 0.1);
}

footer {
    padding: 2rem;
    text-align: center;
    color: var(--muted-color);
    font-size: 0.9rem;
    border-top: 1px solid var(--border-color);
}
"
}

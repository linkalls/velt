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
    return "/* ═══════════════════════════════════════════════════════════════════
   Velt Premium Theme - Fumadocs Inspired
   A stunning documentation theme with glassmorphism & micro-animations
   ═══════════════════════════════════════════════════════════════════ */

@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap');

/* ─────────────────────────────────────────────────────────────────────
   CSS Variables - Light Mode (Default)
   ───────────────────────────────────────────────────────────────────── */
:root {
    /* Background & Surface */
    --bg-primary: #fafafa;
    --bg-secondary: #ffffff;
    --bg-tertiary: #f4f4f5;
    --bg-glass: rgba(255, 255, 255, 0.8);
    
    /* Text */
    --text-primary: #18181b;
    --text-secondary: #3f3f46;
    --text-muted: #71717a;
    --text-inverted: #fafafa;
    
    /* Borders */
    --border-subtle: rgba(0, 0, 0, 0.06);
    --border-default: #e4e4e7;
    --border-strong: #d4d4d8;
    
    /* Accents */
    --accent-primary: #6366f1;
    --accent-primary-hover: #4f46e5;
    --accent-primary-ghost: rgba(99, 102, 241, 0.1);
    --accent-secondary: #8b5cf6;
    --accent-gradient: linear-gradient(135deg, #6366f1 0%, #8b5cf6 50%, #a855f7 100%);
    
    /* Semantic Colors */
    --color-info: #3b82f6;
    --color-info-bg: rgba(59, 130, 246, 0.08);
    --color-info-border: rgba(59, 130, 246, 0.3);
    --color-success: #10b981;
    --color-success-bg: rgba(16, 185, 129, 0.08);
    --color-success-border: rgba(16, 185, 129, 0.3);
    --color-warning: #f59e0b;
    --color-warning-bg: rgba(245, 158, 11, 0.08);
    --color-warning-border: rgba(245, 158, 11, 0.3);
    --color-error: #ef4444;
    --color-error-bg: rgba(239, 68, 68, 0.08);
    --color-error-border: rgba(239, 68, 68, 0.3);
    
    /* Shadows */
    --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.04);
    --shadow-md: 0 4px 12px rgba(0, 0, 0, 0.08);
    --shadow-lg: 0 8px 32px rgba(0, 0, 0, 0.12);
    --shadow-glow: 0 0 40px rgba(99, 102, 241, 0.15);
    
    /* Typography */
    --font-sans: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
    --font-mono: 'JetBrains Mono', 'Fira Code', monospace;
    
    /* Spacing */
    --sidebar-width: 280px;
    --topbar-height: 64px;
    --content-max-width: 820px;
    
    /* Transitions */
    --transition-fast: 150ms cubic-bezier(0.4, 0, 0.2, 1);
    --transition-base: 200ms cubic-bezier(0.4, 0, 0.2, 1);
    --transition-slow: 300ms cubic-bezier(0.4, 0, 0.2, 1);
}

/* ─────────────────────────────────────────────────────────────────────
   Dark Mode Override
   ───────────────────────────────────────────────────────────────────── */
html.dark {
    --bg-primary: #09090b;
    --bg-secondary: #0f0f11;
    --bg-tertiary: #18181b;
    --bg-glass: rgba(15, 15, 17, 0.85);
    
    --text-primary: #fafafa;
    --text-secondary: #d4d4d8;
    --text-muted: #a1a1aa;
    --text-inverted: #18181b;
    
    --border-subtle: rgba(255, 255, 255, 0.06);
    --border-default: #27272a;
    --border-strong: #3f3f46;
    
    --accent-primary-ghost: rgba(99, 102, 241, 0.15);
    
    --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.3);
    --shadow-md: 0 4px 12px rgba(0, 0, 0, 0.4);
    --shadow-lg: 0 8px 32px rgba(0, 0, 0, 0.5);
    --shadow-glow: 0 0 60px rgba(99, 102, 241, 0.2);
}

/* ─────────────────────────────────────────────────────────────────────
   Base Reset & Defaults
   ───────────────────────────────────────────────────────────────────── */
*, *::before, *::after {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
}

html {
    scroll-behavior: smooth;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
}

body {
    font-family: var(--font-sans);
    font-size: 16px;
    line-height: 1.7;
    color: var(--text-primary);
    background: var(--bg-primary);
    transition: background-color var(--transition-slow), color var(--transition-slow);
}

/* ─────────────────────────────────────────────────────────────────────
   Layout Structure
   ───────────────────────────────────────────────────────────────────── */
.layout {
    display: flex;
    min-height: 100vh;
}

/* ─────────────────────────────────────────────────────────────────────
   Sidebar - Glassmorphism Style
   ───────────────────────────────────────────────────────────────────── */
.sidebar {
    width: var(--sidebar-width);
    height: 100vh;
    position: sticky;
    top: 0;
    display: flex;
    flex-direction: column;
    background: var(--bg-glass);
    backdrop-filter: blur(20px) saturate(180%);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
    border-right: 1px solid var(--border-subtle);
    z-index: 100;
}

.brand {
    padding: 1.5rem 1.75rem;
    font-size: 1.25rem;
    font-weight: 700;
    letter-spacing: -0.02em;
    background: var(--accent-gradient);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    border-bottom: 1px solid var(--border-subtle);
}

.sidebar nav {
    flex: 1;
    padding: 1.25rem 1rem;
    display: flex;
    flex-direction: column;
    gap: 4px;
    overflow-y: auto;
}

.sidebar nav::-webkit-scrollbar {
    width: 4px;
}

.sidebar nav::-webkit-scrollbar-track {
    background: transparent;
}

.sidebar nav::-webkit-scrollbar-thumb {
    background: var(--border-default);
    border-radius: 4px;
}

.sidebar a {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 0.625rem 0.875rem;
    font-size: 0.9rem;
    font-weight: 500;
    text-decoration: none;
    color: var(--text-muted);
    border-radius: 8px;
    transition: all var(--transition-fast);
    position: relative;
}

.sidebar a::before {
    content: '';
    position: absolute;
    left: 0;
    top: 50%;
    transform: translateY(-50%);
    width: 3px;
    height: 0;
    background: var(--accent-gradient);
    border-radius: 0 2px 2px 0;
    transition: height var(--transition-fast);
}

.sidebar a:hover {
    color: var(--text-primary);
    background: var(--accent-primary-ghost);
}

.sidebar a.active {
    color: var(--accent-primary);
    background: var(--accent-primary-ghost);
}

.sidebar a.active::before {
    height: 60%;
}

/* ─────────────────────────────────────────────────────────────────────
   Main Content Area
   ───────────────────────────────────────────────────────────────────── */
.main-content {
    flex: 1;
    display: flex;
    flex-direction: column;
    min-height: 100vh;
}

/* ─────────────────────────────────────────────────────────────────────
   Top Bar - Glassmorphism Header
   ───────────────────────────────────────────────────────────────────── */
.topbar {
    height: var(--topbar-height);
    padding: 0 2rem;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 1rem;
    background: var(--bg-glass);
    backdrop-filter: blur(20px) saturate(180%);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
    border-bottom: 1px solid var(--border-subtle);
    position: sticky;
    top: 0;
    z-index: 50;
}

.search-placeholder {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 0.5rem 1rem;
    min-width: 240px;
    font-size: 0.875rem;
    color: var(--text-muted);
    background: var(--bg-tertiary);
    border: 1px solid var(--border-default);
    border-radius: 10px;
    cursor: pointer;
    transition: all var(--transition-fast);
}

.search-placeholder:hover {
    border-color: var(--accent-primary);
    box-shadow: var(--shadow-glow);
}

.search-placeholder::before {
    content: '⌘K';
    font-size: 0.75rem;
    font-weight: 600;
    padding: 2px 6px;
    background: var(--bg-secondary);
    border: 1px solid var(--border-default);
    border-radius: 4px;
    margin-left: auto;
}

#theme-toggle {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 40px;
    height: 40px;
    background: transparent;
    border: 1px solid transparent;
    border-radius: 10px;
    color: var(--text-muted);
    cursor: pointer;
    transition: all var(--transition-fast);
}

#theme-toggle:hover {
    color: var(--text-primary);
    background: var(--bg-tertiary);
    border-color: var(--border-default);
}

#theme-toggle:active {
    transform: scale(0.95);
}

html:not(.dark) .sun-icon { display: none; }
html:not(.dark) .moon-icon { display: block; }
html.dark .sun-icon { display: block; }
html.dark .moon-icon { display: none; }

/* ─────────────────────────────────────────────────────────────────────
   Content Area
   ───────────────────────────────────────────────────────────────────── */
.content-area {
    flex: 1;
    width: 100%;
    max-width: var(--content-max-width);
    margin: 0 auto;
    padding: 3rem 2.5rem;
}

/* ─────────────────────────────────────────────────────────────────────
   Typography Styles
   ───────────────────────────────────────────────────────────────────── */
h1, h2, h3, h4, h5, h6 {
    font-weight: 700;
    letter-spacing: -0.025em;
    line-height: 1.3;
    color: var(--text-primary);
}

h1 {
    font-size: 2.75rem;
    font-weight: 800;
    margin-bottom: 1rem;
    background: var(--accent-gradient);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
}

h2 {
    font-size: 1.875rem;
    margin-top: 3rem;
    margin-bottom: 1rem;
    padding-bottom: 0.75rem;
    border-bottom: 1px solid var(--border-default);
}

h3 {
    font-size: 1.5rem;
    margin-top: 2.5rem;
    margin-bottom: 0.75rem;
}

p {
    margin-bottom: 1.25rem;
    color: var(--text-secondary);
}

a {
    color: var(--accent-primary);
    text-decoration: none;
    font-weight: 500;
    transition: color var(--transition-fast);
}

a:hover {
    color: var(--accent-primary-hover);
    text-decoration: underline;
}

strong, b {
    font-weight: 600;
    color: var(--text-primary);
}

/* ─────────────────────────────────────────────────────────────────────
   Lists
   ───────────────────────────────────────────────────────────────────── */
ul, ol {
    margin: 1rem 0 1.5rem 1.5rem;
    color: var(--text-secondary);
}

li {
    margin-bottom: 0.5rem;
    padding-left: 0.25rem;
}

li::marker {
    color: var(--accent-primary);
}

/* ─────────────────────────────────────────────────────────────────────
   Code & Pre
   ───────────────────────────────────────────────────────────────────── */
code {
    font-family: var(--font-mono);
    font-size: 0.875em;
    padding: 0.2em 0.4em;
    background: var(--bg-tertiary);
    border: 1px solid var(--border-default);
    border-radius: 6px;
    color: var(--accent-primary);
}

pre {
    margin: 1.5rem 0;
    padding: 1.25rem 1.5rem;
    background: var(--bg-secondary);
    border: 1px solid var(--border-default);
    border-radius: 12px;
    overflow-x: auto;
    box-shadow: var(--shadow-sm);
}

pre code {
    padding: 0;
    background: none;
    border: none;
    color: var(--text-primary);
    font-size: 0.9rem;
    line-height: 1.6;
}

/* ─────────────────────────────────────────────────────────────────────
   Callout Components - Beautiful Alert Boxes
   ───────────────────────────────────────────────────────────────────── */
.callout {
    position: relative;
    margin: 1.75rem 0;
    padding: 1.25rem 1.5rem;
    padding-left: 3.5rem;
    background: var(--color-info-bg);
    border: 1px solid var(--color-info-border);
    border-radius: 12px;
    box-shadow: var(--shadow-sm);
}

.callout::before {
    content: 'ℹ';
    position: absolute;
    left: 1.25rem;
    top: 1.25rem;
    font-size: 1.25rem;
    line-height: 1;
}

.callout-info {
    background: var(--color-info-bg);
    border-color: var(--color-info-border);
}

.callout-info::before {
    content: '💡';
}

.callout-success {
    background: var(--color-success-bg);
    border-color: var(--color-success-border);
}

.callout-success::before {
    content: '✅';
}

.callout-warning {
    background: var(--color-warning-bg);
    border-color: var(--color-warning-border);
}

.callout-warning::before {
    content: '⚠️';
}

.callout-error, .callout-danger {
    background: var(--color-error-bg);
    border-color: var(--color-error-border);
}

.callout-error::before, .callout-danger::before {
    content: '🚨';
}

/* ─────────────────────────────────────────────────────────────────────
   Custom Component Styles
   ───────────────────────────────────────────────────────────────────── */
.hello-component,
.custom-component {
    margin: 1.5rem 0;
    padding: 1.5rem;
    background: linear-gradient(135deg, var(--accent-primary-ghost), transparent);
    border: 1px solid var(--border-default);
    border-radius: 12px;
    transition: all var(--transition-base);
}

.hello-component:hover,
.custom-component:hover {
    border-color: var(--accent-primary);
    box-shadow: var(--shadow-glow);
    transform: translateY(-2px);
}

.hello-component h3 {
    margin-top: 0;
    margin-bottom: 0.5rem;
    font-size: 1.125rem;
    color: var(--accent-primary);
}

.counter {
    display: inline-flex;
    gap: 1.5rem;
    padding: 1rem 1.5rem;
    background: var(--bg-tertiary);
    border-radius: 10px;
    font-family: var(--font-mono);
}

.alert {
    padding: 1rem 1.25rem;
    border-radius: 10px;
    margin: 1rem 0;
}

/* ─────────────────────────────────────────────────────────────────────
   Footer
   ───────────────────────────────────────────────────────────────────── */
footer {
    padding: 2rem;
    text-align: center;
    font-size: 0.875rem;
    color: var(--text-muted);
    border-top: 1px solid var(--border-subtle);
    background: var(--bg-glass);
    backdrop-filter: blur(10px);
}

footer a {
    font-weight: 600;
}

/* ─────────────────────────────────────────────────────────────────────
   Responsive Design
   ───────────────────────────────────────────────────────────────────── */
@media (max-width: 1024px) {
    :root {
        --sidebar-width: 240px;
    }
    
    .content-area {
        padding: 2rem 1.5rem;
    }
}

@media (max-width: 768px) {
    .sidebar {
        display: none;
    }
    
    h1 { font-size: 2rem; }
    h2 { font-size: 1.5rem; }
    
    .search-placeholder {
        min-width: auto;
        flex: 1;
    }
    
    .search-placeholder::before {
        display: none;
    }
}

/* ─────────────────────────────────────────────────────────────────────
   Animations & Micro-interactions
   ───────────────────────────────────────────────────────────────────── */
@keyframes fadeIn {
    from { opacity: 0; transform: translateY(10px); }
    to { opacity: 1; transform: translateY(0); }
}

.content-area > * {
    animation: fadeIn 0.4s ease-out forwards;
}

.content-area > *:nth-child(1) { animation-delay: 0.05s; }
.content-area > *:nth-child(2) { animation-delay: 0.1s; }
.content-area > *:nth-child(3) { animation-delay: 0.15s; }
.content-area > *:nth-child(4) { animation-delay: 0.2s; }
.content-area > *:nth-child(5) { animation-delay: 0.25s; }

/* ─────────────────────────────────────────────────────────────────────
   Selection Highlight
   ───────────────────────────────────────────────────────────────────── */
::selection {
    background: var(--accent-primary);
    color: var(--text-inverted);
}

::-moz-selection {
    background: var(--accent-primary);
    color: var(--text-inverted);
}
"
}

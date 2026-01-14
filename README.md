# 🚀 Velt

**A blazingly fast Static Site Generator powered by V**

Velt generates pure static HTML from Markdown with embedded V components. No JavaScript runtime, no hydration, just fast websites.

[![Made with V](https://img.shields.io/badge/Made%20with-V-5D87BF.svg)](https://vlang.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## ✨ Features

| Feature | Description |
|---------|-------------|
| ⚡ **Blazingly Fast** | Parallel builds with V threads. Millisecond rebuilds. |
| 🔒 **Type Safe** | Component props are V structs, type-checked at compile time. |
| 📝 **VDX Format** | Markdown + V components (like MDX for V). |
| 🔄 **Live Reload** | Instant browser refresh on file changes. |
| 🌐 **i18n Ready** | Filename-based localization (`docs.ja.vdx` → `/docs.ja.html`). |
| 🎨 **Syntax Highlighting** | Shiki-powered code blocks with dark/light themes. |
| 📦 **Zero JS Runtime** | Pure static HTML output. No client-side framework. |

## 📦 Installation

**Prerequisites:** [V](https://vlang.io/) must be installed.

```bash
git clone https://github.com/linkalls/velt
cd velt
v -o velt .
```

## 🛠 Quick Start

### 1. Create a new project

```bash
# Documentation site
./velt new my-docs

# Blog
./velt new my-blog --theme blog
```

### 2. Start development server

```bash
cd my-docs
../velt dev
```

Open `http://localhost:3000`. Edit any `.vdx` file and watch the browser auto-refresh!

### 3. Build for production

```bash
../velt build
```

Output is in `dist/` - deploy to Netlify, Vercel, or any static host.

## 📂 Project Structure

```
my-project/
├── content/           # Markdown content (.vdx)
│   ├── index.vdx      → /index.html
│   ├── docs.vdx       → /docs.html
│   └── docs.ja.vdx    → /docs.ja.html (Japanese)
├── components/        # V components
│   └── Callout.v
├── layouts/           # Page layouts
│   └── default.v
├── assets/            # Static files (CSS, images)
│   └── style.css
└── dist/              # Build output (gitignored)
```

## 🧩 Components

**Define:** `components/Callout.v`
```v
module components

pub struct Callout {
pub:
    type_   string = 'info'
    content string  // Children content
}

pub fn (c Callout) render() string {
    return '<div class="callout callout-${c.type_}">${c.content}</div>'
}
```

**Use:** `content/index.vdx`
```markdown
# Welcome

<Callout type_="warning">
  This is a **warning** callout!
</Callout>
```

## 🎨 Layouts

Layouts wrap your page content:

```v
// layouts/default.v
module layouts

pub fn default(content string, title string, nav_html string, lang string, page_path string) string {
    return '<!DOCTYPE html>
    <html lang="${lang}">
    <head><title>${title}</title></head>
    <body>
        <nav>${nav_html}</nav>
        <main>${content}</main>
    </body>
    </html>'
}
```

## 🌐 Internationalization

Use filename-based i18n:

| File | Output | Language |
|------|--------|----------|
| `docs.vdx` | `/docs.html` | English (default) |
| `docs.ja.vdx` | `/docs.ja.html` | Japanese |
| `docs.zh.vdx` | `/docs.zh.html` | Chinese |

The language switcher automatically generates correct URLs.

## 📚 CLI Reference

```bash
velt new <name> [--theme <theme>]  # Create project (docs/blog)
velt dev                           # Dev server + live reload
velt build                         # Production build
velt serve [port]                  # Static server only
velt help                          # Show help
```

## 📄 Documentation

Full documentation is built with Velt itself:

```bash
cd docs
../velt dev
```

## 🗺 Roadmap

- [ ] Search functionality
- [ ] RSS feed generation
- [ ] Sitemap generation
- [ ] Custom 404 pages
- [ ] Image optimization
- [ ] MDX-like import syntax

## License

MIT © [linkalls](https://github.com/linkalls)
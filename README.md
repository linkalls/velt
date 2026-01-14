# Velt

Velt is a Static Site Generator (SSG) framework written in V.
It leverages the performance and type safety of V to build blazing fast websites with Zero Runtime JS.

## 🚀 Features

- **Zero Runtime JS**: Generates pure static HTML. No hydration, no client-side framework overhead.
- **Type Safety**: Components are V structs. Props are type-checked at compile time.
- **Blazingly Fast**: Powered by the V compiler. Millisecond build times.
- **VDX Format**: Markdown with embedded V components (similar to MDX).
- **Live Reload**: Built-in development server with instant updates.
- **Automatic Navigation**: Automatically generates sidebar navigation from your content structure.

## 📦 Installation

Prerequisites: [V](https://vlang.io/) must be installed and in your PATH.

```bash
git clone https://github.com/yourusername/velt
cd velt
v -o velt src/
```

## 🛠 Usage

### Create a new project

```bash
./velt new my-project
```

### Start Development Server

```bash
cd my-project
../velt dev
```

This starts a local server at `http://localhost:3000`. Changes to `.vdx` files or components will automatically trigger a rebuild and reload the browser.

### Build for Production

```bash
../velt build
```

The static site will be generated in the `dist/` directory, ready to be deployed to Netlify, Vercel, or GitHub Pages.

## 📂 Project Structure

```text
/my-project
├── v.mod             # Project dependencies
├── velt.config.v     # Configuration (Planned)
├── /components       # User components (.v)
│   └── Callout.v     # struct Callout { ... }
├── /layouts          # Page layouts (.v)
│   └── default.v     # fn default(content, title, nav) string
├── /content          # Content files (.vdx)
│   ├── index.vdx     # -> dist/index.html
│   └── docs.vdx      # -> dist/docs.html
└── /dist             # Output directory (gitignored)
```

## 🧩 Components

Components are standard V structs defined in the `components` module.

**1. Define a component (`components/Callout.v`):**

```v
module components

pub struct Callout {
pub:
    type_   string = 'info' // Use 'type_' to avoid keyword conflict
    content string          // Children content is injected here
}

pub fn (c Callout) render() string {
    return '<div class="callout callout-${c.type_}">${c.content}</div>'
}
```

**2. Use it in Markdown (`content/index.vdx`):**

```markdown
# Welcome

<Callout type_="warning">
  This is a V component with **Markdown** inside!
</Callout>
```

## 🎨 Layouts

Layouts are V functions that wrap your page content. They receive the page content, title, and auto-generated navigation HTML.

**`layouts/default.v`:**

```v
module layouts

pub fn default(content string, title string, nav_html string) string {
    return '
    <!DOCTYPE html>
    <html>
        <head>
            <title>${title}</title>
        </head>
        <body>
            <nav>${nav_html}</nav>
            <main>${content}</main>
        </body>
    </html>
    '
}
```

**`content/index.vdx`:**

```toml
+++
title = "Home"
layout = "default"
+++
```

## 📄 Documentation

We have a documentation site built with Velt itself!
Check out the `docs/` directory.

To run the docs:

```bash
cd docs
../velt dev
```

## License

MIT
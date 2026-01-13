module main

import os
import markdown
import components
import layouts

fn main() {
    generate_page() or { panic(err) }
}

fn generate_page() ! {
    mut buffer := []string{}

    buffer << markdown.to_html('# Frontmatter Reference

Frontmatter is TOML-formatted metadata at the top of `.vdx` files.

## Syntax

Frontmatter is enclosed in `+++` markers:

```markdown
+++
layout = "default"
title = "My Page Title"
+++

# Page Content Here
```')
    buffer << markdown.to_html('

## Required Fields

None. All fields are optional with sensible defaults.

## Available Fields

### `layout`

Specifies which layout template to use.

```toml
layout = "default"
```')
    buffer << markdown.to_html('

| Value | Description |
|-------|-------------|
| `default` | Standard documentation layout with sidebar |
| `landing` | Landing page layout (excluded from nav) |
| Custom | Any layout file in `layouts/` directory |

')
    // Component: Callout
    buffer << components.Callout{
        type_: 'info'
        content: markdown.to_html('
Default value is `"default"` if not specified.
')
    }.render()
    buffer << markdown.to_html('

### `title`

The page title, used in:
- Browser tab (`<')
    buffer << markdown.to_html('title>`)
- Navigation sidebar
- SEO meta tags

```toml
title = "Getting Started"
```')
    buffer << markdown.to_html('

If not specified, the filename is used as a fallback.

## Future Fields

')
    // Component: Callout
    buffer << components.Callout{
        type_: 'warning'
        content: markdown.to_html('
These fields are planned for future versions:
')
    }.render()
    buffer << markdown.to_html('

### `description`

Page description for SEO.

```toml
description = "Learn how to install and configure Velt"
```')
    buffer << markdown.to_html('

### `date`

Publication date for blog posts.

```toml
date = 2024-01-15
```')
    buffer << markdown.to_html('

### `draft`

Mark page as draft (excluded from build).

```toml
draft = true
```')
    buffer << markdown.to_html('

### `order`

Custom ordering in navigation.

```toml
order = 1
```')
    buffer << markdown.to_html('

## Examples

Minimal page:

```markdown
+++
title = "About"
+++

# About Us
```')
    buffer << markdown.to_html('

Full documentation page:

```markdown
+++
layout = "default"
title = "Installation Guide"
+++

# Installation Guide

Welcome to the installation guide...
```')
    buffer << markdown.to_html('

Landing page:

```markdown
+++
layout = "landing"
title = "Welcome to Velt"
+++

<Hero title="Build Fast" subtitle="Static sites with V" />
```')

    full_html := layouts.default(buffer.join('\n'), 'Frontmatter Reference', '<a href="/docs.html">Introduction</a>
                <a href="/x.html">X</a>
                <div class="nav-section"><div class="nav-section-title">Getting started</div><a href="/getting-started/installation.html">Installation</a><a href="/getting-started/project-structure.html">Project Structure</a><a href="/getting-started/quick-start.html">Quick Start</a></div>
                <div class="nav-section"><div class="nav-section-title">Guides</div><a href="/guides/components.html">Components</a><a href="/guides/layouts.html">Layouts</a><a href="/guides/styling.html">Styling</a></div>
                <div class="nav-section"><div class="nav-section-title">Ja</div><a href="/ja/docs.html">はじめに</a><a href="/ja/getting-started/installation.html">インストール</a><a href="/ja/getting-started/project-structure.html">プロジェクト構造</a><a href="/ja/getting-started/quick-start.html">クイックスタート</a><a href="/ja/guides/components.html">コンポーネント</a><a href="/ja/guides/layouts.html">レイアウト</a><a href="/ja/guides/styling.html">スタイリング</a><a href="/ja/reference/cli.html">CLIリファレンス</a><a href="/ja/reference/frontmatter.html">フロントマターリファレンス</a></div>
                <div class="nav-section"><div class="nav-section-title">Reference</div><a href="/reference/cli.html">CLI Reference</a><a href="/reference/frontmatter.html">Frontmatter Reference</a></div>')
    // Writing to dist/reference/frontmatter.html
    os.write_file('dist/reference/frontmatter.html', full_html)!
}

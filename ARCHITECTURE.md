# Velt Architecture

Internal architecture of Velt, a V-based Static Site Generator.

## Design Philosophy

Velt uses a **"compile-the-compiler"** approach:

1. Parse `.vdx` content into segments (Markdown + Components)
2. Generate temporary V source code
3. Compile and execute to produce static HTML
4. Clean up temporary files

This guarantees **type safety** (V compiler checks props) and **performance** (native execution).

## System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        CLI (main.v)                         │
│  new | dev | build | serve                                  │
└─────────────────┬───────────────────────────────────────────┘
                  │
    ┌─────────────┴─────────────┐
    ▼                           ▼
┌─────────┐              ┌─────────────┐
│ Watcher │──triggers───▶│  Builder    │
│(watch.v)│              │ (watch.v)   │
└─────────┘              └──────┬──────┘
                                │
         ┌──────────────────────┼──────────────────────┐
         ▼                      ▼                      ▼
   ┌──────────┐          ┌────────────┐         ┌───────────┐
   │  Parser  │          │ Generator  │         │  Layouts  │
   │(parser.v)│          │(generator.v)│        │   (.v)    │
   └──────────┘          └────────────┘         └───────────┘
         │                      │
         │    Segments          │    V Source
         ▼                      ▼
   ┌──────────┐          ┌────────────┐
   │ Markdown │          │ V Compiler │
   │  (md/)   │          │   + Run    │
   └──────────┘          └────────────┘
                                │
                                ▼
                         ┌────────────┐
                         │   dist/    │
                         │  (HTML)    │
                         └────────────┘
```

## Core Modules

### CLI (`src/main.v`)

Entry point. Dispatches commands:

| Command | Description | Function |
|---------|-------------|----------|
| `new` | Scaffold project | `cmd_new()` |
| `dev` | Watch + server | `watch_and_rebuild()` + `cmd_serve()` |
| `build` | One-time build | `build_all()` |
| `serve` | Static server | `cmd_serve()` |

### Watcher (`src/watch.v`)

File change detection and build orchestration:

- **Parallel Initial Build**: Uses V threads for concurrent page builds
- **Incremental Rebuild**: Only rebuilds changed files
- **Navigation Caching**: Pre-computes nav HTML per language

```v
// Parallel build with V threads
fn build_all() {
    mut threads := []thread{}
    for file in files {
        threads << spawn build_one(file, nav_html, lang)
    }
    threads.wait()
}
```

### Parser (`src/parser.v`)

State-machine parser for `.vdx` files:

1. **Frontmatter**: TOML between `+++` markers
2. **Code Fences**: Preserved verbatim (no component parsing inside)
3. **Components**: JSX-like tags `<Component prop="value" />`
4. **Markdown**: Everything else

### Generator (`src/generator.v`)

Produces temporary V source code:

```v
// Generated code structure
module main
import components
import layouts
import os

fn main() {
    mut buffer := []string{}
    buffer << md.to_html("# Hello")        // Markdown segment
    buffer << components.Callout{...}.render()  // Component
    html := layouts.default(buffer.join(''), ...)
    os.write_file('dist/page.html', html)!
}
```

### Server (`src/server.v`)

Development server with live reload:

- **veb Framework**: V's built-in web framework
- **Live Reload**: RwMutex-based signal + browser polling (300ms)
- **Static Assets**: Mounted at `/assets/`

### Markdown (`src/md/`)

Pure V Markdown parser:

- GFM tables, code blocks, task lists
- No external dependencies
- Fast inline parsing

## Build Pipeline

```
content/docs.vdx
     │
     ▼ Read & Parse Frontmatter
     │
     ▼ Parse Body (segments)
     │
     ▼ Generate V Code → build_gen_docs.v
     │
     ▼ v run build_gen_docs.v
     │
     ▼ Write dist/docs.html
     │
     ▼ Cleanup (delete .v file)
```

## i18n Architecture

Filename-based localization:

| Pattern | Language | Output |
|---------|----------|--------|
| `docs.vdx` | English (default) | `/docs.html` |
| `docs.ja.vdx` | Japanese | `/docs.ja.html` |
| `docs.zh.vdx` | Chinese | `/docs.zh.html` |

- `detect_language()`: Extracts lang from filename
- `collect_nav_items()`: Filters by language
- Layout receives `lang` + `page_path` for switcher

## Performance Optimizations

1. **Parallel Builds**: V threads for concurrent page generation
2. **Incremental Rebuild**: Only changed files on save
3. **Navigation Cache**: Pre-computed per language
4. **Polling-based Watch**: Low overhead, cross-platform

## Future Goals

- [ ] **Plugin System**: Build-time hooks for CSS/data processing
- [ ] **Asset Pipeline**: Image optimization, CSS bundling
- [ ] **Search Index**: Generate JSON index for client-side search
- [ ] **Caching**: Skip unchanged files via content hashing

# Velt Architecture

This document describes the internal architecture of Velt, a V-based Static Site Generator.

## High-Level Overview

Velt operates on a unique "compile-the-compiler" principle. Unlike traditional SSGs that interpret templates at runtime or use a virtual DOM, Velt translates your content (`.vdx`) and components (`.v`) into a temporary V program. This program is then compiled and executed to generate the final static HTML.

This approach guarantees:
1.  **Type Safety**: Component props are checked by the V compiler.
2.  **Performance**: Leveraging V's fast compilation and execution.
3.  **Simplicity**: No complex runtime or virtual DOM is shipped to the client.

## Core Modules

### 1. CLI (`src/main.v`)
The entry point of the application. It handles command-line arguments and dispatches commands:
- `new`: Scaffolds a project using embedded templates.
- `dev`: Starts the watcher and development server.
- `build`: Triggers a one-off build process.
- `serve`: Serves the `dist` directory.

### 2. Watcher & Orchestrator (`src/watch.v`)
In development mode, this module watches for file changes using a polling mechanism (to ensure cross-platform compatibility without heavy dependencies).

When a change is detected, it triggers the `build_all()` or `build_one()` process.
- **`build_all()`**: Scans `content/` to generate a global navigation structure (`nav_html`) and rebuilds all pages.
- **`build_one()`**: Rebuilds a single page (used for optimization, though currently `build_all` is often triggered to update nav).

### 3. Parser (`src/parser.v`)
A custom state-machine parser that reads `.vdx` files.
It separates the content into:
- **Markdown segments**: Handled by the `markdown` module.
- **Component calls**: Detected via custom logic (not regex-only) to handle nested braces `{}` and props correctly.
- **Code Fences**: Ignored to prevent false positives inside code blocks.

### 4. Code Generator (`src/generator.v`)
Transpiles the parsed segments into a valid V source file (`build_gen_xxxx.v`).

The generated code imports:
- `components`: Your user-defined components.
- `layouts`: Your page layouts.
- `markdown`: V's standard markdown parser.

It constructs a `main` function that:
1. Renders Markdown segments to HTML.
2. Instantiates Component structs with the provided props.
3. Calls `.render()` on components.
4. Passes the accumulated HTML string, page title, and navigation HTML to the selected layout function.
5. Writes the final string to `dist/`.

## Build Pipeline

The process for building a single `.vdx` file:

1.  **Read**: Load `content/page.vdx`.
2.  **Parse Frontmatter**: Extract `title` and `layout` (TOML-like syntax).
3.  **Parse Body**: Split into text and component tokens.
4.  **Generate V Code**: Create a temporary file `build_gen_page.v`.
    ```v
    module main
    import components
    import layouts
    fn main() {
        // ... generated rendering logic ...
        os.write_file('dist/page.html', full_html)!
    }
    ```
5.  **Compile & Run**: Execute `v run build_gen_page.v`.
    - This step performs type checking on props.
    - If the user provided an `int` to a `string` field, the build fails here.
6.  **Cleanup**: Remove the temporary `.v` and executable files.

## Project Structure Assumptions

Velt assumes a strict directory structure to simplify configuration:
- `components/`: All files here are part of the `components` module.
- `layouts/`: All files here are part of the `layouts` module.
- `content/`: Maps 1:1 to output HTML files.

## Future Architectural Goals

- **Parallel Builds**: Compile multiple pages in parallel using V's coroutines.
- **Incremental Compilation**: Reuse compiled artifacts for unchanged components.
- **Plugin System**: Allow compile-time hooks for CSS processing or data fetching.

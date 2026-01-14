# Codebase Analysis & Issues

Based on the review of the current codebase (`src/`), here is a detailed breakdown of the issues, specifically addressing the feedback regarding "scalability concerns" and "room for improvement".

## 1. Scalability: Per-Page Compilation Strategy (Critical)

The most significant scalability issue lies in how the static site is generated.

*   **Problem:** The current implementation (`src/watch.v` and `src/generator.v`) generates a temporary V source file (`build_gen_*.v`) for **every single content page** and compiles/runs it individually using `v run`.
*   **Evidence:**
    *   `src/watch.v`: Calls `build_one` for each file.
    *   `src/watch.v` (line 144): `cmd := '${v_cmd} run ${gen_file}'` inside the build function.
*   **Impact:**
    *   **Build Time:** The time to build the site grows linearly (or worse) with the number of pages. Compiling a V program, even a small one, incurs overhead (compiler startup, type checking, code gen). For a site with 1,000 pages, this would run the compiler 1,000 times.
    *   **Resource Usage:** Heavy CPU and I/O usage during full builds.
*   **Recommendation:** Move to a "runtime" generation approach or a single compiled builder that accepts content as data, rather than compiling code for each piece of content.

## 2. Architecture: Tight Coupling & Hardcoded Logic

The architecture is clean for a small project but lacks the abstraction needed for growth.

*   **Problem:** Layout logic and property parsing are hardcoded in the generator.
*   **Evidence:**
    *   `src/generator.v`: Contains explicit `if layout_name == 'post'` checks. Adding a new layout requires modifying the core generator source code.
    *   `src/generator.v`: `transform_props` is a manual string parsing function mixed into the generator logic.
*   **Impact:** Violates the Open/Closed principle. Users cannot add new layout types without forking or modifying the framework core.
*   **Recommendation:** Implement a dynamic layout registration system or use reflection/interfaces to handle layouts generically.

## 3. Robustness: Parser Limitations

The custom Velt parser (`src/parser.v`) has correctness issues that will break in complex scenarios.

*   **Problem:** The parser cannot handle nested components of the same name.
*   **Evidence:**
    *   `src/parser.v`: The logic searches for the closing tag `</${name}>` using `index_after`. It does not track nesting depth for the specific tag name.
    *   Example: `<Box><Box>Content</Box></Box>` will result in the outer Box closing at the *first* `</Box>`, leaving the second `</Box>` dangling or incorrectly parsed.
*   **Impact:** Prevents the creation of complex component hierarchies (e.g., Grid systems, nested containers).
*   **Recommendation:** Rewrite the parser to use a stack-based approach or a proper tokenizer that tracks depth per tag name.

## 4. Code Quality: Brittle String Handling

There is heavy reliance on manual string manipulation which is error-prone.

*   **Problem:** Manual HTML escaping and injection.
*   **Evidence:**
    *   `src/generator.v`: `escaped_html := children_html.replace('\\', '\\\\').replace('\n', '\\n')...`
    *   As noted in `issue.md` (the existing issue file), this has already caused bugs with Markdown tables and multiline strings.
*   **Impact:** High risk of rendering bugs or injection vulnerabilities when content contains special characters not covered by the manual replacements.
*   **Recommendation:** Use a robust serialization method or a proper template engine that handles escaping automatically.

## 5. Development Experience

*   **Problem:** The file watcher uses polling and full directory walks.
*   **Evidence:** `src/watch.v` uses `time.sleep` and `os.walk_ext` in an infinite loop.
*   **Impact:** On large projects with thousands of files, `os.walk_ext` every 200ms will consume significant CPU.

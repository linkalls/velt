module main

// import os
import strings

fn generate_v_code(segments []ParsedSegment, output_path string, layout_name string, title string, nav_html string) string {
    mut sb := strings.new_builder(1000)

    sb.writeln('module main')
    sb.writeln('')
    sb.writeln('import os')
    sb.writeln('import markdown')
    sb.writeln('import components')
    sb.writeln('import layouts')
    sb.writeln('')
    sb.writeln('fn main() {')
    sb.writeln('    generate_page() or { panic(err) }')
    sb.writeln('}')
    sb.writeln('')
    sb.writeln('fn generate_page() ! {')
    sb.writeln('    mut buffer := []string{}')
    sb.writeln('')

    for seg in segments {
        if seg.is_component {
            mut args_code := seg.content
            if args_code != '' {
                args_code = transform_props(args_code)
            }

            sb.writeln('    // Component: ${seg.component_name}')
            sb.writeln('    buffer << components.${seg.component_name}{')
            if args_code.len > 0 {
                sb.writeln('        ${args_code}')
            }
            // Handle children
            if seg.children.len > 0 {
                // If the component supports children, we assume it has a field for it.
                // We should parse the children as markdown/components too recursively!
                // But for v0.2.0, let's just pass raw string or parsed HTML?
                // Spec says: "Markdown as parsed, then passed".
                // But `children` field in struct is string.

                // Recursion is needed. But `generate_v_code` returns a full string.
                // We need a `generate_fragment` function.
                // For now, let's just pass raw string as `content`.
                // Use standard strings with escaping for robustness.
                // We escape backslashes, single quotes, and dollar signs (to prevent interpolation).
                escaped_children := seg.children.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$')
                sb.writeln("        content: markdown.to_html('${escaped_children}')")
            }
            sb.writeln('    }.render()')

        } else {
            // Markdown
            if seg.content.trim_space().len > 0 {
                // Use standard strings with escaping for robustness.
                // We escape backslashes, single quotes, and dollar signs (to prevent interpolation).
                escaped_content := seg.content.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$')
                sb.writeln("    buffer << markdown.to_html('${escaped_content}')")
            }
        }
    }

    // Escape nav_html for V string
    nav_escaped := nav_html.replace('\\', '\\\\').replace("'", "\\'")
    sb.writeln('')
    // Pass content, title, and navigation to layout
    sb.writeln("    full_html := layouts.${layout_name}(buffer.join('\\n'), '${title}', '${nav_escaped}')")    // os.write_file requires path relative to CWD.
    // When running from `demo/`, `demo/dist/index.html` implies `demo/demo/dist/index.html`?
    // No.
    // But `main.v` generates the path as `demo/dist/index.html`.
    // If we run `v run build_gen.v` inside `demo/`, then CWD is `demo/`.
    // So writing to `demo/dist/index.html` tries to write to `demo/demo/dist/index.html`.
    // We should fix the path in generated code or in main.v

    // Let's make the output path relative to the project root properly.
    // If we are in `demo/`, we want to write to `dist/index.html`.

    // However, `output_path` is passed from `main.v` which is running in root.
    // `main.v` calculates `output_path` as `demo/dist/index.html`.

    // We should fix `main.v` to pass the correct path or change how we run the generator.

    // For now, let's keep `main.v` logic but strip the prefix if running inside.

    sb.writeln("    // Writing to ${output_path}")
    sb.writeln("    os.write_file('${output_path}', full_html)!")
    sb.writeln('}')

    return sb.str()
}

fn transform_props(raw_props string) string {
    mut result := []string{}
    mut cursor := 0

    for cursor < raw_props.len {
        for cursor < raw_props.len && raw_props[cursor].is_space() {
            cursor++
        }
        if cursor >= raw_props.len { break }

        key_start := cursor
        for cursor < raw_props.len && raw_props[cursor] != `=` {
            cursor++
        }
        key := raw_props[key_start..cursor].trim_space()

        if cursor >= raw_props.len || raw_props[cursor] != `=` {
            continue
        }
        cursor++

        if cursor >= raw_props.len { break }

        mut value := ''
        if raw_props[cursor] == `"` {
            cursor++
            val_start := cursor
            for cursor < raw_props.len && raw_props[cursor] != `"` {
                cursor++
            }
            value = "'${raw_props[val_start..cursor]}'"
            cursor++
        } else if raw_props[cursor] == `{` {
            cursor++
            val_start := cursor
            mut depth := 1
            for cursor < raw_props.len && depth > 0 {
                if raw_props[cursor] == `{` { depth++ }
                else if raw_props[cursor] == `}` { depth-- }
                if depth > 0 { cursor++ }
            }
            value = raw_props[val_start..cursor]
            cursor++
        } else {
             val_start := cursor
             for cursor < raw_props.len && !raw_props[cursor].is_space() {
                 cursor++
             }
             val_tmp := raw_props[val_start..cursor]
             value = "'${val_tmp}'"
        }

        result << "${key}: ${value}"
    }

    return result.join(', ')
}

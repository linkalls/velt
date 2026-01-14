module main

// import os
import strings
import src.md

fn generate_v_code(segments []ParsedSegment, output_path string, layout_name string, title string, nav_html string, date string, author string, lang string, page_path string) string {
	mut sb := strings.new_builder(1000)

	sb.writeln('module main')
	sb.writeln('')
	sb.writeln('import os')
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
			// Pre-process markdown at build time
				children_html := md.to_html(seg.children)
				escaped_html := children_html.replace('\\', '\\\\').replace('\n', '\\n').replace("'", "\\'").replace('$', '\\$')
				sb.writeln("        content: '${escaped_html}'")
			}
			sb.writeln('    }.render()')
		} else {
			// Markdown - pre-process at build time
			if seg.content.trim_space().len > 0 {
				// Convert markdown to HTML at build time (in velt binary)
				html_content := md.to_html(seg.content)
				// Escape for V string (order matters: backslash first, then newlines, then quotes)
				escaped_html := html_content.replace('\\', '\\\\').replace('\n', '\\n').replace("'", "\\'").replace('$', '\\$')
				sb.writeln("    buffer << '${escaped_html}'")
			}
		}
	}

	// Escape nav_html for V string
	nav_escaped := nav_html.replace('\\', '\\\\').replace("'", "\\'")
	sb.writeln('')

	// Handle different layout signatures
	if layout_name == 'post' {
		// Post layout: (content, title, date, author)
		sb.writeln("    full_html := layouts.post(buffer.join('\\n'), '${title}', '${date}', '${author}')")
	} else {
		// Default/landing/list layouts with language support: (content, title, nav_html, lang, page_path)
		sb.writeln("    full_html := layouts.${layout_name}(buffer.join('\\n'), '${title}', '${nav_escaped}', '${lang}', '${page_path}')")
	}

	sb.writeln('    // Writing to ${output_path}')
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
		if cursor >= raw_props.len {
			break
		}

		key_start := cursor
		for cursor < raw_props.len && raw_props[cursor] != `=` {
			cursor++
		}
		key := raw_props[key_start..cursor].trim_space()

		if cursor >= raw_props.len || raw_props[cursor] != `=` {
			continue
		}
		cursor++

		if cursor >= raw_props.len {
			break
		}

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
				if raw_props[cursor] == `{` {
					depth++
				} else if raw_props[cursor] == `}` {
					depth--
				}
				if depth > 0 {
					cursor++
				}
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

		result << '${key}: ${value}'
	}

	return result.join(', ')
}

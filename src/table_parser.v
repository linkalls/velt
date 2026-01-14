module main

// GFM Table Parser - Converts markdown tables to HTML
// This runs as a pre-processor before standard markdown rendering

// Parse GFM tables in markdown content and convert to HTML
fn parse_gfm_tables(content string) string {
	lines := content.split_into_lines()
	mut result := []string{}
	mut i := 0

	for i < lines.len {
		line := lines[i]

		// Check if this line looks like a table header (contains |)
		if line.contains('|') && i + 1 < lines.len {
			separator := lines[i + 1]
			// Check if next line is a separator (|---|---|)
			if is_table_separator(separator) {
				// Found a table! Parse it
				mut table_lines := []string{}
				table_lines << line
				table_lines << separator
				i += 2

				// Collect remaining table rows
				for i < lines.len && lines[i].contains('|') && !is_table_separator(lines[i]) {
					// Skip if it looks like a new table header
					if i + 1 < lines.len && is_table_separator(lines[i + 1]) {
						break
					}
					table_lines << lines[i]
					i++
				}

				// Convert table to HTML
				result << convert_table_to_html(table_lines)
				continue
			}
		}

		result << line
		i++
	}

	return result.join('\n')
}

// Check if a line is a table separator (|---|---|)
fn is_table_separator(line string) bool {
	trimmed := line.trim_space()
	if !trimmed.contains('|') {
		return false
	}

	// Check if it contains only |, -, :, and spaces
	for c in trimmed {
		if c != `|` && c != `-` && c != `:` && c != ` ` {
			return false
		}
	}

	// Must have at least some dashes
	return trimmed.contains('-')
}

// Parse table cells from a row
fn parse_table_row(line string) []string {
	// Remove leading/trailing pipes and split by |
	trimmed := line.trim_space()
	mut content := trimmed

	if content.starts_with('|') {
		content = content[1..]
	}
	if content.ends_with('|') {
		content = content[..content.len - 1]
	}

	cells := content.split('|')
	mut result := []string{}
	for cell in cells {
		result << cell.trim_space()
	}
	return result
}

// Convert table lines to HTML
fn convert_table_to_html(table_lines []string) string {
	if table_lines.len < 2 {
		return table_lines.join('\n')
	}

	header_cells := parse_table_row(table_lines[0])

	mut html := '<table>\n<thead>\n<tr>'
	for cell in header_cells {
		// Handle inline code in cells
		formatted_cell := format_cell_content(cell)
		html += '<th>${formatted_cell}</th>'
	}
	html += '</tr>\n</thead>\n<tbody>\n'

	// Skip header and separator, process body rows
	for j := 2; j < table_lines.len; j++ {
		row_cells := parse_table_row(table_lines[j])
		html += '<tr>'
		for cell in row_cells {
			formatted_cell := format_cell_content(cell)
			html += '<td>${formatted_cell}</td>'
		}
		html += '</tr>\n'
	}

	html += '</tbody>\n</table>'
	return html
}

// Format cell content (handle inline code, etc.)
fn format_cell_content(cell string) string {
	mut result := cell

	// Convert inline code backticks to <code> tags
	mut in_code := false
	mut output := []u8{}

	for c in result {
		if c == `\`` {
			if in_code {
				output << `<`
				output << `/`
				output << `c`
				output << `o`
				output << `d`
				output << `e`
				output << `>`
				in_code = false
			} else {
				output << `<`
				output << `c`
				output << `o`
				output << `d`
				output << `e`
				output << `>`
				in_code = true
			}
		} else {
			output << c
		}
	}

	return output.bytestr()
}

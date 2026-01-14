module md

// Code blocks and table parsing for markdown

// Parse fenced code blocks (``` ```)
fn parse_code_blocks(content string) string {
    lines := content.split('\n')
    mut result := []string{}
    mut i := 0
    
    for i < lines.len {
        line := lines[i]
        trimmed := line.trim_space()
        
        // Check for code fence
        if trimmed.starts_with('```') {
            // Get language (if any)
            lang := trimmed[3..].trim_space()
            mut code_lines := []string{}
            i++
            
            // Collect code until closing fence
            for i < lines.len {
                if lines[i].trim_space() == '```' {
                    break
                }
                // Escape HTML in code
                escaped := lines[i].replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
                code_lines << escaped
                i++
            }
            
            // Generate HTML
            if lang.len > 0 {
                result << '<pre><code class="language-${lang}">${code_lines.join("\n")}</code></pre>'
            } else {
                result << '<pre><code>${code_lines.join("\n")}</code></pre>'
            }
            i++ // Skip closing fence
            continue
        }
        
        result << line
        i++
    }
    
    return result.join('\n')
}

// Parse GFM tables
fn parse_tables(content string) string {
    lines := content.split('\n')
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
                for i < lines.len && lines[i].contains('|') {
                    // Skip if it's a separator (new table)
                    if is_table_separator(lines[i]) {
                        break
                    }
                    // Skip if next line is a separator (header of new table)
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
    if !trimmed.contains('|') || !trimmed.contains('-') {
        return false
    }
    
    // Must contain only |, -, :, and spaces
    for c in trimmed {
        if c != `|` && c != `-` && c != `:` && c != ` ` {
            return false
        }
    }
    
    return true
}

// Parse table cells from a row
fn parse_table_row(line string) []string {
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
        formatted := format_table_cell(cell)
        html += '<th>${formatted}</th>'
    }
    html += '</tr>\n</thead>\n<tbody>\n'
    
    // Skip header and separator, process body rows
    for j := 2; j < table_lines.len; j++ {
        row_cells := parse_table_row(table_lines[j])
        html += '<tr>'
        for cell in row_cells {
            formatted := format_table_cell(cell)
            html += '<td>${formatted}</td>'
        }
        html += '</tr>\n'
    }
    
    html += '</tbody>\n</table>'
    return html
}

// Format table cell content (inline code, etc.)
fn format_table_cell(cell string) string {
    mut result := cell
    
    // Escape HTML
    result = result.replace('&', '&amp;')
    result = result.replace('<', '&lt;')
    result = result.replace('>', '&gt;')
    
    // Convert inline code backticks to <code> tags
    mut output := []u8{}
    mut in_code := false
    
    for c in result {
        if c == `\`` {
            if in_code {
                output << '</code>'.bytes()
                in_code = false
            } else {
                output << '<code>'.bytes()
                in_code = true
            }
        } else {
            output << c
        }
    }
    
    return output.bytestr()
}

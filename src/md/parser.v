module md

// Pure V Markdown Parser
// Converts Markdown to HTML without external dependencies
// Supports: Headers, Bold, Italic, Code, Links, Images, Lists, Tables, Blockquotes

pub fn to_html(content string) string {
    // Pre-process: normalize line endings
    normalized := content.replace('\r\n', '\n').replace('\r', '\n')
    
    // Parse GFM tables first (they span multiple lines)
    with_tables := parse_tables(normalized)
    
    // Parse code blocks (``` ```)
    with_code_blocks := parse_code_blocks(with_tables)
    
    // Parse block elements line by line
    lines := with_code_blocks.split('\n')
    mut result := []string{}
    mut i := 0
    mut in_list := false
    mut list_type := '' // 'ul' or 'ol'
    mut in_blockquote := false
    mut in_pre := false  // Track if we're inside a <pre> block
    mut in_table := false // Track if we're inside a <table> block
    
    for i < lines.len {
        line := lines[i]
        trimmed := line.trim_space()
        
        // Track pre block state
        if trimmed.contains('<pre>') || trimmed.contains('<pre ') {
            in_pre = true
        }
        if trimmed.contains('</pre>') {
            result << line
            in_pre = false
            i++
            continue
        }
        
        // If inside a pre block, preserve the line as-is
        if in_pre {
            result << line
            i++
            continue
        }
        
        // Track table block state
        if trimmed.contains('<table>') || trimmed.contains('<table ') {
            in_table = true
        }
        if trimmed.contains('</table>') {
            result << line
            in_table = false
            i++
            continue
        }
        
        // If inside a table block, preserve the line as-is
        if in_table {
            result << line
            i++
            continue
        }
        
        // Empty line - close any open blocks
        if trimmed.len == 0 {
            if in_list {
                result << '</${list_type}>'
                in_list = false
            }
            if in_blockquote {
                result << '</blockquote>'
                in_blockquote = false
            }
            result << ''
            i++
            continue
        }
        
        // Preserve already-converted HTML (tables, code blocks)
        if trimmed.starts_with('<table') || trimmed.starts_with('</table') ||
           trimmed.starts_with('<thead') || trimmed.starts_with('</thead') ||
           trimmed.starts_with('<tbody') || trimmed.starts_with('</tbody') ||
           trimmed.starts_with('<tr') || trimmed.starts_with('</tr') ||
           trimmed.starts_with('<th') || trimmed.starts_with('</th') || 
           trimmed.starts_with('<td') || trimmed.starts_with('</td') ||
           trimmed.starts_with('<pre') || trimmed.starts_with('</pre') ||
           trimmed.starts_with('<code') || trimmed.starts_with('</code') {
            result << line
            i++
            continue
        }
        
        // Headers
        if trimmed.starts_with('#') {
            result << parse_header(trimmed)
            i++
            continue
        }
        
        // Horizontal rule
        if is_horizontal_rule(trimmed) {
            result << '<hr>'
            i++
            continue
        }
        
        // Blockquotes
        if trimmed.starts_with('>') {
            if !in_blockquote {
                result << '<blockquote>'
                in_blockquote = true
            }
            quote_content := trimmed[1..].trim_space()
            result << '<p>${parse_inline(quote_content)}</p>'
            i++
            continue
        } else if in_blockquote {
            result << '</blockquote>'
            in_blockquote = false
        }
        
        // Unordered lists
        if trimmed.starts_with('- ') || trimmed.starts_with('* ') {
            if !in_list || list_type != 'ul' {
                if in_list {
                    result << '</${list_type}>'
                }
                result << '<ul>'
                in_list = true
                list_type = 'ul'
            }
            item_content := trimmed[2..].trim_space()
            result << '<li>${parse_inline(item_content)}</li>'
            i++
            continue
        }
        
        // Ordered lists
        if is_ordered_list_item(trimmed) {
            if !in_list || list_type != 'ol' {
                if in_list {
                    result << '</${list_type}>'
                }
                result << '<ol>'
                in_list = true
                list_type = 'ol'
            }
            item_content := get_ordered_list_content(trimmed)
            result << '<li>${parse_inline(item_content)}</li>'
            i++
            continue
        }
        
        // Close list if we're not in a list item
        if in_list {
            result << '</${list_type}>'
            in_list = false
        }
        
        // Regular paragraph
        result << '<p>${parse_inline(trimmed)}</p>'
        i++
    }
    
    // Close any remaining open blocks
    if in_list {
        result << '</${list_type}>'
    }
    if in_blockquote {
        result << '</blockquote>'
    }
    
    return result.join('\n')
}

// Parse header lines (#, ##, ###, etc.)
fn parse_header(line string) string {
    mut level := 0
    for c in line {
        if c == `#` {
            level++
        } else {
            break
        }
    }
    if level > 6 {
        level = 6
    }
    content := line[level..].trim_space()
    return '<h${level}>${parse_inline(content)}</h${level}>'
}

// Check if line is a horizontal rule
fn is_horizontal_rule(line string) bool {
    trimmed := line.trim_space()
    if trimmed.len < 3 {
        return false
    }
    
    // Check for ---, ***, ___
    first := trimmed[0]
    if first != `-` && first != `*` && first != `_` {
        return false
    }
    
    mut count := 0
    for c in trimmed {
        if c == first {
            count++
        } else if c != ` ` {
            return false
        }
    }
    return count >= 3
}

// Check if line is an ordered list item (1. 2. etc.)
fn is_ordered_list_item(line string) bool {
    mut i := 0
    for i < line.len && line[i].is_digit() {
        i++
    }
    if i == 0 || i >= line.len {
        return false
    }
    return line[i] == `.` && i + 1 < line.len && line[i + 1] == ` `
}

// Get content after "1. " in ordered list
fn get_ordered_list_content(line string) string {
    mut i := 0
    for i < line.len && line[i].is_digit() {
        i++
    }
    if i + 2 < line.len {
        return line[i + 2..].trim_space()
    }
    return ''
}

// Parse inline elements: bold, italic, code, links, images
fn parse_inline(text string) string {
    mut result := text
    
    // Escape HTML entities
    result = result.replace('&', '&amp;')
    result = result.replace('<', '&lt;')
    result = result.replace('>', '&gt;')
    
    // Images: ![alt](url)
    result = parse_images(result)
    
    // Links: [text](url)
    result = parse_links(result)
    
    // Inline code: `code`
    result = parse_inline_code(result)
    
    // Bold: **text** or __text__
    result = parse_bold(result)
    
    // Italic: *text* or _text_
    result = parse_italic(result)
    
    return result
}

// Parse inline code
fn parse_inline_code(text string) string {
    mut result := []u8{}
    mut i := 0
    mut in_code := false
    
    for i < text.len {
        if text[i] == `\`` {
            if in_code {
                result << `<`
                result << `/`
                result << `c`
                result << `o`
                result << `d`
                result << `e`
                result << `>`
                in_code = false
            } else {
                result << `<`
                result << `c`
                result << `o`
                result << `d`
                result << `e`
                result << `>`
                in_code = true
            }
        } else {
            result << text[i]
        }
        i++
    }
    
    return result.bytestr()
}

// Parse bold text
fn parse_bold(text string) string {
    mut result := text
    
    // **bold**
    for result.contains('**') {
        start := result.index('**') or { break }
        rest := result[start + 2..]
        end := rest.index('**') or { break }
        bold_text := rest[..end]
        result = result[..start] + '<strong>' + bold_text + '</strong>' + rest[end + 2..]
    }
    
    // __bold__
    for result.contains('__') {
        start := result.index('__') or { break }
        rest := result[start + 2..]
        end := rest.index('__') or { break }
        bold_text := rest[..end]
        result = result[..start] + '<strong>' + bold_text + '</strong>' + rest[end + 2..]
    }
    
    return result
}

// Parse italic text
fn parse_italic(text string) string {
    mut result := text
    
    // *italic* (but not **)
    mut i := 0
    mut output := []u8{}
    
    for i < result.len {
        if result[i] == `*` && (i + 1 >= result.len || result[i + 1] != `*`) {
            // Find closing *
            mut j := i + 1
            for j < result.len {
                if result[j] == `*` && (j + 1 >= result.len || result[j + 1] != `*`) {
                    // Found closing *
                    output << '<em>'.bytes()
                    output << result[i + 1..j].bytes()
                    output << '</em>'.bytes()
                    i = j + 1
                    break
                }
                j++
            }
            if j >= result.len {
                output << result[i]
                i++
            }
        } else {
            output << result[i]
            i++
        }
    }
    
    return output.bytestr()
}

// Parse links: [text](url)
fn parse_links(text string) string {
    mut result := text
    
    for result.contains('](') {
        // Find [
        bracket_start := result.index('[') or { break }
        // Find ]( after [
        rest := result[bracket_start + 1..]
        bracket_end := rest.index('](') or { break }
        link_text := rest[..bracket_end]
        
        // Find closing )
        url_start := bracket_start + 1 + bracket_end + 2
        url_rest := result[url_start..]
        paren_end := url_rest.index(')') or { break }
        url := url_rest[..paren_end]
        
        // Build replacement
        replacement := '<a href="${url}">${link_text}</a>'
        result = result[..bracket_start] + replacement + result[url_start + paren_end + 1..]
    }
    
    return result
}

// Parse images: ![alt](url)
fn parse_images(text string) string {
    mut result := text
    
    for result.contains('![') {
        // Find ![
        img_start := result.index('![') or { break }
        // Find ]( after ![
        rest := result[img_start + 2..]
        bracket_end := rest.index('](') or { break }
        alt_text := rest[..bracket_end]
        
        // Find closing )
        url_start := img_start + 2 + bracket_end + 2
        url_rest := result[url_start..]
        paren_end := url_rest.index(')') or { break }
        url := url_rest[..paren_end]
        
        // Build replacement
        replacement := '<img src="${url}" alt="${alt_text}">'
        result = result[..img_start] + replacement + result[url_start + paren_end + 1..]
    }
    
    return result
}

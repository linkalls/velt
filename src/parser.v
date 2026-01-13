module main

struct ComponentCall {
pub:
    name string
    raw_args string
    children string
}

struct ParsedSegment {
pub:
    is_component bool
    content string
    component_name string
    children string
}

fn parse_velt_file(content string) []ParsedSegment {
    mut segments := []ParsedSegment{}

    mut index := 0
    for index < content.len {
        // Find next opening tag <[A-Z]
        // We use index_after but we need to handle Option return.

        start_tag_idx_opt := content.index_after('<', index)

        // Handle Option manually
        start_tag_idx := start_tag_idx_opt or {
            // No more tags, the rest is markdown
            segments << ParsedSegment{
                is_component: false
                content: content[index..]
            }
            break
        }

        // Check if it looks like a component (starts with Uppercase)
        if start_tag_idx + 1 >= content.len {
             segments << ParsedSegment{
                is_component: false
                content: content[index..]
            }
            break
        }

        char_after_lt := content[start_tag_idx+1]

        if char_after_lt.is_capital() {
            // Found potential component
            // Add text before this tag to segments
            if start_tag_idx > index {
                segments << ParsedSegment{
                    is_component: false
                    content: content[index..start_tag_idx]
                }
            }

            // Now parse the component
            // Extract Name
            // Find end of name (space, >, /)
            mut name_end_idx := start_tag_idx + 1
            for name_end_idx < content.len {
                c := content[name_end_idx]
                if !c.is_alnum() && c != `_` {
                    break
                }
                name_end_idx++
            }

            name := content[start_tag_idx+1..name_end_idx]

            // Parse attributes until `/>` or `>`

            mut cursor := name_end_idx
            mut in_quote := false
            mut quote_char := u8(0)
            mut brace_depth := 0
            mut tag_end_idx := -1
            mut is_self_closing := false

            for cursor < content.len {
                c := content[cursor]
                if in_quote {
                    if c == quote_char {
                        if content[cursor-1] != `\\` {
                            in_quote = false
                        }
                    }
                } else {
                    if c == `"` || c == `'` {
                        in_quote = true
                        quote_char = c
                    } else if c == `{` {
                        brace_depth++
                    } else if c == `}` {
                        brace_depth--
                    } else if c == `>` && brace_depth == 0 {
                        // Found end of tag
                        tag_end_idx = cursor
                        if cursor > 0 && content[cursor-1] == `/` {
                            is_self_closing = true
                        }
                        break
                    }
                }
                cursor++
            }

            if tag_end_idx != -1 {
                // Extracted tag
                mut raw_args_end := tag_end_idx
                if is_self_closing {
                    raw_args_end-- // skip /
                }

                raw_args := content[name_end_idx..raw_args_end].trim_space()

                if is_self_closing {
                    segments << ParsedSegment{
                        is_component: true
                        component_name: name
                        content: raw_args
                    }
                    index = tag_end_idx + 1
                } else {
                    // Start tag found, look for end tag </Name>
                    // Naive implementation: Find next closing tag.
                    // TODO: Handle nested components of same name by counting depth.
                    // Current implementation might close early if nested: <Box><Box>...</Box></Box>
                    // For MVP, we stick to finding the first </Name>.

                    end_tag := '</${name}>'
                    close_tag_idx_opt := content.index_after(end_tag, tag_end_idx)

                    if close_tag_idx := close_tag_idx_opt {
                         children := content[tag_end_idx+1..close_tag_idx]
                        segments << ParsedSegment{
                            is_component: true
                            component_name: name
                            content: raw_args
                            children: children
                        }
                        index = close_tag_idx + end_tag.len
                    } else {
                        // No closing tag found? Treat as text?
                        segments << ParsedSegment{
                            is_component: false
                            content: content[start_tag_idx..tag_end_idx+1]
                        }
                        index = tag_end_idx + 1
                    }
                }
            } else {
                // Malformed tag?
                segments << ParsedSegment{
                    is_component: false
                    content: content[start_tag_idx..start_tag_idx+1]
                }
                index = start_tag_idx + 1
            }

        } else {
            // Not a component
             segments << ParsedSegment{
                is_component: false
                content: content[index..start_tag_idx+1]
            }
            index = start_tag_idx + 1
        }
    }

    return segments
}

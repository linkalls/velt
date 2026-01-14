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
        // Find next interesting tokens
        tag_start_opt := content.index_after('<', index)
        tag_start := tag_start_opt or { -1 }

        code_fence_opt := content.index_after('```', index)
        code_fence := code_fence_opt or { -1 }


        mut next_event := -1
        mut is_tag := false
        mut is_fence := false

        // Find the earliest event (only tags and code fences, not inline code)
        if tag_start != -1 {
            next_event = tag_start
            is_tag = true
        }
        if code_fence != -1 && (next_event == -1 || code_fence < next_event) {
            next_event = code_fence
            is_tag = false
            is_fence = true
        }

        if next_event == -1 {
             segments << ParsedSegment{
                is_component: false
                content: content[index..]
            }
            break
        }

        if is_fence {
            // Find end of fence
            fence_end_opt := content.index_after('```', next_event + 3)
            fence_end := fence_end_opt or { -1 }

            if fence_end != -1 {
                segments << ParsedSegment{
                    is_component: false
                    content: content[index..fence_end+3]
                }
                index = fence_end + 3
            } else {
                segments << ParsedSegment{
                    is_component: false
                    content: content[index..]
                }
                break
            }
        } else if is_tag {
            // Check if it's a component
             if next_event + 1 >= content.len {
                 segments << ParsedSegment{
                    is_component: false
                    content: content[index..]
                }
                break
            }

            char_after_lt := content[next_event+1]
            if char_after_lt.is_capital() {
                // Add text before tag
                 if next_event > index {
                    segments << ParsedSegment{
                        is_component: false
                        content: content[index..next_event]
                    }
                }
                
                start_tag_idx := next_event
                
                // Existing parsing logic
                mut name_end_idx := start_tag_idx + 1
                for name_end_idx < content.len {
                    c := content[name_end_idx]
                    if !c.is_alnum() && c != `_` {
                        break
                    }
                    name_end_idx++
                }

                name := content[start_tag_idx+1..name_end_idx]

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
                    mut raw_args_end := tag_end_idx
                    if is_self_closing {
                        raw_args_end-- 
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
                             segments << ParsedSegment{
                                is_component: false
                                content: content[start_tag_idx..tag_end_idx+1]
                            }
                            index = tag_end_idx + 1
                        }
                    }
                } else {
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
                    content: content[index..next_event+1]
                }
                index = next_event + 1
            }
        }
    }

    return segments
}

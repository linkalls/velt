module main

fn test_parse_simple() {
    content := 'Markdown <Hello /> Markdown'
    segments := parse_velt_file(content)
    assert segments.len == 3
    assert segments[0].is_component == false
    assert segments[0].content == 'Markdown '
    assert segments[1].is_component == true
    assert segments[1].component_name == 'Hello'
    assert segments[2].is_component == false
    assert segments[2].content == ' Markdown'
}

fn test_parse_props() {
    content := '<Hello title="World" />'
    segments := parse_velt_file(content)
    assert segments.len == 1
    assert segments[0].is_component == true
    assert segments[0].component_name == 'Hello'
    assert segments[0].content.contains('title="World"')
}

fn test_parse_children() {
    content := '<Alert>Warning</Alert>'
    segments := parse_velt_file(content)
    assert segments.len == 1
    assert segments[0].is_component == true
    assert segments[0].component_name == 'Alert'
    assert segments[0].children == 'Warning'
}

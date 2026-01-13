module main

fn test_transform_props() {
    input := 'title="Hello" count={10}'
    output := transform_props(input)
    assert output.contains("title: 'Hello'")
    assert output.contains("count: 10")
}

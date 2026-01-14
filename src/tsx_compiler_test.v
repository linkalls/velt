module main

import os

fn test_check_bun() {
    compiler := new_tsx_compiler('.')
    has_bun := compiler.check_bun()
    // Just check that the function runs without error
    // Result depends on environment
    println('Bun available: ${has_bun}')
}

fn test_find_tsx_components() {
    test_dir := '_test_tsx_project'
    os.mkdir_all('${test_dir}/components') or {}
    defer { os.rmdir_all(test_dir) or {} }

    // Create test TSX files
    os.write_file('${test_dir}/components/Hero.tsx', '// test') or {}
    os.write_file('${test_dir}/components/Card.tsx', '// test') or {}
    os.write_file('${test_dir}/components/Footer.v', '// v file') or {}

    compiler := new_tsx_compiler(test_dir)
    tsx_files := compiler.find_tsx_components()

    assert tsx_files.len == 2
    assert tsx_files.any(it.contains('Hero.tsx'))
    assert tsx_files.any(it.contains('Card.tsx'))
}

fn test_get_component_name() {
    assert get_component_name('/path/to/Hero.tsx') == 'Hero'
    assert get_component_name('/path/to/PostCard.v') == 'PostCard'
    assert get_component_name('Card.tsx') == 'Card'
}

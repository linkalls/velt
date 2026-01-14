module main

import os

fn test_cmd_new_docs_theme() {
    test_dir := '_test_docs_project'
    defer { os.rmdir_all(test_dir) or {} }

    cmd_new(test_dir, 'docs') or {
        assert false, 'cmd_new failed: ${err}'
        return
    }

    // Verify docs theme structure
    assert os.exists('${test_dir}/layouts/default.v')
    assert os.exists('${test_dir}/layouts/landing.v')
    assert os.exists('${test_dir}/components/Hero.v')
    assert os.exists('${test_dir}/components/Callout.v')
    assert os.exists('${test_dir}/assets/style.css')
    assert os.exists('${test_dir}/assets/landing.css')
    assert os.exists('${test_dir}/content/index.vdx')
    assert os.exists('${test_dir}/content/docs.vdx')

    // Verify config contains theme
    config := os.read_file('${test_dir}/velt.config.v') or { '' }
    assert config.contains("theme string = 'docs'")
}

fn test_cmd_new_blog_theme() {
    test_dir := '_test_blog_project'
    defer { os.rmdir_all(test_dir) or {} }

    cmd_new(test_dir, 'blog') or {
        assert false, 'cmd_new failed: ${err}'
        return
    }

    // Verify blog theme structure
    assert os.exists('${test_dir}/layouts/post.v')
    assert os.exists('${test_dir}/layouts/list.v')
    assert os.exists('${test_dir}/components/PostCard.v')
    assert os.exists('${test_dir}/assets/blog.css')
    assert os.exists('${test_dir}/content/index.vdx')
    assert os.exists('${test_dir}/content/posts/hello-world.vdx')

    // Verify config contains theme
    config := os.read_file('${test_dir}/velt.config.v') or { '' }
    assert config.contains("theme string = 'blog'")
}

fn test_cmd_new_existing_directory() {
    test_dir := '_test_existing'
    os.mkdir(test_dir) or {}
    defer { os.rmdir_all(test_dir) or {} }

    // Should not panic, just return early
    cmd_new(test_dir, 'docs') or {}
    
    // Should not have created any files inside
    assert !os.exists('${test_dir}/velt.config.v')
}

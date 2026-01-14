module main

import os

// Embed docs theme files
const docs_style_css = $embed_file('themes/docs/assets/style.css')
const docs_landing_css = $embed_file('themes/docs/assets/landing.css')
const docs_layout_default = $embed_file('themes/docs/layouts/default.v')
const docs_layout_landing = $embed_file('themes/docs/layouts/landing.v')
const docs_component_callout = $embed_file('themes/docs/components/Callout.v')
const docs_component_hero = $embed_file('themes/docs/components/Hero.v')
const docs_component_features = $embed_file('themes/docs/components/FeaturesSection.v')

// Embed blog theme files
const blog_css = $embed_file('themes/blog/assets/blog.css')
const blog_layout_post = $embed_file('themes/blog/layouts/post.v')
const blog_layout_list = $embed_file('themes/blog/layouts/list.v')
const blog_component_postcard = $embed_file('themes/blog/components/PostCard.v')
const blog_content_index = $embed_file('themes/blog/content/index.vdx')
const blog_content_hello = $embed_file('themes/blog/content/hello-world.vdx')

// Embed content templates
const tpl_content_index = $embed_file('templates/content/index.vdx')
const tpl_content_docs = $embed_file('templates/content/docs.vdx')

fn cmd_new(project_name string, theme string) ! {
    if os.exists(project_name) {
        println('Error: Directory ${project_name} already exists.')
        return
    }

    // Validate theme
    valid_themes := ['docs', 'blog']
    if theme !in valid_themes {
        println('Error: Unknown theme "${theme}". Available themes: ${valid_themes}')
        return
    }

    println('Creating new Velt project: ${project_name} with theme: ${theme}...')

    os.mkdir(project_name) or { panic(err) }
    os.mkdir_all('${project_name}/components') or { panic(err) }
    os.mkdir_all('${project_name}/content') or { panic(err) }
    os.mkdir_all('${project_name}/layouts') or { panic(err) }
    os.mkdir_all('${project_name}/assets') or { panic(err) }

    // Create v.mod
    site_type := if theme == 'blog' { 'Blog' } else { 'Documentation Site' }
    os.write_file('${project_name}/v.mod', "Module {
    name: '${project_name}'
    description: 'My Velt ${site_type}'
    version: '0.0.1'
    license: 'MIT'
    dependencies: []
}")!

    // Create config with theme
    os.write_file('${project_name}/velt.config.v', "module main

pub struct Config {
pub:
    title string = 'My ${site_type}'
    theme string = '${theme}'
}")!

    match theme {
        'docs' {
            scaffold_docs_theme(project_name)!
        }
        'blog' {
            scaffold_blog_theme(project_name)!
        }
        else {}
    }

    println('Done! Now run:')
    println('  cd ${project_name}')
    println('  velt build')
    println('  velt serve')
}

fn scaffold_docs_theme(project_name string) ! {
    // Layouts
    os.write_file('${project_name}/layouts/default.v', docs_layout_default.to_string())!
    os.write_file('${project_name}/layouts/landing.v', docs_layout_landing.to_string())!

    // Components
    os.write_file('${project_name}/components/Callout.v', docs_component_callout.to_string())!
    os.write_file('${project_name}/components/Hero.v', docs_component_hero.to_string())!
    os.write_file('${project_name}/components/FeaturesSection.v', docs_component_features.to_string())!

    // Content
    os.write_file('${project_name}/content/index.vdx', tpl_content_index.to_string())!
    os.write_file('${project_name}/content/docs.vdx', tpl_content_docs.to_string())!

    // Assets
    os.write_file('${project_name}/assets/style.css', docs_style_css.to_string())!
    os.write_file('${project_name}/assets/landing.css', docs_landing_css.to_string())!
}

fn scaffold_blog_theme(project_name string) ! {
    // Layouts
    os.write_file('${project_name}/layouts/post.v', blog_layout_post.to_string())!
    os.write_file('${project_name}/layouts/list.v', blog_layout_list.to_string())!

    // Components
    os.write_file('${project_name}/components/PostCard.v', blog_component_postcard.to_string())!

    // Content
    os.mkdir_all('${project_name}/content/posts') or { panic(err) }
    os.write_file('${project_name}/content/index.vdx', blog_content_index.to_string())!
    os.write_file('${project_name}/content/posts/hello-world.vdx', blog_content_hello.to_string())!

    // Assets
    os.write_file('${project_name}/assets/blog.css', blog_css.to_string())!
}

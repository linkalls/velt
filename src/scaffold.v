module main

import os

// Embed CSS files - V will embed these at compile time
const style_css = $embed_file('assets/style.css')
const landing_css = $embed_file('assets/landing.css')

// Embed template files
const tpl_layout_default = $embed_file('templates/layouts/default.v')
const tpl_layout_landing = $embed_file('templates/layouts/landing.v')
const tpl_component_callout = $embed_file('templates/components/Callout.v')
const tpl_component_hero = $embed_file('templates/components/Hero.v')
const tpl_component_features = $embed_file('templates/components/FeaturesSection.v')
const tpl_content_index = $embed_file('templates/content/index.vdx')
const tpl_content_docs = $embed_file('templates/content/docs.vdx')

fn cmd_new(project_name string) ! {
	if os.exists(project_name) {
		println('Error: Directory ${project_name} already exists.')
		return
	}

	println('Creating new Velt project: ${project_name}...')

	os.mkdir(project_name) or { panic(err) }
	os.mkdir_all('${project_name}/components') or { panic(err) }
	os.mkdir_all('${project_name}/content') or { panic(err) }
	os.mkdir_all('${project_name}/layouts') or { panic(err) }
	os.mkdir_all('${project_name}/assets') or { panic(err) }

	// Create v.mod
	os.write_file('${project_name}/v.mod', "Module {
    name: '${project_name}'
    description: 'My Velt Documentation Site'
    version: '0.0.1'
    license: 'MIT'
    dependencies: []
}")!

	// Create config
	os.write_file('${project_name}/velt.config.v', "module main

pub struct Config {
pub:
    title string = 'My Docs'
}")!

	// Create layouts from embedded templates
	os.write_file('${project_name}/layouts/default.v', tpl_layout_default.to_string())!
	os.write_file('${project_name}/layouts/landing.v', tpl_layout_landing.to_string())!

	// Create components from embedded templates
	os.write_file('${project_name}/components/Callout.v', tpl_component_callout.to_string())!
	os.write_file('${project_name}/components/Hero.v', tpl_component_hero.to_string())!
	os.write_file('${project_name}/components/FeaturesSection.v', tpl_component_features.to_string())!

	// Create content from embedded templates
	os.write_file('${project_name}/content/index.vdx', tpl_content_index.to_string())!
	os.write_file('${project_name}/content/docs.vdx', tpl_content_docs.to_string())!

	// Copy CSS files from embedded data
	os.write_file('${project_name}/assets/style.css', style_css.to_string())!
	os.write_file('${project_name}/assets/landing.css', landing_css.to_string())!

	println('Done! Now run:')
	println('  cd ${project_name}')
	println('  velt build')
	println('  velt serve')
}

module main

import veb
import os
// import markdown

// App struct with veb.StaticHandler embedded FIRST
pub struct App {
	veb.StaticHandler
}

// Custom Context struct
pub struct Context {
	veb.Context
}

// ... (structs unchanged)

// Index route
@['/']
pub fn (app &App) index(mut ctx Context) veb.Result {
	return serve_page(mut ctx, 'index')
}

// Dynamic page route
@['/:page']
pub fn (app &App) page(mut ctx Context, page string) veb.Result {
	// Skip asset requests that might fall through
	if page.starts_with('assets') || page.ends_with('.css') || page.ends_with('.js') {
		return ctx.not_found()
	}

	// Handle docs.html -> docs
	page_name := if page.ends_with('.html') {
		page.replace('.html', '')
	} else {
		page
	}

	return serve_page(mut ctx, page_name)
}

fn serve_page(mut ctx Context, name string) veb.Result {
	vdx_file := 'content/${name}.vdx'

	if !os.exists(vdx_file) {
		return ctx.not_found()
	}

	println('[velt] Building: ${vdx_file}')
	html := build_page_with_markdown(vdx_file)
	return ctx.html(html)
}

// Helper to build page on the fly
fn build_page_with_markdown(path string) string {
	build_one(path)
	
	// Calculate expected output path
	// This mirrors logic in build_one
	normalized := path.replace('\\', '/')
	filename := normalized.replace('content/', '').replace('.vdx', '.html')
	out_path := 'dist/${filename}'
	
	return os.read_file(out_path) or {
		eprintln('Failed to read built file ${out_path}: ${err}')
		return 'Error building page'
	}
}

fn cmd_serve(port int) ! {
	println('Starting Velt Dev Server at http://localhost:${port}')
	mut app := &App{}
	// Handle static assets at /assets route
	app.mount_static_folder_at('assets', '/assets')!
	veb.run[App, Context](mut app, port)
}

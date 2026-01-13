module main

import veb
import os
import net.http as _
// import markdown

// App struct with veb.StaticHandler embedded FIRST
pub struct App {
	veb.StaticHandler
mut:
	reload_chan chan bool
}

// Custom Context struct
pub struct Context {
	veb.Context
}

pub fn (mut app App) notify_reload() {
	select {
		app.reload_chan <- true { println('[server] Sending reload signal...') }
		else { println('[server] No listeners for reload.') }
	}
}

// ... (structs unchanged)

// SSE Route for live reload
@['/_velt_reload']
pub fn (app &App) reload_event(mut ctx Context) veb.Result {
	ctx.set_content_type('text/event-stream')
	ctx.set_header(.cache_control, 'no-cache')
	ctx.set_header(.connection, 'keep-alive')

	_ := <-app.reload_chan
	return ctx.ok('data: reload\n\n')
}

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
	mut html := build_page_with_markdown(vdx_file)

	// Inject reload script
	reload_script := '<script>
	new EventSource("/_velt_reload").onmessage = () => location.reload();
	</script></body>'

	html = html.replace('</body>', reload_script)

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

fn cmd_serve(port int, app &App) ! {
	println('Starting Velt Dev Server at http://localhost:${port}')
	// Handle static assets at /assets route
	// Note: We need to cast to mut because mount_static_folder_at modifies app,
	// but veb.run takes it too.
	// Actually, let's just assume app is already set up or we modify it here.
	mut mutable_app := unsafe { app }
	mutable_app.mount_static_folder_at('assets', '/assets')!
	veb.run[App, Context](mut mutable_app, port)
}

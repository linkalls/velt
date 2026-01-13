module main

import veb
import os
// import net.http as _
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
		app.reload_chan <- true {
			println('[server] Sending reload signal...')
		}
		else {
			println('[server] No listeners for reload.')
		}
	}
}

// ... (structs unchanged)

// Polling endpoint for live reload - returns immediately
// Client polls this endpoint periodically to check for reload signal
@['/_velt_reload']
pub fn (mut app App) reload_event(mut ctx Context) veb.Result {
	// Non-blocking check for reload signal
	select {
		_ := <-app.reload_chan {
			return ctx.ok('reload')
		}
		else {
			return ctx.ok('ok')
		}
	}
	return ctx.ok('ok') // unreachable
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
	// First check if pre-built HTML exists
	html_file := 'dist/${name}.html'

	mut html := ''
	if os.exists(html_file) {
		// Use pre-built HTML (built by watcher)
		html = os.read_file(html_file) or {
			eprintln('Failed to read ${html_file}: ${err}')
			return ctx.html('<h1>500 - Server Error</h1>')
		}
	} else {
		// Fallback: check if source exists and build it
		vdx_file := 'content/${name}.vdx'
		if !os.exists(vdx_file) {
			return ctx.not_found()
		}

		println('[velt] Building on demand: ${vdx_file}')
		build_all()  // Rebuild all to ensure navigation is correct

		html = os.read_file(html_file) or {
			eprintln('Failed to read built file ${html_file}: ${err}')
			return ctx.html('<h1>500 - Server Error</h1>')
		}
	}

	// Inject reload script - use polling instead of SSE
	reload_script := '<script>
	(function() {
		var checkReload = function() {
			fetch("/_velt_reload").then(function(r) { return r.text(); }).then(function(t) {
				if (t === "reload") location.reload();
				else setTimeout(checkReload, 500);
			}).catch(function() { setTimeout(checkReload, 1000); });
		};
		checkReload();
	})();
	</script></body>'

	html = html.replace('</body>', reload_script)

	return ctx.html(html)
}

fn cmd_serve(port int, app &App) ! {
	println('Starting Velt Dev Server at http://localhost:${port}')
	// Handle static assets at /assets route
	mut mutable_app := unsafe { app }
	mutable_app.mount_static_folder_at('assets', '/assets')!
	// Use run_at for multi-threaded server
	veb.run_at[App, Context](mut mutable_app, host: '', port: port)!
}

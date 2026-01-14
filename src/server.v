module main

import veb
import os
import sync

// App struct with veb.StaticHandler embedded FIRST
pub struct App {
	veb.StaticHandler
mut:
	reload_flag &sync.RwMutex = sync.new_rwmutex()
	should_reload bool
}

// Custom Context struct
pub struct Context {
	veb.Context
}

pub fn (mut app App) notify_reload() {
	app.reload_flag.@lock()
	app.should_reload = true
	app.reload_flag.unlock()
	println('[server] Reload signal set')
}

// Polling endpoint for live reload
@['/_velt_reload']
pub fn (mut app App) reload_event(mut ctx Context) veb.Result {
	app.reload_flag.@lock()
	should := app.should_reload
	if should {
		app.should_reload = false
	}
	app.reload_flag.unlock()
	
	if should {
		return ctx.ok('reload')
	}
	return ctx.ok('ok')
}

// Index route
@['/']
pub fn (app &App) index(mut ctx Context) veb.Result {
	return serve_page(mut ctx, 'index')
}

// Dynamic page route (1 level)
@['/:page']
pub fn (app &App) page(mut ctx Context, page string) veb.Result {
	if page.starts_with('assets') || page.ends_with('.css') || page.ends_with('.js') {
		return ctx.not_found()
	}

	page_name := if page.ends_with('.html') {
		page.replace('.html', '')
	} else {
		page
	}

	return serve_page(mut ctx, page_name)
}

// Nested route (2 levels)
@['/:dir/:page']
pub fn (app &App) nested_page(mut ctx Context, dir string, page string) veb.Result {
	page_name := if page.ends_with('.html') {
		'${dir}/' + page.replace('.html', '')
	} else {
		'${dir}/${page}'
	}
	return serve_page(mut ctx, page_name)
}

// Deeply nested route (3 levels)
@['/:dir/:subdir/:page']
pub fn (app &App) deep_nested_page(mut ctx Context, dir string, subdir string, page string) veb.Result {
	page_name := if page.ends_with('.html') {
		'${dir}/${subdir}/' + page.replace('.html', '')
	} else {
		'${dir}/${subdir}/${page}'
	}
	return serve_page(mut ctx, page_name)
}

fn serve_page(mut ctx Context, name string) veb.Result {
	html_file := 'dist/${name}.html'

	mut html := ''
	if os.exists(html_file) {
		html = os.read_file(html_file) or {
			eprintln('Failed to read ${html_file}: ${err}')
			return ctx.html('<h1>500 - Server Error</h1>')
		}
	} else {
		vdx_file := 'content/${name}.vdx'
		if !os.exists(vdx_file) {
			return ctx.not_found()
		}

		println('[velt] Building on demand: ${vdx_file}')
		build_all()

		html = os.read_file(html_file) or {
			eprintln('Failed to read built file ${html_file}: ${err}')
			return ctx.html('<h1>500 - Server Error</h1>')
		}
	}

	// Inject reload script with polling
	reload_script := '<script>
	(function() {
		var poll = function() {
			fetch("/_velt_reload").then(function(r) { return r.text(); }).then(function(t) {
				if (t === "reload") { console.log("[velt] Reloading..."); location.reload(); }
				else setTimeout(poll, 300);
			}).catch(function() { setTimeout(poll, 1000); });
		};
		poll();
	})();
	</script></body>'

	html = html.replace('</body>', reload_script)

	return ctx.html(html)
}

fn cmd_serve(port int, app &App) ! {
	println('Starting Velt Dev Server at http://localhost:${port}')
	mut mutable_app := unsafe { app }
	mutable_app.mount_static_folder_at('assets', '/assets')!
	veb.run_at[App, Context](mut mutable_app, host: '', port: port)!
}


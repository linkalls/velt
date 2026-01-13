module main

import os

fn main() {
    if os.args.len > 1 {
        match os.args[1] {
            'new' {
                if os.args.len < 3 {
                    println('Usage: velt new <project_name>')
                    return
                }
                cmd_new(os.args[2]) or { panic(err) }
                return
            }
            'dev' {
                watch_and_rebuild()
                return
            }
            'serve' {
                // Parse optional port: velt serve 8080
                mut port := 3000
                if os.args.len >= 3 {
                    port = os.args[2].int()
                    if port == 0 {
                        port = 3000
                    }
                }
                cmd_serve(port) or { panic(err) }
                return
            }
            'build' {
                // Fall through to build logic
            }
            'help', '--help', '-h' {
                print_help()
                return
            }
            else {
                println('Unknown command: ${os.args[1]}')
                print_help()
                return
            }
        }
    }

    // Default action: Build
    do_build()
}

fn do_build() {
    if !os.exists('dist') {
        os.mkdir('dist') or { panic(err) }
    }

    // Copy assets
    if os.exists('assets') {
        // Use cp -r for simplicity
        os.execute('cp -r assets dist/')
    }

    build_all()
}

fn print_help() {
    println('')
    println('  ╭───────────────────────────────────────────╮')
    println('  │              🚀 Velt CLI                  │')
    println('  │   Static Site Generator powered by V      │')
    println('  ╰───────────────────────────────────────────╯')
    println('')
    println('  USAGE:')
    println('    velt <command> [options]')
    println('')
    println('  COMMANDS:')
    println('    new <name>     Create a new Velt project')
    println('    build          Build the site to dist/')
    println('    dev            Watch mode with auto-rebuild')
    println('    serve [port]   Start dev server (default: 3000)')
    println('    help           Show this help message')
    println('')
    println('  EXAMPLES:')
    println('    velt new my-docs')
    println('    velt build')
    println('    velt serve 8080')
    println('')
}

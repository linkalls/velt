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
            'build' {
                // Fall through to build logic
            }
            else {
                // Assuming build if no command or unknown
                println('Unknown command. Usage: velt [new|dev|build]')
                // return // Optional: return or try to build?
            }
        }
    }

    // Default action: Build
    if !os.exists('dist') {
        os.mkdir('dist') or { panic(err) }
    }

    // Copy assets
    if os.exists('assets') {
        // os.cp_r('assets', 'dist/assets')? V's os module might vary.
        // Let's use cp -r via shell for MVP robustness or manual copy.
        // os.cp_all is available in newer V.
        // let's try manual copy or shell.
        os.execute('cp -r assets dist/')
    }

    build_all()
}

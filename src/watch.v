module main

import os
import time

fn watch_and_rebuild() {
    println('Starting development server...')

    build_all()

    println('Watching for changes in content...')

    mut mtimes := map[string]i64{}

    files := os.walk_ext('content', '.vdx')
    for file in files {
        mtimes[file] = os.file_last_mod_unix(file)
    }

    for {
        time.sleep(100 * time.millisecond)

        current_files := os.walk_ext('content', '.vdx')
        for file in current_files {
            mtime := os.file_last_mod_unix(file)
            prev_mtime := mtimes[file] or { 0 }

            if mtime > prev_mtime {
                println('Change detected in ${file}, rebuilding...')
                build_one(file)
                mtimes[file] = mtime
            }
        }
    }
}

fn build_all() {
    files := os.walk_ext('content', '.vdx')
    for file in files {
        build_one(file)
    }
}

fn build_one(file string) {
    println('Processing ${file}...')
    content := os.read_file(file) or {
        println('Error reading file: ${err}')
        return
    }

    segments := parse_velt_file(content)

    // Output path relative to dist/
    // file is like content/index.vdx
    // we want dist/index.html
    // If file is content/sub/page.vdx, we want dist/sub/page.html

    // naive replacement:
    filename := file.replace('content/', '').replace('.vdx', '.html')
    output_path := 'dist/${filename}'

    // Ensure dir exists
    output_dir := os.dir(output_path)
    if !os.exists(output_dir) {
        os.mkdir_all(output_dir) or {}
    }

    code := generate_v_code(segments, output_path, 'default')

    gen_file := 'build_gen.v'
    os.write_file(gen_file, code) or {
        println('Error writing gen file: ${err}')
        return
    }

    // Run V
    // Use env var or default `v`
    v_exe := os.getenv('V_EXE')
    v_cmd := if v_exe != '' { v_exe } else { 'v' }

    // We run in current directory.
    cmd := '${v_cmd} run ${gen_file}'
    res := os.execute(cmd)
    if res.exit_code != 0 {
        println('Error building ${file}:')
        println(res.output)
    } else {
        println('Successfully built ${output_path}')
    }
}

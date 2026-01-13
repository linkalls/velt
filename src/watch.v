module main

import os
import time

fn watch_and_rebuild(cb fn()) {
	println('Starting watcher...')

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
				cb()
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

	// Parse frontmatter (TOML between +++ markers)
	mut layout := 'default'
	mut body := content
	
	if content.starts_with('+++') {
		// Find closing +++
		parts := content.split('+++')
		if parts.len >= 3 {
			frontmatter := parts[1].trim_space()
			// Parse layout from frontmatter
			for line in frontmatter.split_into_lines() {
				if line.contains('layout') && line.contains('=') {
					// Extract value: layout = "landing"
					value := line.split('=')[1].trim_space().replace('"', '').replace("'", '')
					layout = value
					break
				}
			}
			// Body is everything after the second +++
			body = parts[2..].join('+++').trim_space()
		}
	}

	segments := parse_velt_file(body)

	// Output path relative to dist/
	normalized_file := file.replace('\\', '/')
	filename := normalized_file.replace('content/', '').replace('.vdx', '.html')
	output_path := 'dist/${filename}'

	// Ensure dir exists
	output_dir := os.dir(output_path)
	if !os.exists(output_dir) {
		os.mkdir_all(output_dir) or {}
	}

	code := generate_v_code(segments, output_path, layout)

	gen_file := 'build_gen.v'
	os.write_file(gen_file, code) or {
		println('Error writing gen file: ${err}')
		return
	}

	// Run V
	v_exe := os.getenv('V_EXE')
	v_cmd := if v_exe != '' { v_exe } else { 'v' }

	cmd := '${v_cmd} run ${gen_file}'
	res := os.execute(cmd)
	if res.exit_code != 0 {
		println('Error building ${file}:')
		println(res.output)
	} else {
		println('Successfully built ${output_path}')
	}
}


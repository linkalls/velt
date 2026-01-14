module main

import os
import time

fn watch_and_rebuild(cb fn ()) {
	println('Starting watcher...')

	build_all()

	println('Watching for changes in content...')

	mut mtimes := map[string]i64{}
	mut cached_nav_en := ''
	mut cached_nav_ja := ''

	files := os.walk_ext('content', '.vdx')
	for file in files {
		mtimes[file] = os.file_last_mod_unix(file)
	}
	
	// Cache initial navigation
	cached_nav_en = collect_nav_items(files, '')
	cached_nav_ja = collect_nav_items(files, 'ja')

	for {
		time.sleep(200 * time.millisecond)

		current_files := os.walk_ext('content', '.vdx')
		
		// Check if file count changed (new file added or removed)
		if current_files.len != mtimes.keys().len {
			println('File list changed, rebuilding all...')
			build_all()
			mtimes.clear()
			for file in current_files {
				mtimes[file] = os.file_last_mod_unix(file)
			}
			// Update cached navigation
			cached_nav_en = collect_nav_items(current_files, '')
			cached_nav_ja = collect_nav_items(current_files, 'ja')
			cb()
			continue
		}
		
		// Check for modified files - only rebuild changed files
		for file in current_files {
			mtime := os.file_last_mod_unix(file)
			prev_mtime := mtimes[file] or { 0 }

			if mtime > prev_mtime {
				println('Change detected in ${file}')
				// Only rebuild the changed file
				lang := detect_language(file)
				nav_html := if lang == 'ja' { cached_nav_ja } else { cached_nav_en }
				build_one(file, nav_html, lang)
				mtimes[file] = mtime
				cb()
			}
		}
	}
}

// Parallel build all files using V threads
fn build_all() {
	files := os.walk_ext('content', '.vdx')
	
	// Pre-compute navigation for all languages
	nav_html_en := collect_nav_items(files, '')
	nav_html_ja := collect_nav_items(files, 'ja')
	
	// Build files in parallel using threads
	mut threads := []thread{}
	
	for file in files {
		lang := detect_language(file)
		nav_html := if lang == 'ja' { nav_html_ja } else { nav_html_en }
		threads << spawn build_one(file, nav_html, lang)
	}
	
	// Wait for all threads to complete
	threads.wait()
}

// Detect language from filename pattern: name.lang.vdx
fn detect_language(file string) string {
	normalized := file.replace('\\', '/')
	base := normalized.split('/').last() // e.g., "docs.ja.vdx"
	parts := base.replace('.vdx', '').split('.')
	if parts.len >= 2 {
		lang := parts.last()
		if lang == 'ja' || lang == 'en' || lang == 'zh' || lang == 'ko' {
			return lang
		}
	}
	return ''  // Default to English (no suffix)
}

// Collect navigation items from all content files
fn collect_nav_items(files []string, filter_lang string) string {
	mut nav_items := []string{}
	mut dirs := map[string][]string{}
	
	for file in files {
		file_lang := detect_language(file)
		if file_lang != filter_lang {
			continue
		}
		
		content := os.read_file(file) or { continue }
		mut title := ''
		mut layout := 'default'
		
		if content.starts_with('+++') {
			parts := content.split('+++')
			if parts.len >= 3 {
				frontmatter := parts[1].trim_space()
				for line in frontmatter.split_into_lines() {
					if line.contains('=') {
						key := line.split('=')[0].trim_space()
						value := line.split('=')[1].trim_space().replace('"', '').replace("'", '')
						if key == 'title' {
							title = value
						} else if key == 'layout' {
							layout = value
						}
					}
				}
			}
		}
		
		if layout == 'landing' {
			continue
		}
		
		normalized := file.replace('\\', '/')
		html_name := normalized.replace('content/', '').replace('.vdx', '.html')
		
		if title.len == 0 {
			base := html_name.replace('.html', '')
			parts := base.split('/')
			name := parts[parts.len - 1]
			name_parts := name.split('.')
			clean_name := if name_parts.len > 1 && name_parts.last() in ['ja', 'en', 'zh', 'ko'] {
				name_parts[..name_parts.len - 1].join('.')
			} else {
				name
			}
			title = clean_name.replace('_', ' ').replace('-', ' ')
			if title.len > 0 {
				title = title[0..1].to_upper() + title[1..]
			}
		}
		
		dir_parts := html_name.split('/')
		if dir_parts.len > 1 {
			dir_name := dir_parts[0]
			if dir_name !in dirs {
				dirs[dir_name] = []string{}
			}
			dirs[dir_name] << '<a href="/${html_name}">${title}</a>'
		} else {
			nav_items << '<a href="/${html_name}">${title}</a>'
		}
	}
	
	mut result := nav_items.clone()
	
	for dir_name, items in dirs {
		display_name := dir_name[0..1].to_upper() + dir_name[1..].replace('_', ' ').replace('-', ' ')
		mut section := '<div class="nav-section">'
		section += '<div class="nav-section-title">${display_name}</div>'
		for item in items {
			section += item
		}
		section += '</div>'
		result << section
	}
	
	return result.join('\n                ')
}

fn build_one(file string, nav_html string, lang string) {
	println('Processing ${file}...')
	content := os.read_file(file) or {
		println('Error reading file: ${err}')
		return
	}

	mut layout := 'default'
	mut title := ''
	mut date := ''
	mut author := ''
	mut body := content

	if content.starts_with('+++') {
		parts := content.split('+++')
		if parts.len >= 3 {
			frontmatter := parts[1].trim_space()
			for line in frontmatter.split_into_lines() {
				if line.contains('=') {
					key := line.split('=')[0].trim_space()
					value := line.split('=')[1].trim_space().replace('"', '').replace("'", '')
					if key == 'layout' {
						layout = value
					} else if key == 'title' {
						title = value
					} else if key == 'date' {
						date = value
					} else if key == 'author' {
						author = value
					}
				}
			}
			body = parts[2..].join('+++').trim_space()
		}
	}

	normalized_body := body.replace('\r\n', '\n').replace('\r', '\n')
	segments := parse_velt_file(normalized_body)

	normalized_file := file.replace('\\', '/')
	filename := normalized_file.replace('content/', '').replace('.vdx', '.html')
	output_path := 'dist/${filename}'

	output_dir := os.dir(output_path)
	if !os.exists(output_dir) {
		os.mkdir_all(output_dir) or {}
	}

	page_path := '/' + filename
	code := generate_v_code(segments, output_path, layout, title, nav_html, date, author, lang, page_path)

	base_name := filename.replace('/', '_').replace('.html', '')
	gen_file := 'build_gen_${base_name}.v'

	os.write_file(gen_file, code) or {
		println('Error writing gen file: ${err}')
		return
	}

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

	os.rm(gen_file) or {}
}

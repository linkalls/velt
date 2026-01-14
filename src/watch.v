module main

import os
import time

fn watch_and_rebuild(cb fn ()) {
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
				println('Change detected in ${file}, rebuilding all...')
				// Rebuild all to update navigation in all pages
				build_all()
				mtimes[file] = mtime
				cb()
				break // Only need to rebuild once
			}
		}
	}
}

fn build_all() {
	files := os.walk_ext('content', '.vdx')
	// Collect nav items by language
	nav_html_en := collect_nav_items(files, '')      // English (no lang suffix)
	nav_html_ja := collect_nav_items(files, 'ja')    // Japanese
	for file in files {
		// Detect language from filename (e.g., docs.ja.vdx -> ja)
		lang := detect_language(file)
		nav_html := if lang == 'ja' { nav_html_ja } else { nav_html_en }
		build_one(file, nav_html, lang)
	}
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
// Excludes pages with layout="landing" and reflects directory structure
// filter_lang: 'ja', 'en', '' (empty = no language suffix = English)
fn collect_nav_items(files []string, filter_lang string) string {
	mut nav_items := []string{}
	mut dirs := map[string][]string{}  // dir -> list of nav items
	
	for file in files {
		// Filter by language
		file_lang := detect_language(file)
		if file_lang != filter_lang {
			continue
		}
		
		content := os.read_file(file) or { continue }
		mut title := ''
		mut layout := 'default'
		
		// Parse frontmatter to get title and layout
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
		
		// Skip landing layout pages
		if layout == 'landing' {
			continue
		}
		
		// Generate HTML filename
		normalized := file.replace('\\', '/')
		html_name := normalized.replace('content/', '').replace('.vdx', '.html')
		
		// Use filename as fallback title
		if title.len == 0 {
			base := html_name.replace('.html', '')
			// Get last part after /
			parts := base.split('/')
			name := parts[parts.len - 1]
			// Remove language suffix from title (e.g., "docs.ja" -> "docs")
			name_parts := name.split('.')
			clean_name := if name_parts.len > 1 && name_parts.last() in ['ja', 'en', 'zh', 'ko'] {
				name_parts[..name_parts.len - 1].join('.')
			} else {
				name
			}
			title = clean_name.replace('_', ' ').replace('-', ' ')
			// Capitalize first letter
			if title.len > 0 {
				title = title[0..1].to_upper() + title[1..]
			}
		}
		
		// Group by directory
		dir_parts := html_name.split('/')
		if dir_parts.len > 1 {
			// Has directory
			dir_name := dir_parts[0]
			if dir_name !in dirs {
				dirs[dir_name] = []string{}
			}
			dirs[dir_name] << '<a href="/${html_name}">${title}</a>'
		} else {
			// Root level
			nav_items << '<a href="/${html_name}">${title}</a>'
		}
	}
	
	// Build final nav HTML
	mut result := nav_items.clone()
	
	// Add directory sections
	for dir_name, items in dirs {
		// Capitalize directory name for display
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

	// Parse frontmatter (TOML between +++ markers)
	mut layout := 'default'
	mut title := ''
	mut date := ''
	mut author := ''
	mut body := content

	if content.starts_with('+++') {
		// Find closing +++
		parts := content.split('+++')
		if parts.len >= 3 {
			frontmatter := parts[1].trim_space()
			// Parse frontmatter fields
			for line in frontmatter.split_into_lines() {
				if line.contains('=') {
					key := line.split('=')[0].trim_space()
					value := line.split('=')[1].trim_space().replace('"', '').replace("'",
						'')
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
			// Body is everything after the second +++
			body = parts[2..].join('+++').trim_space()
		}
	}

	// Normalize line endings (Windows CRLF -> LF)
	normalized_body := body.replace('\r\n', '\n').replace('\r', '\n')
	segments := parse_velt_file(normalized_body)

	// Output path relative to dist/
	normalized_file := file.replace('\\', '/')
	filename := normalized_file.replace('content/', '').replace('.vdx', '.html')
	output_path := 'dist/${filename}'

	// Ensure dir exists
	output_dir := os.dir(output_path)
	if !os.exists(output_dir) {
		os.mkdir_all(output_dir) or {}
	}

	// Compute page path for language switcher (e.g., docs.ja.html -> docs.html for EN, docs.html -> docs.ja.html for JA)
	page_path := '/' + filename
	code := generate_v_code(segments, output_path, layout, title, nav_html, date, author, lang, page_path)

	// Use unique temp file name based on source file to avoid race conditions
	// when building multiple files concurrently
	base_name := filename.replace('/', '_').replace('.html', '')
	gen_file := 'build_gen_${base_name}.v'
	gen_exe := 'build_gen_${base_name}.exe'

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

	// Clean up temp files (temporarily disabled for debugging)
	// os.rm(gen_file) or {}
	// os.rm(gen_exe) or {}
}

module main

// i18n helper functions for filename-based localization
// Files can be named: docs.vdx (default/en), docs.ja.vdx (Japanese)

// Get language code from filename
// e.g., "content/docs.ja.vdx" -> "ja", "content/docs.vdx" -> ""
fn get_lang_from_filename(file string) string {
    base := file.replace('\\', '/').all_after_last('/').replace('.vdx', '')
    parts := base.split('.')
    if parts.len >= 2 {
        lang := parts[parts.len - 1]
        // Known language codes
        if lang in ['ja', 'en', 'zh', 'ko', 'es', 'fr', 'de','cn'] {
            return lang
        }
    }
    return ''
}

// Get base filename without language suffix
// e.g., "docs.ja" -> "docs", "docs" -> "docs"
fn get_base_name(file string) string {
    base := file.replace('\\', '/').all_after_last('/').replace('.vdx', '')
    parts := base.split('.')
    if parts.len >= 2 {
        lang := parts[parts.len - 1]
        if lang in ['ja', 'en', 'zh', 'ko', 'es', 'fr', 'de','cn'] {
            return parts[..parts.len - 1].join('.')
        }
    }
    return base
}

// Generate output path for a given file
// e.g., "content/docs.ja.vdx" -> "dist/docs.ja.html"
fn get_output_path(file string) string {
    normalized := file.replace('\\', '/').replace('content/', '')
    html_name := normalized.replace('.vdx', '.html')
    return 'dist/${html_name}'
}

// Get alternate language versions for a given file
// Returns map of lang_code -> relative_url
fn get_lang_alternatives(file string, all_files []string) map[string]string {
    mut alternatives := map[string]string{}
    base_name := get_base_name(file)
    file_dir := file.replace('\\', '/').all_before_last('/')
    
    for f in all_files {
        other_base := get_base_name(f)
        other_dir := f.replace('\\', '/').all_before_last('/')
        
        if other_base == base_name && other_dir == file_dir {
            lang := get_lang_from_filename(f)
            if lang == '' {
                alternatives['en'] = '/${other_base}.html'
            } else {
                alternatives[lang] = '/${other_base}.${lang}.html'
            }
        }
    }
    
    return alternatives
}

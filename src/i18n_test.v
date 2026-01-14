module main

import os

fn test_get_lang_from_filename() {
	assert get_lang_from_filename('content/docs.ja.vdx') == 'ja'
	assert get_lang_from_filename('content/docs.vdx') == ''
	assert get_lang_from_filename('content/guides/themes.ja.vdx') == 'ja'
	assert get_lang_from_filename('content/guides/themes.en.vdx') == 'en'
	assert get_lang_from_filename('content/file.test.vdx') == '' // 'test' is not a known lang
}

fn test_get_base_name() {
	assert get_base_name('content/docs.ja.vdx') == 'docs'
	assert get_base_name('content/docs.vdx') == 'docs'
	assert get_base_name('content/guides/themes.ja.vdx') == 'themes'
	assert get_base_name('content/my.file.ja.vdx') == 'my.file'
}

fn test_get_output_path() {
	assert get_output_path('content/docs.ja.vdx') == 'dist/docs.ja.html'
	assert get_output_path('content/docs.vdx') == 'dist/docs.html'
	assert get_output_path('content/guides/themes.ja.vdx') == 'dist/guides/themes.ja.html'
}

fn test_get_lang_alternatives() {
	files := [
		'content/docs.vdx',
		'content/docs.ja.vdx',
		'content/other.vdx',
	]

	alts := get_lang_alternatives('content/docs.vdx', files)
	assert 'en' in alts
	assert 'ja' in alts
	assert alts['en'] == '/docs.html'
	assert alts['ja'] == '/docs.ja.html'
}

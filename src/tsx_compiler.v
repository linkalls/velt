
module main

import os

// TSX Compiler - Compiles .tsx components to HTML using Bun/esbuild
// This is a build-time transpilation, not runtime

struct TsxCompiler {
    project_dir string
}

fn new_tsx_compiler(project_dir string) TsxCompiler {
    return TsxCompiler{
        project_dir: project_dir
    }
}

// Check if Bun is available
fn (c TsxCompiler) check_bun() bool {
    result := os.execute('bun --version')
    return result.exit_code == 0
}

// Compile a TSX component to HTML string
// Returns the rendered HTML output
fn (c TsxCompiler) compile_component(component_path string, props map[string]string) !string {
    if !os.exists(component_path) {
        return error('TSX component not found: ${component_path}')
    }

    // Create a temporary runner script
    mut props_json := '{'
    for key, value in props {
        props_json += '"${key}": "${value}",'
    }
    if props_json.len > 1 {
        props_json = props_json[..props_json.len - 1]  // Remove trailing comma
    }
    props_json += '}'

    runner_code := '
import { renderToString } from "react-dom/server";
import Component from "./${os.base(component_path)}";

const props = ${props_json};
const html = renderToString(<Component {...props} />);
console.log(html);
'

    runner_path := os.join_path(os.dir(component_path), '_velt_tsx_runner.tsx')
    os.write_file(runner_path, runner_code)!
    defer { os.rm(runner_path) or {} }

    // Run with Bun
    result := os.execute('bun run ${runner_path}')
    if result.exit_code != 0 {
        return error('TSX compilation failed: ${result.output}')
    }

    return result.output.trim_space()
}

// Find all TSX components in the components directory
fn (c TsxCompiler) find_tsx_components() []string {
    components_dir := os.join_path(c.project_dir, 'components')
    if !os.exists(components_dir) {
        return []
    }

    mut tsx_files := []string{}
    files := os.ls(components_dir) or { return [] }
    for file in files {
        if file.ends_with('.tsx') {
            tsx_files << os.join_path(components_dir, file)
        }
    }
    return tsx_files
}

// Get component name from file path
fn get_component_name(file_path string) string {
    base := os.base(file_path)
    return base.replace('.tsx', '').replace('.v', '')
}

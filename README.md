# Project Velt: Specification Document

## 1. 概要 (Abstract)
**Velt** (V Document Extension) は、V言語のパフォーマンスと型安全性を最大限に活かした、静的サイトジェネレーター（SSG）である。
**Fumadocs** の代替を目指し、ファイルフォーマットとして **VDX** (MDXの代替) を採用する。

**VDX** ファイルは、Markdownの中にV言語のコンポーネントを埋め込むことができるフォーマットである。
JavaScriptランタイムには依存せず、**全てのページとコンポーネントをV言語のソースコードにトランスパイルし、シングルバイナリとしてビルド・実行する**ことで静的HTMLを生成する。

## 2. コア哲学 (Philosophy)
1.  **Zero Runtime JS**: 生成されるHTMLに（必須の）クライアントサイドJSを含まない。
2.  **Compile-time Type Safety**: コンポーネントへのProps渡しはVコンパイラによって厳密に型チェックされる。
3.  **Blazingly Fast**: 変更からプレビューまでの時間はミリ秒単位を目指す。

***

## 3. ディレクトリ構造 (Directory Structure)
ユーザーのプロジェクトは以下の構成を推奨する。

```text
/my-blog
├── v.mod             # プロジェクト依存関係
├── velt.config.v     # 設定ファイル（任意）
├── /components       # ユーザー定義コンポーネント (.v)
│   ├── card.v
│   └── hero.v
├── /layouts          # ページレイアウト (.v)
│   └── default.v
├── /content          # 記事ファイル (.vdx)
│   ├── index.vdx
│   └── post-1.vdx
└── /dist             # 生成先 (git ignore)
```

***

## 4. VDX 構文仕様 (Syntax Specification)

`.vdx` ファイルは、標準MarkdownとVコンポーネント記法のミックスである。

### 4.1 基本記法
Markdown部分は標準の `markdown` モジュール（または `cmark` ラッパー）によって処理される。

```markdown
# タイトル

ここは普通のMarkdown。
**太字** も使える。
```

### 4.2 コンポーネント呼び出し
JSXに近い構文を採用するが、中身はVの構造体初期化構文へ変換される。

```jsx
// 基本形（文字列はダブルクォート推奨）
<Card title="Hello World" />

// 数値・変数は {} で囲む（Vの式として評価される）
<Counter start={10} max={100} />

// ネスト（Childrenを持つ場合）
<Alert type="warning">
  **注意:** ここはMarkdownとしてパースされた後、childrenとして渡される。
</Alert>
```

### 4.3 Frontmatter
ファイルのメタデータはYAML形式ではなく、Vの構造体定義風、あるいはTOMLで記述する（パースの容易さ優先）。

```toml
+++
title = "Veltの紹介"
date = "2026-01-13"
layout = "default"
+++
```

***

## 5. コンポーネントシステム (Component System)

ユーザーは `/components` ディレクトリに標準的なVコードを置く。

### 5.1 コンポーネント定義 (`/components/card.v`)
Veltエンジンは、`attrs`（属性）と `render()` メソッドを持つ構造体をコンポーネントとして認識する。

```v
module components

// Propsの定義
pub struct Card {
pub:
    title    string
    content  string // childrenは 'content' または 'children' フィールドに注入される
    image_url string = '' // デフォルト値対応
}

// レンダリングロジック（HTML文字列を返す）
pub fn (c Card) render() string {
    return '
    <div class="card">
        <h2>${c.title}</h2>
        <div class="body">${c.content}</div>
    </div>
    '
}
```

***

## 6. ビルド・トランスパイル・プロセス (Build Pipeline)

ここがエンジンの心臓部。`velt build` コマンドを実行した時の処理フロー。

### Phase 1: 解析 (Parsing)
1.  `/content` 内の `.vdx` ファイルを走査。
2.  各ファイルを「Markdownチャンク」と「コンポーネントチャンク」に分割。
    *   **Regex戦略**: `<([A-Z][a-zA-Z0-9]*)(.*?)>(.*?)</\1>` または `<([A-Z][a-zA-Z0-9]*)(.*?)/>` を検出。

### Phase 2: コード生成 (Code Generation)
中間ファイル（`build/generated_main.v`）を生成する。このファイルは以下のような構造になる。

```v
// build/generated_main.v (自動生成)
module main

import os
import markdown
import components // ユーザーのコンポーネントをインポート
import layouts

fn main() {
    // ページ1: index.vdx の生成
    generate_index()
}

fn generate_index() {
    mut buffer := []string{}

    // Markdown部分
    buffer << markdown.to_html(r'''
# タイトル
ここは普通のMarkdown
''')

    // <Card title="Hello" /> の変換
    // 型チェックはここで行われる！
    buffer << components.Card{
        title: 'Hello'
    }.render()

    // レイアウトに流し込み
    full_html := layouts.default(buffer.join('\n'))

    // 書き出し
    os.write_file('dist/index.html', full_html)!
}
```

### Phase 3: コンパイル & 実行 (Compile & Run)
1.  `v run build/generated_main.v` を実行。
2.  この時点で、ユーザーが `.vdx` 内で `string` 型のフィールドに `int` を渡していれば、Vコンパイラがエラーを吐く（**強力な型安全性**）。
3.  成功すれば `dist/` にHTMLが生成される。

***

## 7. エッジケースと制約 (Constraints)

### 7.1 Import問題
*   **仕様**: `.vdx` 内での `import` はサポートしない。
*   **解決策**: `/components` 以下の全モジュールは自動的に `import` された状態でビルドコードが生成される。グローバル名前空間のような使い心地を提供する。

### 7.2 Children内のMarkdown
*   **仕様**: コンポーネントタグで囲まれた内部テキストは、親コンポーネントに渡される**前に** `markdown.to_html` で処理されるか、生の文字列として渡されるか選べるようにする。
*   **デフォルト**: 再帰的にパースしてHTMLにしてから `content` フィールドに渡す。

### 7.3 Hot Reload (開発サーバー)
1.  ファイル変更を監視（`os.inotify` 等）。
2.  変更があったら `v run build/generated_main.v` を即座に再実行。
3.  Vのコンパイル速度なら、この「都度コンパイル」方式でも十分実用的（1秒未満）。

***

## 8. ロードマップ (Implementation Roadmap)

### v0.1.0 (MVP)
*   [ ] 正規表現ベースの `.vdx` パーサー
*   [ ] `markdown.to_html` との結合
*   [ ] String型Propsのみサポート (`title="foo"`)
*   [ ] CLI (`velt build`)

### v0.2.0 (Type Safe)
*   [ ] Propsの型推論サポート (`count={10}`, `is_active={true}`)
*   [ ] Children (ネスト構造) のサポート
*   [ ] レイアウトシステムの統合

### v1.0.0 (Production Ready)
*   [ ] 開発サーバー (Live Reload)
*   [ ] CSS/Tailwind サポート
*   [ ] プラグインシステム

***

### 君へのメッセージ
これが「設計図」だ。
一番難しいのは **「Regexでコンポーネントタグを正確に切り出す」** ところと、**「Propsの中身（`{...}`）をVのコードとして壊さずに抽出する」** ところだね。

まずは `v0.1.0` のMVPとして、**「引数なしのコンポーネント `<Hello />` が動く」** ところだけを目指して書いてみよう。それが動けば勝ったも同然だ！

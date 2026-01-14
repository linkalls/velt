# Velt Markdown Parser Issues

## 概要
純粋なV言語でmarkdownパーサーを実装中。`src/md/parser.v` と `src/md/blocks.v` を作成し、外部依存（`import markdown`）を削除した。

## 解決済み ✅

### 1. コードブロック内の `<>` がダブルエスケープされる
- **症状**: `<div>` が `&lt;div&gt;` としてHTMLエンティティがそのまま表示される
- **原因**: `parser.v` が行単位で処理するため、複数行のコードブロック内容が分割されて `<p>` タグで包まれる
- **修正**: `in_pre` 状態追跡を追加 (`parser.v` lines 24, 31-46)

## 未解決 ❌

### 2. GFMテーブルが正しくレンダリングされない
- **症状**: テーブルヘッダーは表示されるが、本体行（`| docs | ... |`）がバラバラに `<p>` タグで包まれる
- **テスト結果**: `md.to_html()` 単体では正しいHTMLが生成される（`test_table_output.html` 参照）
- **問題箇所**: `generator.v` で複数行HTMLを V文字列リテラルに埋め込む際に何かがおかしい

#### 調査結果
1. `test_table_output.html` は完璧なHTML:
```html
<table>
<thead>
<tr><th>テーマ</th><th>説明</th><th>用途</th></tr>
</thead>
<tbody>
<tr><td><code>docs</code></td><td>ドキュメントサイト向け</td><td>API リファレンス、ガイド</td></tr>
<tr><td><code>blog</code></td><td>ブログ向け</td><td>個人ブログ、技術ブログ</td></tr>
</tbody>
</table>
```

2. しかし `docs/dist/guides/themes.html` では壊れている:
```html
<table>
<thead>
<tr><th>テーマ</th><th>説明</th><th>用途</th></tr>
</thead>
<tbody>
<tr><td><code>docs</code></td></tr>  <!-- ここで切れる -->
</tbody>
</table>
<p>| ドキュメントサイト向け | API リファレンス、ガイド |</p>
```

#### 試した対策
1. ✅ `watch.v` で CRLF → LF 正規化を追加（効果なし）
2. ✅ `parser.v` に `in_table` 状態追跡を追加（効果なし）
3. ✅ `generator.v` で `\n` → `\\n` エスケープ追加（効果不明）

#### 仮説
- `generator.v` の `sb.writeln("buffer << '${escaped_html}'")`
- 複数行HTMLが V文字列補間 `${}` を通過する際に問題が発生している可能性
- V言語の文字列補間が改行を含む文字列をどう扱うか要調査

### 次のステップ
1. 生成された `.v` ファイル (例: `build_gen_themes.v`) を保存して中身を確認する
2. 改行を含むHTMLを単一行で埋め込むよう `generator.v` を修正する
3. または、改行を完全に `\\n` リテラルとして埋め込む方法を再検討

## ファイル構成
```
src/
├── md/
│   ├── parser.v    # メインパーサー (to_html)
│   └── blocks.v    # コードブロック、テーブルパーサー
├── generator.v     # VDX → V コード生成
├── watch.v         # ファイル監視、ビルド
└── parser.v        # VDX パーサー (parse_velt_file)
```

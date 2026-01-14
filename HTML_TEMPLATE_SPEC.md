# HTML テンプレートコンポーネント仕様書

## 1. 概要 (Overview)
Velt バイナリ単体（Vコンパイラなし）で利用するユーザー向けに、簡易的なコンポーネント拡張機能を提供する。
ユーザーは `components/` ディレクトリに `.html` ファイルを配置することで、独自のコンポーネントを定義できる。

これは「90%のユースケースはビルトインでカバーし、残りの10%を簡易なHTML置換で解決する」という戦略に基づく。

## 2. ファイル配置 (File Structure)
標準のコンポーネントディレクトリに `.html` ファイルを置く。

```text
/my-project
├── /components
│   ├── button.html      # <Button /> コンポーネントになる
│   └── card.html        # <Card /> コンポーネントになる
└── /content
    └── index.vdx
```

## 3. 構文仕様 (Syntax Specification)

### 3.1 定義側 (`components/button.html`)
Mustache風の `{{ variable }}` 構文を使用する。

```html
<!-- components/button.html -->
<a href="{{ url }}" class="btn {{ type }}">
    {{ children }}
</a>
```

*   `{{ children }}`: コンポーネントの内部コンテンツ（スロット）が挿入される予約語。
*   `{{ prop_name }}`: `<Component prop_name="..." />` で渡された値に置換される。

### 3.2 利用側 (`content/index.vdx`)
通常の V コンポーネントと同様に呼び出す。

```jsx
<Button url="https://example.com" type="primary">
  クリックしてね
</Button>
```

## 4. 動作仕様 (Behavior)

### 4.1 優先順位
コンポーネント名の解決は以下の順序で行う。

1.  **Velt 内蔵コンポーネント** (e.g., `Callout`, `CodeBlock`)
2.  **ユーザー定義 V コンポーネント** (`components/*.v` - Vコンパイラがある場合のみ)
3.  **ユーザー定義 HTML テンプレート** (`components/*.html`)

### 4.2 レンダリングプロセス (Runtime Replacement)
Velt バイナリはビルド時（`velt build`）に以下の処理を行う。

1.  `components/*.html` を読み込み、メモリ上にキャッシュする。
2.  `.vdx` パース時に未知のタグ（例: `<Button>`）を検出する。
3.  キャッシュされたテンプレート (`button.html`) を探す。
4.  単純な文字列置換を行う。
    *   `{{ url }}` → `"https://example.com"`
    *   `{{ children }}` → `"クリックしてね"` (Markdownパース後のHTML)
5.  置換後のHTML文字列を生成結果に埋め込む。

## 5. 制約事項 (Constraints)

*   **ロジックなし**: `if` 文や `for` ループなどの制御構文はサポートしない（当面は単純置換のみ）。
*   **安全性**: ユーザー入力のエスケープ処理（XSS対策）は、挿入される値に対して自動的に行われるべきである（実装要検討）。
*   **パフォーマンス**: 正規表現または単純な文字列探索による置換のため、複雑なネストには不向きだが、単純なUIパーツには十分高速である。

## 6. 将来の拡張 (Future Scope)
*   **デフォルト値**: `{{ type="default" }}` のような記法でデフォルト値を定義可能にするか検討。
*   **条件分岐**: クラスの切り替え程度 (`{{? is_active }}`) の超簡易な条件分岐を入れるか。

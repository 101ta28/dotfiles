# DESIGN.md — [サービス名]

日本語UIを実装・レビューするためのデザイン仕様テンプレートです。UIに関係する作業でのみ使用します。`TBD` は未確定値であり、実装上の制約ではありません。既存のコード、デザイントークン、computed style、提供された画像から確認できない値を推測で埋めないでください。

## Usage & Evidence

仕様を埋めるときは、次の優先順で根拠を採用します。

1. ユーザーが明示した要件
2. リポジトリ内のデザイントークンと共通コンポーネント
3. 対象画面の実装とブラウザの computed style
4. 提供されたデザインファイルやスクリーンショット

矛盾がある場合は勝手に統合せず、影響が小さく可逆なら既存実装を維持し、結果を報告してください。ブランドやアクセシビリティに関わる重要な矛盾は確認を求めてください。

## 1. Product Intent

- **対象ユーザー**: TBD
- **主要タスク**: TBD
- **デザイン方針**: TBD
- **情報密度**: TBD
- **キーワード**: TBD（3〜5語）
- **避ける印象**: TBD

## 2. Reference Sources

- **デザイントークン**: TBD（リポジトリ相対パス）
- **共通コンポーネント**: TBD（リポジトリ相対パス）
- **基準画面・ルート**: TBD
- **デザインファイル・画像**: TBD
- **対象ブラウザ・端末**: TBD
- **アクセシビリティ目標**: WCAG 2.2 AA / TBD

## 3. Design Tokens

### Colors

実際に使用する値だけを記載します。色名ではなく役割で管理し、前景色と背景色の組み合わせも明示してください。

| Token | Value | Role | Required pairing |
|---|---:|---|---|
| `color-primary` | TBD | 主要CTA、選択状態 | TBD |
| `color-primary-hover` | TBD | ホバー状態 | TBD |
| `color-text` | TBD | 本文 | TBD |
| `color-text-muted` | TBD | 補足 | TBD |
| `color-border` | TBD | 境界線 | TBD |
| `color-background` | TBD | ページ背景 | TBD |
| `color-surface` | TBD | カード、モーダル | TBD |
| `color-danger` | TBD | エラー、破壊的操作 | TBD |
| `color-warning` | TBD | 警告 | TBD |
| `color-success` | TBD | 成功 | TBD |

### Typography

フォント名とフォールバック順は既存CSSから転記します。日本語と欧文の順序を慣例だけで変更しないでください。

- **Sans family**: TBD
- **Serif family**: TBD / 使用しない
- **Monospace family**: TBD

| Role | Family | Size | Weight | Line height | Letter spacing |
|---|---|---:|---:|---:|---:|
| Display | TBD | TBD | TBD | TBD | TBD |
| Heading 1 | TBD | TBD | TBD | TBD | TBD |
| Heading 2 | TBD | TBD | TBD | TBD | TBD |
| Heading 3 | TBD | TBD | TBD | TBD | TBD |
| Body | TBD | TBD | TBD | TBD | TBD |
| Caption | TBD | TBD | TBD | TBD | TBD |

### Spacing, Radius & Elevation

| Token | Value | Typical use |
|---|---:|---|
| `space-xs` | TBD | TBD |
| `space-sm` | TBD | TBD |
| `space-md` | TBD | TBD |
| `space-lg` | TBD | TBD |
| `space-xl` | TBD | TBD |
| `radius-sm` | TBD | TBD |
| `radius-md` | TBD | TBD |
| `radius-lg` | TBD | TBD |
| `shadow-1` | TBD | TBD |
| `shadow-2` | TBD | TBD |

## 4. Layout & Responsive Behavior

- **Container max width**: TBD
- **Horizontal padding**: TBD
- **Grid columns / gutter**: TBD
- **Content alignment**: TBD

| Breakpoint | Width or condition | Behavior change |
|---|---:|---|
| Compact | TBD | TBD |
| Medium | TBD | TBD |
| Wide | TBD | TBD |

ブレークポイントは端末名だけで決めず、コンテンツが崩れる幅を基準にします。各幅で、ナビゲーション、表、フォーム、モーダル、長い日本語文言がどう変化するかを記載してください。

## 5. Japanese Typography

- 通常の本文では既存の `font-family`、`line-height`、`letter-spacing` を維持します。
- CJKの禁則処理が必要な箇所では `line-break` を検討し、長いURLや識別子の折り返しは `overflow-wrap` で個別に扱います。
- `word-break: break-all` を本文の既定値にしません。語中やURLの任意位置での分割が必要な限定箇所でのみ使用します。
- `font-feature-settings` を使う場合は一つの宣言に必要な機能をまとめ、既存値を上書きしないことを確認します。
- `palt`、縦書き、明朝体は、ブランド要件または既存実装がある場合だけ指定します。

必要な場合の実値を記載します。

```css
font-family: TBD;
line-height: TBD;
letter-spacing: TBD;
line-break: TBD;
overflow-wrap: TBD;
font-feature-settings: TBD;
```

## 6. Components & States

各コンポーネントは外観だけでなく、状態と挙動を定義してください。既存の共通コンポーネントがあれば再利用します。

| Component | Variants | Required states | Source |
|---|---|---|---|
| Button | TBD | default, hover, focus-visible, active, disabled, loading | TBD |
| Input | TBD | default, focus, invalid, disabled, read-only | TBD |
| Select / Combobox | TBD | closed, open, focused, invalid, disabled | TBD |
| Card | TBD | default, interactive, selected | TBD |
| Dialog | TBD | open, initial focus, closing | TBD |
| Table / List | TBD | loading, empty, error, selected | TBD |

コンポーネント固有の寸法、色、余白、角丸、影、アイコン、アニメーションは、ここまたは参照先のトークンに一度だけ記載します。

## 7. Accessibility & Interaction

- 通常テキストは背景に対して4.5:1以上、大きなテキストは3:1以上のコントラストを確保します。
- UIコンポーネントや意味のあるグラフィックの境界・状態は、必要な隣接色に対して3:1以上を確保します。
- 色だけで状態やエラーを伝えません。
- キーボード操作、論理的なフォーカス順、視認可能な `:focus-visible` を実装します。
- WCAG 2.2 AAのポインターターゲットは原則24×24 CSS px以上、または規定の間隔・例外を満たします。重要または頻繁な操作では44×44 CSS pxを目標にします。
- テキストを200%に拡大しても情報や操作を失わないようにします。
- 動きがある場合は `prefers-reduced-motion` に対応し、操作完了に不要な動きを減らします。
- loading、empty、error、success、disabled の各状態を、対象コンポーネントに応じて確認します。

## 8. Do / Avoid

### Do

- 既存トークンと共通コンポーネントを優先する。
- 数値や禁止事項には、コード、デザイン資料、または検証結果の根拠を持たせる。
- 日本語の長文、長い固有名詞、URL、数値、和欧混植でレイアウトを確認する。
- 変更対象とその周辺を実際のブラウザで確認する。

### Avoid

- `TBD` を推測値に置き換える。
- 要求されていない全面的なリデザインや新しいデザイン言語を導入する。
- 単一のスクリーンショットだけから見えない状態やレスポンシブ挙動を断定する。
- 色、フォント、余白、角丸、影をコンポーネントごとに重複定義する。
- ホバー状態だけを実装し、キーボード・タッチ・エラー状態を省略する。

## 9. Implementation Handoff

UI実装を依頼するときは、次を一度ずつ明示します。

- **Goal**: 実現するユーザー操作または画面
- **Context**: 対象ファイル、ルート、既存コンポーネント
- **Hard constraints**: 変更範囲、維持する挙動、禁止事項
- **Evidence**: デザイン資料、スクリーンショット、computed style、トークン
- **Success criteria**: 対象幅、状態、操作、アクセシビリティ、視覚差分
- **Validation**: 実行するテスト、ブラウザ確認、スクリーンショット比較

実装後は、対象のテストと静的チェックに加え、定義した各ビューポートと状態をブラウザで確認します。目視確認できなかった項目、推測を避けて維持した既存値、残る差異を結果に明記してください。

# Supabase セットアップ手順（Heroコンテンツ管理）

トップページの Hero（ファーストビュー）の文言を、管理画面から編集し Supabase に保存できるようにするための手順です。
**コードはすべて実装済み**なので、以下の「あなたがやること」だけ行えば有効化されます。
未設定のあいだも、サイトは初期文言で正常に表示されます（フォールバック）。

---

## あなたがやること（3ステップ）

### 1. Supabase プロジェクトを用意し、キーを取得

1. https://supabase.com にログインし、プロジェクトを作成（無料枠でOK）。
2. 左メニュー **Project Settings → API** を開き、以下3つを控える:
   - **Project URL**（例：`https://xxxx.supabase.co`）
   - **anon public** key
   - **service_role** key（＝秘密キー。公開厳禁）

> ⚠️ アカウント作成・キーの取得は、セキュリティ上わたし（AI）では行えません。ご自身で取得してください。

### 2. テーブルを作成（SQLを実行）

Supabase ダッシュボード **SQL Editor** で、リポジトリ内の
[`supabase/schema.sql`](./supabase/schema.sql) の内容を貼り付けて **Run**。
`hero_content` テーブルが作られ、初期文言が1行入ります。

### 3. 環境変数を設定

プロジェクト直下でテンプレートをコピー:

```bash
cp .env.local.example .env.local
```

`.env.local` を開き、ステップ1の値を貼り付け:

```
NEXT_PUBLIC_SUPABASE_URL=https://xxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=（anon public key）
SUPABASE_SERVICE_ROLE_KEY=（service_role key）
```

保存したら開発サーバーを再起動:

```bash
npm run dev
```

---

## 動作確認

1. `http://localhost:3000/admin/hero` を開く（管理画面 → 「Heroコンテンツ」）。
2. 未設定時に出ていた黄色い警告バナーが消えていることを確認。
3. 文言を編集 → 右のプレビューが即時更新される。
4. **保存する** をクリック → 「保存しました」表示。
5. `http://localhost:3000/` を再読み込み → Hero の文言が変わっていれば成功。

---

## 仕組み（実装メモ）

| 要素 | ファイル | 役割 |
|---|---|---|
| クライアント生成 | `src/lib/supabase.ts` | anon（読取）/ service_role（書込）を出し分け。未設定なら `null` |
| 取得ロジック | `src/lib/hero.ts` | DBから取得、失敗時は既定値へフォールバック |
| 型・既定値 | `src/lib/hero-content.ts` | `HeroContent` 型と初期文言（外部依存なし） |
| 保存処理 | `src/app/actions/hero.ts` | Server Action。service_role で `upsert` → `revalidatePath('/')` |
| 公開表示 | `src/components/site/hero.tsx` | サーバー側でDB取得して描画 |
| 編集UI | `src/components/admin/hero-editor.tsx` | フォーム＋ライブプレビュー |
| DBスキーマ | `supabase/schema.sql` | テーブル定義・初期データ・RLS |

### セキュリティ上の注意
- 書き込みは **service_role キー（サーバー専用）** のみ。`NEXT_PUBLIC_` を付けていないのでブラウザには渡りません。
- 公開読み取りは RLS の SELECT ポリシーで許可、書き込みポリシーは作っていない（＝anonキーでは書けない）。
- **この管理画面は認証なし（研修用）** です。本番運用する場合は、`/admin` に必ずログイン認証を追加してください（Supabase Auth 等）。

-- ============================================================
-- LandBridge サイト : Hero コンテンツ用スキーマ
-- Supabase ダッシュボード → SQL Editor に貼り付けて実行してください。
-- ============================================================

-- 1) テーブル作成（1行だけ持つ想定。id='default' 固定）
create table if not exists public.hero_content (
  id              text primary key default 'default',
  badge           text not null default '',
  title_lead      text not null default '',
  title_highlight text not null default '',
  title_tail      text not null default '',
  description     text not null default '',
  primary_cta     text not null default '',
  secondary_cta   text not null default '',
  updated_at      timestamptz not null default now()
);

-- 2) 初期データ投入（サイトの初期文言）。既に存在すれば何もしない。
insert into public.hero_content (
  id, badge, title_lead, title_highlight, title_tail,
  description, primary_cta, secondary_cta
) values (
  'default',
  '生成AIネイティブなプロダクトカンパニー',
  'テクノロジーで、',
  '次の可能性',
  'へ橋を架ける。',
  'LandBridge は、生成AIとソフトウェアエンジニアリングを軸に、アイデアの構想からプロダクトの内製化までを一気通貫で支援します。課題と成果のあいだに、確かな「橋」を。',
  '無料で相談する',
  '事業内容を見る'
)
on conflict (id) do nothing;

-- 3) Row Level Security（RLS）を有効化
alter table public.hero_content enable row level security;

-- 4) 公開読み取りポリシー（anon / authenticated が SELECT 可能）
--    ※ 書き込みは service_role キー（RLSをバイパス）でのみ行うため、
--      INSERT/UPDATE ポリシーはあえて作らない = 一般公開キーでは書き込めない。
drop policy if exists "hero public read" on public.hero_content;
create policy "hero public read"
  on public.hero_content
  for select
  using (true);

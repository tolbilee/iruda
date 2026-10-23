create table if not exists public.sabo (
  id uuid primary key default gen_random_uuid(),
  reporter text not null,
  dateline text,
  assignment text,
  assignment_time text,
  body text,
  image_path text not null,
  image_url text not null,
  template_id text,
  template_name text,
  event text not null default '2026-접견례',
  created_at timestamptz not null default now()
);

create index if not exists sabo_created_at_idx
  on public.sabo (created_at desc);

alter table public.sabo enable row level security;

drop policy if exists "누구나 사보를 읽는다" on public.sabo;
drop policy if exists "누구나 사보를 남긴다" on public.sabo;

create policy "누구나 사보를 읽는다"
  on public.sabo for select
  to anon, authenticated
  using (true);

create policy "누구나 사보를 남긴다"
  on public.sabo for insert
  to anon, authenticated
  with check (true);

insert into storage.buckets (id, name, public)
values ('sabo', 'sabo', true)
on conflict (id) do update set public = true;

drop policy if exists "사보 사진은 누구나 본다" on storage.objects;
drop policy if exists "사보 사진은 누구나 올린다" on storage.objects;

create policy "사보 사진은 누구나 본다"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'sabo');

create policy "사보 사진은 누구나 올린다"
  on storage.objects for insert
  to anon, authenticated
  with check (
    bucket_id = 'sabo'
    and (storage.extension(name) in ('jpg', 'jpeg', 'png', 'webp'))
  );

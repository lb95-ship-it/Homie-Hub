-- Homie Hub backend. Paste this whole file into Supabase > SQL Editor > New query > Run.
-- Safe to run more than once.

create table if not exists public.hub_items (
  group_code text not null,
  kind       text not null,
  id         text not null,
  ord        int  not null default 0,
  data       jsonb not null,
  updated_at timestamptz not null default now(),
  primary key (group_code, kind, id)
);

-- Lock the table. The app can only reach it through the two functions below,
-- and both require the group code, so nobody can browse other groups' rows.
alter table public.hub_items enable row level security;
revoke all on public.hub_items from anon, authenticated;

create or replace function public.hub_pull(p_code text)
returns jsonb
language plpgsql security definer set search_path = public
as $$
begin
  if p_code is null or length(p_code) < 6 then raise exception 'group code too short'; end if;
  return coalesce(
    (select jsonb_agg(jsonb_build_object('kind', kind, 'id', id, 'ord', ord, 'data', data))
       from public.hub_items where group_code = p_code),
    '[]'::jsonb);
end $$;

create or replace function public.hub_push(p_code text, p_upserts jsonb, p_deletes jsonb)
returns void
language plpgsql security definer set search_path = public
as $$
begin
  if p_code is null or length(p_code) < 6 then raise exception 'group code too short'; end if;

  insert into public.hub_items (group_code, kind, id, ord, data)
  select p_code, e.v->>'kind', e.v->>'id', coalesce((e.v->>'ord')::int, 0), e.v->'data'
    from jsonb_array_elements(coalesce(p_upserts, '[]'::jsonb)) as e(v)
  on conflict (group_code, kind, id)
  do update set ord = excluded.ord, data = excluded.data, updated_at = now();

  delete from public.hub_items h
   using jsonb_array_elements(coalesce(p_deletes, '[]'::jsonb)) as e(v)
   where h.group_code = p_code and h.kind = e.v->>'kind' and h.id = e.v->>'id';
end $$;

revoke all on function public.hub_pull(text) from public;
revoke all on function public.hub_push(text, jsonb, jsonb) from public;
grant execute on function public.hub_pull(text) to anon, authenticated;
grant execute on function public.hub_push(text, jsonb, jsonb) to anon, authenticated;

alter table public.usuarios enable row level security;

drop policy if exists usuarios_select_all on public.usuarios;
drop policy if exists usuarios_insert_all on public.usuarios;
drop policy if exists usuarios_update_all on public.usuarios;
drop policy if exists usuarios_delete_all on public.usuarios;

create policy usuarios_select_all
on public.usuarios
for select
to anon, authenticated
using (true);

create policy usuarios_insert_all
on public.usuarios
for insert
to anon, authenticated
with check (true);

create policy usuarios_update_all
on public.usuarios
for update
to anon, authenticated
using (true)
with check (true);

create policy usuarios_delete_all
on public.usuarios
for delete
to anon, authenticated
using (true);

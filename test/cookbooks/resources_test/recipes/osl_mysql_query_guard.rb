# A leftover guard unit that osl-mysql::query_guard must remove; the marker keeps the
# second converge idempotent.
marker = '/root/.query-guard-stale-created'

systemd_unit 'pt-kill-old_user.service' do
  content(Unit: { Description: 'stale guard' }, Service: { ExecStart: '/bin/sleep infinity' })
  action :create
  not_if { ::File.exist?(marker) }
end

file marker

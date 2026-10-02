provides :osl_mysql_query_guard
resource_name :osl_mysql_query_guard
unified_mode true

default_action :create

# User names become systemd unit names: '@' would make a template unit, '.' a regex wildcard.
property :rules, Array, default: [], callbacks: {
  'must be Hashes with a user of letters, digits, _ or -' => lambda { |rules|
    rules.all? { |r| r.is_a?(Hash) && (r['user'] || r[:user]).to_s.match?(/\A[A-Za-z0-9_-]+\z/) }
  },
  'must have a busy_time that is a positive Integer when set' => lambda { |rules|
    rules.all? { |r| (b = r['busy_time'] || r[:busy_time]).nil? || (b.is_a?(Integer) && b.positive?) }
  },
  'must only use the keys user and busy_time' => lambda { |rules|
    rules.all? { |r| (r.keys.map(&:to_s) - %w(user busy_time)).empty? }
  },
  'must not list a user twice' => lambda { |rules|
    users = rules.map { |r| r['user'] || r[:user] }
    users.uniq.size == users.size
  },
}
# pt-kill treats a busy time of 0 as "kill every query"
property :busy_time, Integer, default: 120, callbacks: { 'must be positive' => lambda(&:positive?) }
property :interval, Integer, default: 10, callbacks: { 'must be positive' => lambda(&:positive?) }
property :defaults_file, String, default: '/root/.my.cnf'

action :create do
  # percona::package_repo sets up the percona-tools repo only on EL8 and EL9
  if node['platform_version'].to_i >= 10
    raise 'osl_mysql_query_guard supports EL8 and EL9 only: percona-toolkit has no configured repo on EL10'
  end

  package 'percona-toolkit'

  rules = osl_mysql_query_guard_rules(new_resource.rules, new_resource.busy_time)

  rules.each do |user, busy_time|
    unit = osl_mysql_query_guard_unit(user)

    systemd_unit unit do
      content osl_mysql_query_guard_content(user, busy_time, new_resource.interval, new_resource.defaults_file)
      action :create
    end

    service unit do
      action [:enable, :start]
      subscribes :restart, "systemd_unit[#{unit}]"
    end
  end

  # A user dropped from the rules loses its guard
  stale = osl_mysql_query_guard_units_on_disk - rules.keys.map { |u| osl_mysql_query_guard_unit(u) }
  stale.each do |unit|
    service unit do
      action [:stop, :disable]
    end

    systemd_unit unit do
      action :delete
    end
  end
end

action :delete do
  osl_mysql_query_guard_units_on_disk.each do |unit|
    service unit do
      action [:stop, :disable]
    end

    systemd_unit unit do
      action :delete
    end
  end
end

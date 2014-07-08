default['mysql']['reload_action'] = "none"

default['mysql']['server']['tmpdir'] = ['/tmp']
default['mysql']['server']['socket'] = '/var/lib/mysql/mysql.sock'
default['mysql']['server']['pid_file'] = '/var/lib/mysql/mysql.pid'
default['mysql']['server']['directories']['log_dir'] = '/var/log/mysql'
default['mysql']['security'] = {}
default['mysql']['server']['packages'] = %w[
Percona-Server-shared-55
Percona-Server-server-55
percona-toolkit
percona-xtrabackup
]

default['mysql']['client']['packages'] = %w[
Percona-Server-client-55
Percona-Server-shared-compat
]


default['mysql']['service_name'] = "mysql"
default['mysql']['version'] = '5.5'
default['mysql']['bind_address'] = '0.0.0.0'
default['mysql']['old_passwords'] = 0
default['mysql']['root_network_acl'] = 'localhost'
default['mysql']['remove_anonymous_users'] = true

# Tunables
default['mysql']['tunable']['binlog_format'] = "mixed"
default['mysql']['tunable']['myisam_recover'] = "FORCE,BACKUP"
default['mysql']['tunable']['max_connections'] = "500"
default['mysql']['tunable']['max_allowed_packet'] = "128M"
default['mysql']['tunable']['max_connect_errors'] = "100000"
default['mysql']['tunable']['connect_timeout'] = "28880"
default['mysql']['tunable']['open_files_limit'] = "65535"
default['mysql']['tunable']['log_bin'] = "/var/lib/mysql/mysql-bin"
default['mysql']['tunable']['expire_logs_days'] = '10'
default['mysql']['tunable']['sync_binlog'] = "0"
default['mysql']['tunable']['query_cache_type'] = "0"
default['mysql']['tunable']['query_cache_size'] = "0"
default['mysql']['tunable']['thread_cache_size'] = "50"
default['mysql']['tunable']['key_buffer_size'] = "32M"
default['mysql']['tunable']['table_definition_cache'] = "4096"
default['mysql']['tunable']['table_open_cache'] = "10240"
default['mysql']['tunable']['innodb_file_per_table'] = "1"
default['mysql']['tunable']['innodb_flush_method'] = "O_DIRECT"
default['mysql']['tunable']['innodb_log_files_in_group'] = "2"
default['mysql']['tunable']['innodb_flush_log_at_trx_commit'] = "2"
default['mysql']['tunable']['lc_messages_dir'] = '/usr/share/percona-server'
default['mysql']['tunable']['lc_messages'] = 'en_US'

# Calculate the InnoDB buffer pool size and instances
# Ohai reports memory in kB
mem = (node['memory']['total'].split("kB")[0].to_i / 1024) # in MB
default['mysql']['tunable']['innodb_buffer_pool_size'] = "#{(Integer(mem * 0.75))}M"
default['mysql']['tunable']['innodb_buffer_pool_instances'] = (mem * 0.75 * 0.2 / 1024).ceil

# sysctl attrs
default['sysctl']['params']['vm']['swappiness'] = 0

# nrpe attrs
# add to nrpe packages if they already exist.
begin
  if node['nagios']['nrpe']['packages']
    node.override['nagios']['nrpe']['packages'] = node['nagios']['nrpe']['packages'] + ['percona-nagios-plugins']
  else
    node.default['nagios']['nrpe']['packages'] = ['percona-nagios-plugins']
  end
rescue NoMethodError
  node.default['nagios']['nrpe']['packages'] = ['percona-nagios-plugins']
end

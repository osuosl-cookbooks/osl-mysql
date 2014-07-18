default['percona']['server']['tmpdir'] = '/tmp'
default['percona']['server']['socket'] = '/var/lib/mysql/mysql.sock'
default['percona']['server']['pidfile'] = '/var/lib/mysql/mysql.pid'

default['percona']['bind_address'] = '0.0.0.0'
default['mysql']['old_passwords'] = 0

# Tunables
default['percona']['server']['binlog_format'] = "mixed"
default['percona']['server']['myisam_recover'] = "FORCE,BACKUP"
default['percona']['server']['max_connections'] = "500"
default['percona']['server']['max_allowed_packet'] = "128M"
default['percona']['server']['max_connect_errors'] = "100000"
default['percona']['server']['connect_timeout'] = "28880"
default['percona']['server']['open_files_limit'] = "65535"
default['percona']['server']['log_bin'] = "/var/lib/mysql/mysql-bin"
default['percona']['server']['expire_logs_days'] = '10'
default['percona']['server']['sync_binlog'] = "0"
default['percona']['server']['query_cache_size'] = "0"
default['percona']['server']['thread_cache_size'] = "50"
default['percona']['server']['key_buffer'] = "32M"
default['percona']['server']['table_cache'] = "4096"
default['percona']['server']['innodb_file_per_table'] = true
default['percona']['server']['innodb_flush_method'] = "O_DIRECT"
default['percona']['server']['innodb_log_files_in_group'] = "2"
default['percona']['server']['innodb_flush_log_at_trx_commit'] = "2"

# Calculate the InnoDB buffer pool size and instances
# Ohai reports memory in kB
mem = (node['memory']['total'].split("kB")[0].to_i / 1024) # in MB
default['percona']['server']['innodb_buffer_pool_size'] = "#{(Integer(mem * 0.75))}M"

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

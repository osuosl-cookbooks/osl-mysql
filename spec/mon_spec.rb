require 'spec_helper'

describe 'osl-mysql::mon' do
  [CENTOS_7_OPTS, CENTOS_6_OPTS].each do |pltfrm|
    context "on #{pltfrm[:platform]} #{pltfrm[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(pltfrm).converge(described_recipe)
      end
      before do
        stub_data_bag('enc_data_bag').and_return(['passwords'])
        stub_data_bag_item('enc_data_bag', 'passwords').and_return(root: 'root_pw', monitor: 'monitor_pw')
        allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).with('osl-mysql::server')
        allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).with('osl-mysql::nrpe')
        allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).with('osl-mysql::munin')
        allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).with('percona::monitoring')
      end
      it do
        expect { chef_run }.to_not raise_error
      end
      it do
        expect(chef_run).to install_mysql2_chef_gem('default')
          .with(
            provider: Chef::Provider::Mysql2ChefGem::Percona
          )
      end
      it do
        expect(chef_run).to create_mysql_database_user('mysql_monitor_grant')
          .with(
            connection: {
              host: 'localhost',
              username: 'root',
              password: 'root_pw' },
            username: 'monitor',
            password: 'monitor_pw',
            privileges: [:super, :process, 'replication client']
          )
      end
      it do
        expect(chef_run).to grant_mysql_database_user('mysql_monitor_grant')
          .with(
            connection: {
              host: 'localhost',
              username: 'root',
              password: 'root_pw' },
            username: 'monitor',
            password: 'monitor_pw',
            privileges: [:super, :process, 'replication client']
          )
      end
      it do
        expect(chef_run).to grant_mysql_database_user('mysql_monitor_database')
          .with(
            connection: {
              host: 'localhost',
              username: 'root',
              password: 'root_pw',
            },
            username: 'monitor',
            privileges: [:select],
            database_name: 'mysql'
          )
      end
      it do
        expect(chef_run).to create_template('nrpe_conf_dir/mysql.cnf')
          .with(
            source: 'nagios/mysql.cnf.erb',
            mode: 0600,
            owner: 'nrpe_user',
            group: 'nrpe_gruop',
            variables: {
              password: 'monitor',
            },
            sensitive: true
          )
      end
      %w(innodb pidfile processlist replication-delay).each do |c|
        it do
          expect(chef_run).to add_nrpe_check("pmp-check-mysql-#{c}")
            .with(
              command: "nrpe_plugin_dir/pmp-check-mysql-#{c}"
            )
        end
      end
      it do
        expect(chef_run).to create_template('munin_basedir/plugin-conf.d/mysql')
          .with(
            source: 'munin/mysql.erb',
            owner: 'munin',
            group: 'munin',
            variables: {
              passwlrd: 'monitor',
            }
          )
      end
      it do
        expect(chef_run).to install_package('perl-Cache-Cache')
      end
      %w(mysql_queries mysql_slowqueries mysql_threads).each do |p|
        it do
          expect(chef_run).to create_munin_plugin(p.to_s)
        end
      end
      %w(
        bin_relay_log
        commands
        connections
        innodb_bpool
        innodb_bpool_act
        innodb_semaphores
        qcache
        qcache_mem
        slow
        table_locks
        tmp_tables
      ).each do |p|
        it do
          expect(chef_run).to create_munin_plugin('mysql_')
            .with(
              plugin: "mysql_#{p}"
            )
        end
      end
    end
  end
end

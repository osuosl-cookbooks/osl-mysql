require 'spec_helper'

describe 'osl-mysql::mon' do
  include_context 'common_stubs'

  ALLPLATFORMS.each do |pltfrm|
    context "on #{pltfrm[:platform]} #{pltfrm[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(pltfrm).converge(described_recipe)
      end
      before do
        stub_data_bag_item('passwords', 'mysql').and_return(root: 'root_pw', monitor: 'monitor_pw')
      end
      it do
        expect { chef_run }.to_not raise_error
      end
      %w(
        osl-mysql::server
        osl-nrpe
        osl-munin::client
      ).each do |recipe|
        it do
          expect(chef_run).to include_recipe(recipe)
        end
      end
      it do
        expect(chef_run).to create_mariadb_user('mysql_monitor_grant')
          .with(
            ctrl_password: 'root_pw',
            username: 'monitor',
            password: 'monitor_pw',
            privileges: [:super, :select, :process, 'replication client', 'replication slave']
          )
      end
      it do
        expect(chef_run).to grant_mariadb_user('mysql_monitor_grant')
          .with(
            ctrl_password: 'root_pw',
            username: 'monitor',
            password: 'monitor_pw',
            privileges: [:super, :select, :process, 'replication client', 'replication slave']
          )
      end
      it do
        expect(chef_run).to install_package('percona-nagios-plugins')
      end
      it do
        expect(chef_run).to create_template('/etc/nagios/mysql.cnf')
          .with(
            source: 'nagios/mysql.cnf.erb',
            mode: '600',
            owner: 'nrpe',
            group: 'nrpe',
            variables: {
              password: 'monitor_pw',
            },
            sensitive: true
          )
      end
      %w(
        innodb
        pidfile
        processlist
        replication-delay
      ).each do |c|
        it do
          expect(chef_run).to add_nrpe_check("pmp-check-mysql-#{c}")
            .with(
              command: "/usr/lib64/nagios/plugins/pmp-check-mysql-#{c}"
            )
        end
      end
      it do
        expect(chef_run).to create_template('/etc/munin/plugin-conf.d/mysql')
          .with(
            source: 'munin/mysql.erb',
            owner: 'munin',
            group: 'munin',
            variables: {
              password: 'monitor_pw',
            }
          )
      end
      it do
        expect(chef_run).to install_package('perl-Cache-Cache')
      end
      %w(
        mysql_queries
        mysql_slowqueries
        mysql_threads
      ).each do |p|
        it do
          expect(chef_run).to create_munin_plugin(p)
        end
      end
      %w(
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
          expect(chef_run).to create_munin_plugin("mysql_#{p}").with(
            plugin: 'mysql_'
          )
        end
      end
    end
  end
end

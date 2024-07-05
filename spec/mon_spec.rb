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
      ).each do |recipe|
        it do
          expect(chef_run).to include_recipe(recipe)
        end
      end
      it do
        expect(chef_run).to create_percona_mysql_user('mysql_monitor_grant')
          .with(
            ctrl_password: 'root_pw',
            username: 'monitor',
            password: 'monitor_pw',
            privileges: [:super, :select, :process, 'replication client', 'replication slave']
          )
      end
      it do
        expect(chef_run).to grant_percona_mysql_user('mysql_monitor_grant')
          .with(
            ctrl_password: 'root_pw',
            username: 'monitor',
            password: 'monitor_pw',
            privileges: [:super, :select, :process, 'replication client', 'replication slave']
          )
      end
      it do
        expect(chef_run).to include_recipe('yum-osuosl')
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
    end
  end
end

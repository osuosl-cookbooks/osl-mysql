require 'spec_helper'

describe 'osl-mysql::xtrabackuprb' do
  ALLPLATFORMS.each do |pltfrm|
    context "on #{pltfrm[:platform]} #{pltfrm[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(pltfrm).converge(described_recipe)
      end
      it do
        expect { chef_run }.to_not raise_error
      end
      it do
        expect(chef_run).to include_recipe('git')
      end
      it do
        expect(chef_run).to include_recipe('percona::package_repo')
      end
      it do
        expect(chef_run).to install_package('percona-xtrabackup')
      end
      it do
        expect(chef_run).to sync_git('/usr/local/src/xtrabackup-rb')
          .with(
            repository: 'https://github.com/mmz-srf/xtrabackup-rb.git'
          )
      end
      it do
        expect(chef_run).to install_chef_gem('xtrabackup-rb')
          .with(
            source: '/usr/local/src/xtrabackup-rb/xtrabackup-rb-0.0.6.gem'
          )
      end
      it do
        expect(chef_run).to create_link('/usr/local/sbin/xtrabackup-rb')
          .with(
            to: '/opt/chef/embedded/bin/xtrabackup-rb'
          )
      end
    end

    context 'File /opt/chef/embedded/bin/xtrabackup-rb exist' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(pltfrm).converge(described_recipe)
      end
      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('/opt/chef/embedded/bin/xtrabackup-rb').and_return(true)
      end
      it do
        expect { chef_run }.to_not raise_error
      end
      it do
        expect(chef_run).to_not run_execute('gem build xtrabackup-rb.gemspec')
          .with(
            cwd: '/usr/local/src/xtrabackup-rb'
          )
      end
    end

    context 'File /opt/chef/embedded/bin/xtrabackup-rb not exist' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(pltfrm).converge(described_recipe)
      end
      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('/opt/chef/embedded/bin/xtrabackup-rb').and_return(false)
      end
      it do
        expect { chef_run }.to_not raise_error
      end
      it do
        expect(chef_run).to run_execute('gem build xtrabackup-rb.gemspec')
          .with(
            cwd: '/usr/local/src/xtrabackup-rb'
          )
      end
    end
  end
end

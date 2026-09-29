require 'spec_helper'

describe 'osl-mysql::default' do
  include_context 'common_stubs'

  ALLPLATFORMS.each do |pltfrm|
    context "on #{pltfrm[:platform]} #{pltfrm[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(pltfrm).converge(described_recipe)
      end
      it do
        expect { chef_run }.to_not raise_error
      end
      it do
        expect(chef_run).to include_recipe('osl-selinux::default')
      end
      it do
        expect(chef_run.node['percona']['version']).to eq({ '8' => '8.0', '9' => '8.0', '10' => '8.4' }[pltfrm[:version]])
      end
    end
  end
end

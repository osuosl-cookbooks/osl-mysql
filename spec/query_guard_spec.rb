require 'spec_helper'

describe 'osl-mysql::query_guard' do
  include_context 'common_stubs'

  ALLPLATFORMS.each do |pltfrm|
    context "on #{pltfrm[:platform]} #{pltfrm[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(pltfrm) do |node|
          node.override['osl-mysql']['replication']['role'] = 'vip_test'
        end.converge(described_recipe)
      end

      before do
        stub_data_bag_item('mysql_query_guard', 'vip_test').and_return(
          'id' => 'vip_test',
          'rules' => [{ 'user' => 'forum_user', 'busy_time' => 60 }]
        )
      end

      it { expect { chef_run }.to_not raise_error }
      it { expect(chef_run).to include_recipe('osl-mysql::server') }

      it do
        expect(chef_run).to create_osl_mysql_query_guard('vip_test').with(
          rules: [{ 'user' => 'forum_user', 'busy_time' => 60 }]
        )
      end
    end
  end
end

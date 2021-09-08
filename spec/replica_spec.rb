require 'spec_helper'

describe 'osl-mysql::replica' do
  include_context 'common_stubs'

  ALLPLATFORMS.each do |p|
    context "on #{p[:platform]} #{p[:version]}" do
      context 'with source node' do
        platform p[:platform], p[:version]

        before do
          stub_search(:node, 'roles:mysql-vip').and_return(
            [
              {
                name: 'source.example.org',
                network: {
                  interfaces: {
                    eth1: {
                      addresses: {
                        "192.0.2.100": {
                          family: 'inet',
                        },
                      },
                    },
                  },
                },
                percona: {
                  server: {
                    role: 'source',
                  },
                },
              },
            ]
          )
        end

        it do
          expect(chef_run).to include_recipe('osl-mysql::server')
        end
      end

      context 'without source node' do
        platform p[:platform], p[:version]

        before do
          stub_search(:node, 'roles:mysql-vip').and_return([])
        end

        it do
          expect { chef_run }.to raise_error.with_message('You should have one source node')
        end
      end
    end
  end
end

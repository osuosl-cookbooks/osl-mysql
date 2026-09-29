require 'chefspec'
require 'chefspec/berkshelf'

ALMA_8 = {
  platform: 'almalinux',
  version: '8',
}.freeze

ALMA_9 = {
  platform: 'almalinux',
  version: '9',
}.freeze

ALMA_10 = {
  platform: 'almalinux',
  version: '10',
}.freeze

ALLPLATFORMS = [
  ALMA_8,
  ALMA_9,
  ALMA_10,
].freeze

RSpec.configure do |config|
  config.log_level = :warn
end

shared_context 'common_stubs' do
  before do
    stub_command('rpm -qa | grep Percona-Server-shared-56').and_return(true)
    stub_command("mysqladmin --user=root --password='' version").and_return(true)
    stub_command('/usr/bin/test /etc/alternatives/mta -ef /usr/sbin/sendmail.postfix').and_return(true)
    stub_command('dnf module list mysql | grep -q "^mysql.*\\[x\\]"').and_return(true)
    stub_command('rpm -q mysql-libs').and_return(true)
    # percona::ssl (pulled in when replication ssl_enabled is true) reads this bag
    stub_data_bag_item('passwords', 'ssl_replication').and_return(
      'ca-cert' => 'ca',
      'server' => { 'server-cert' => 'cert', 'server-key' => 'key' },
      'client' => { 'client-cert' => 'cert', 'client-key' => 'key' }
    )
  end
end

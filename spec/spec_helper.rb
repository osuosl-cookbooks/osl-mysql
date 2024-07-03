require 'chefspec'
require 'chefspec/berkshelf'

ALMA_8_OPTS = {
  platform: 'almalinux',
  version: '8',
}.freeze

ALMA_9_OPTS = {
  platform: 'almalinux',
  version: '9',
}.freeze

CENTOS_7_OPTS = {
  platform: 'centos',
  version: '7',
}.freeze

ALLPLATFORMS = [
  ALMA_8_OPTS,
  ALMA_9_OPTS,
  CENTOS_7_OPTS,
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
  end
end

require 'chefspec'
require 'chefspec/berkshelf'

# rubocop:disable Style/MutableConstant
CENTOS_7_OPTS = {
  platform: 'centos',
  version: '7',
}

CENTOS_6_OPTS = {
  platform: 'centos',
  version: '6',
}
# rubocop:enable Style/MutableConstant

ALLPLATFORMS = [
  CENTOS_6_OPTS,
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
  end
end

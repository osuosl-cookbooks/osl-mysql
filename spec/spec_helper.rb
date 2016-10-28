require 'chefspec'
require 'chefspec/berkshelf'

ChefSpec::Coverage.start! { add_filter 'osl-mysql' }

CENTOS_7_OPTS = {
  platform: 'centos',
  version: '7.2.1511'
}.freeze

CENTOS_6_OPTS = {
  platform: 'centos',
  version: '6.7'
}.freeze

ALLPLATFORMS = [
  CENTOS_6_OPTS,
  CENTOS_7_OPTS
].freeze

RSpec.configure do |config|
  config.log_level = :fatal
end
source 'https://supermarket.osuosl.org'
source 'https://supermarket.chef.io'
solver :ruby, :required

# test dependencies
cookbook 'multi_node_test', path: 'test/cookbooks/multi_node_test'
cookbook 'resources_test', path: 'test/cookbooks/resources_test'
# waiting for branch to be reviewed and merge
cookbook 'percona', git: 'https://github.com/tffnychng/percona', branch: 'backup-el10'

metadata

source 'https://supermarket.chef.io'

solver :ruby, :required

cookbook 'firewall', git: 'git@github.com:osuosl-cookbooks/firewall'
cookbook 'osl-firewall', git: 'git@github.com:osuosl-cookbooks/osl-firewall'
cookbook 'osl-nrpe', git: 'git@github.com:osuosl-cookbooks/osl-nrpe'
cookbook 'osl-postfix', git: 'git@github.com:osuosl-cookbooks/osl-postfix'
cookbook 'osl-selinux', git: 'git@github.com:osuosl-cookbooks/osl-selinux'

# test dependencies
cookbook 'multi_node_test', path: 'test/cookbooks/multi_node_test'
cookbook 'base', git: 'git@github.com:osuosl-cookbooks/base'
cookbook 'osl-repos', git: 'git@github.com:osuosl-cookbooks/osl-repos'

metadata

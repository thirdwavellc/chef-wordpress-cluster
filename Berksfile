source 'https://supermarket.getchef.com'

metadata

cookbook 'apt'
cookbook 'yum'
cookbook 'git'
cookbook 'unzip', github: 'thirdwavellc/chef-unzip'
cookbook 'ssh-hardening', github: 'TelekomLabs/chef-ssh-hardening', tag: 'v1.0.2'
cookbook 'ssh-import-id', github: 'adamkrone/chef-ssh-import-id'
cookbook 'capistrano-base', github: 'thirdwavellc/chef-capistrano-base', tag: 'v1.0.0'
cookbook 'capistrano-wordpress', github: 'thirdwavellc/chef-capistrano-wordpress', tag: 'v1.0.0'
cookbook 'haproxy'
cookbook 'csync2', github: 'thirdwavellc/chef-csync2'
cookbook 'lsyncd', github: 'thirdwavellc/chef-lsyncd'
cookbook 'consul', github: 'johnbellone/consul-cookbook', ref: '1e1e53ae7c36c1731ccc7531edc0438ee6bb5141'
cookbook 'consul-cluster', github: 'thirdwavellc/chef-consul-cluster'
cookbook 'consul-template', github: 'adamkrone/chef-consul-template'
cookbook 'consul-alerts', github: 'adamkrone/chef-consul-alerts'
cookbook 'consul-services', github: 'thirdwavellc/chef-consul-services'
cookbook 'keepalived'
cookbook 'varnish'
cookbook 'wp-cli'

group :test do
  cookbook 'wordpress-cluster-test', path: 'spec/fixtures/cookbooks/wordpress-cluster-test'
end

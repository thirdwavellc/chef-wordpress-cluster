#
# Cookbook Name:: wordpress-cluster-test
# Recipe:: wordpress_cluster_database
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

wordpress_cluster_database 'my_app_production' do
  user 'my-app'
  user_host '%'
  user_password 'my-app-password'
  mysql_root_password 'my-root-password'
  development node['wordpress_cluster_test']['development']
end

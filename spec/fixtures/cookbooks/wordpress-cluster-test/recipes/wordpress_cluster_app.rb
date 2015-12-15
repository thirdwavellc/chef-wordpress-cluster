#
# Cookbook Name:: wordpress-cluster-test
# Recipe:: wordpress_cluster_app
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

wordpress_cluster_app 'my-app' do
  server_name 'my-app.com'
  scm 'git'
  bedrock node['wordpress_cluster_test']['bedrock']
end

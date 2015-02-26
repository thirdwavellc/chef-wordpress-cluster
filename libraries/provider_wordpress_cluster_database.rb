#
# Cookbook:: wordpress-cluster
# Provider:: wordpress_cluster_database
#
# Copyright 2014 Adam Krone <adam.krone@thirdwavellc.com>
# Copyright 2014 Thirdwave, LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/provider/lwrp_base'

class Chef
  class Provider
    class WordpressClusterDatabase < Chef::Provider::LWRPBase
      include Chef::DSL::IncludeRecipe
      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      action :create do
        include_recipe 'apt::default' if platform_family? 'debian'
        include_recipe 'yum::default' if platform_family? 'rhel'

        if new_resource.development
          node.normal['mysql']['server_root_password'] = new_resource.mysql_root_password
          include_recipe 'mysql::server'
        end

        # This database management section is super crufty, but until we can
        # get the database cookbook to work with percona, it will have to do.

        create_user_command = "create user '#{new_resource.user}'@'#{new_resource.user_host}' identified by '#{new_resource.user_password}'"

        execute "create db user '#{new_resource.user}'" do
          command "mysql -u root -p#{new_resource.mysql_root_password} -e \"#{create_user_command}\""
          not_if "mysql -u root -p#{new_resource.mysql_root_password} -D mysql -e \"select User from user\" | grep #{new_resource.user}"
        end

        create_db_command = "create database if not exists #{new_resource.db_name}"

        execute "create db '#{new_resource.db_name}'" do
          command "mysql -u root -p#{new_resource.mysql_root_password} -e \"#{create_db_command}\""
        end

        grant_privileges_command = "grant all privileges on #{new_resource.db_name}.* to '#{new_resource.user}'@'#{new_resource.user_host}'"

        execute "grant '#{new_resource.user}' privileges on db '#{new_resource.db_name}'" do
          command "mysql -u root -p#{new_resource.mysql_root_password} -e \"#{grant_privileges_command}\""
          not_if "mysql -u #{new_resource.user} -p#{new_resource.user_password} -e \"show databases\" | grep #{new_resource.db_name}"
        end

        execute 'flush privileges' do
          command "mysql -u root -p#{new_resource.mysql_root_password} -e 'flush privileges'"
          not_if "mysql -u root -p#{new_resource.mysql_root_password} -D mysql -e \"select User from user\" | grep #{new_resource.user}"
        end
      end
    end
  end
end

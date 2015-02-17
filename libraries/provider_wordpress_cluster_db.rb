#
# Cookbook:: wordpress-cluster
# Provider:: wordpress_cluster_db
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
    class WordpressClusterDb < Chef::Provider::LWRPBase
      include Chef::DSL::IncludeRecipe
      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      action :create do
        include_recipe 'apt::default' if platform_family? 'debian'
        include_recipe 'yum::default' if platform_family? 'rhel'

        include_recipe 'mysql::server'

        capistrano_mysql_database new_resource.environment do
          app_name new_resource.app_name
          user new_resource.user
          user_password new_resource.user_password
          user_host new_resource.user_host
          mysql_root_password new_resource.mysql_root_password
        end

        unless new_resource.development
          service 'mysql'

          template '/etc/mysql/conf.d/wordpress-tuning.cnf' do
            cookbook 'wordpress-cluster'
            source 'wordpress-tuning.cnf.erb'
            action :create
            notifies :restart, 'service[mysql]', :delayed
          end

          consul_cluster_client new_resource.datacenter do
            servers new_resource.consul_servers
            bind_interface new_resource.consul_bind_interface if new_resource.consul_bind_interface
          end

          service 'consul'

          include_recipe 'consul-services::mysql'
        end
      end

      action :delete do
        capistrano_user 'deploy' do
          action :delete
        end

        capistrano_wordpress_app new_resource.app_name do
          deploy_root "/var/www/#{new_resource.app_name}"
          action :delete
        end

        capistrano_shared_file '.env.ctmpl' do
          deploy_root "/var/www/#{new_resource.app_name}"
          action :delete
        end
      end
    end
  end
end

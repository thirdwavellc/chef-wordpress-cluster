#
# Cookbook:: wordpress-cluster
# Provider:: wordpress_cluster_app
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
    class WordpressClusterApp < Chef::Provider::LWRPBase
      include Chef::DSL::IncludeRecipe
      use_inline_resources if defined?(use_inline_resources)
      provides :wordpress_cluster_app

      def whyrun_supported?
        true
      end

      action :create do
        include_recipe 'apt::default' if platform_family? 'debian'
        include_recipe 'yum::default' if platform_family? 'rhel'

        include_recipe 'unzip::default'

        unless new_resource.development
          include_recipe 'git::default' if new_resource.scm == 'git'
          include_recipe 'hg::default' if new_resource.scm == 'hg'

          capistrano_user 'deploy' do
            group 'deploy'
            group_id 3000
          end

          node.normal['ssh']['allow_agent_forwarding'] = true

          include_recipe 'ssh-hardening::default'
        end

        node.override['apache']['keepalive'] = 'Off'
        node.override['apache']['prefork']['startservers'] = 10
        node.override['apache']['prefork']['minspareservers'] = 10
        node.override['apache']['prefork']['maxspareservers'] = 30
        node.override['apache']['prefork']['serverlimit'] = 50
        node.override['apache']['prefork']['maxrequestworkers'] = 50
        node.override['apache']['prefork']['maxconnectionsperchild'] = 2_500

        service 'apache2' do
          action :nothing
        end

        capistrano_wordpress_app new_resource.app_name do
          web_root new_resource.web_root if new_resource.web_root
          deployment_user new_resource.deployment_user
          deployment_group new_resource.deployment_group
          server_name new_resource.server_name
          notifies :restart, 'service[apache2]', :delayed
        end

        unless new_resource.development
          if new_resource.bedrock
            capistrano_shared_file '.env.ctmpl' do
              cookbook 'wordpress-cluster'
              template '.env.ctmpl.erb'
              app_root "/var/www/#{new_resource.app_name}"
              owner new_resource.deployment_user
              group new_resource.deployment_group
              variables(app_name: new_resource.app_name)
            end
          else
            directory "/var/www/#{new_resource.app_name}/shared/web" do
              owner new_resource.deployment_user
              group new_resource.deployment_group
              recursive true
            end

            template "/var/www/#{new_resource.app_name}/shared/web/wp-config.php.ctmpl" do
              cookbook 'wordpress-cluster'
              source 'wp-config.php.ctmpl.erb'
              owner new_resource.deployment_user
              group new_resource.deployment_group
              variables(app_name: new_resource.app_name, enable_ssl: new_resource.enable_ssl)
            end
          end

          service 'consul-template' do
            action :nothing
          end

          if new_resource.bedrock
            consul_template_config "#{new_resource.app_name}_env" do
              templates [{
                source: "/var/www/#{new_resource.app_name}/shared/.env.ctmpl",
                destination: "/var/www/#{new_resource.app_name}/shared/.env"
              }]
              notifies :restart, 'service[consul-template]', :delayed
            end
          else
            consul_template_config "#{new_resource.app_name}_wp-config" do
              templates [{
                source: "/var/www/#{new_resource.app_name}/shared/web/wp-config.php.ctmpl",
                destination: "/var/www/#{new_resource.app_name}/shared/web/wp-config.php"
              }]
              notifies :restart, 'service[consul-template]', :delayed
            end
          end

          include_recipe 'wp-cli::default'
        end
      end

      action :delete do
        capistrano_user 'deploy' do
          group_id 3000
          action :delete
        end

        capistrano_wordpress_app new_resource.app_name do
          server_name new_resource.server_name
          action :delete
          notifies :restart, 'service[apache2]', :delayed
        end

        if new_resource.bedrock
          capistrano_shared_file '.env.ctmpl' do
            template '.env.ctmpl.erb'
            app_root "/var/www/#{new_resource.app_name}"
            action :delete
          end
        else
          file "/var/www/#{new_resource.app_name}/shared/web/wp-config.php.ctmpl" do
            action :delete
          end
        end
      end
    end
  end
end

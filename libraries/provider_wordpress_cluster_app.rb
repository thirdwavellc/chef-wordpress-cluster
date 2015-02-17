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

          include_recipe 'capistrano-base::ssh'

          ssh_import_id 'deploy' do
            github_accounts new_resource.github_accounts
          end
        end

        node.override['apache']['prefork']['startservers'] = 50
        node.override['apache']['prefork']['minspareservers'] = 50
        node.override['apache']['prefork']['maxspareservers'] = 100
        node.override['apache']['prefork']['serverlimit'] = 200
        node.override['apache']['prefork']['maxrequestworkers'] = 200
        node.override['apache']['prefork']['maxconnectionsperchild'] = 5_000

        capistrano_wordpress_app new_resource.app_name do
          deploy_root "/var/www/#{new_resource.app_name}"
          docroot "/var/www/#{new_resource.app_name}/current/web"
          deployment_user new_resource.deployment_user
          deployment_group new_resource.deployment_group
          server_name new_resource.server_name
        end

        unless new_resource.development
          capistrano_shared_file '.env.ctmpl' do
            cookbook 'wordpress-cluster'
            template '.env.ctmpl.erb'
            deploy_root "/var/www/#{new_resource.app_name}"
            owner new_resource.deployment_user
            group new_resource.deployment_group
            variables app_name: new_resource.app_name
          end

          consul_cluster_client new_resource.datacenter do
            servers new_resource.consul_servers
            bind_interface new_resource.consul_bind_interface if new_resource.consul_bind_interface
            acl_datacenter new_resource.consul_acl_datacenter if new_resource.consul_acl_datacenter
            acl_token new_resource.consul_acl_token if new_resource.consul_acl_token
          end

          service 'consul'

          node.normal['consul_template'] = {
            consul: '127.0.0.1:8500'
          }

          include_recipe 'consul-template::default'

          consul_template_config "#{new_resource.app_name}_env" do
            templates [{
              source: "/var/www/#{new_resource.app_name}/shared/.env.ctmpl",
              destination: "/var/www/#{new_resource.app_name}/shared/.env"
            }]
          end

          service 'consul-template' do
            action :restart
          end

          include_recipe 'consul-services::apache2'
          include_recipe 'consul-services::consul-template'

          include_recipe 'consul-services::wordpress'

          node.normal['varnish']['version'] = '3.0.5'
          node.normal['varnish']['vcl_cookbook'] = 'wordpress-cluster'
          node.normal['varnish']['ttl'] = 15

          include_recipe 'varnish::default'
          include_recipe 'consul-services::varnish'

          include_recipe 'wp-cli::default'

          service 'apache2' do
            action :restart
          end
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

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

          node.normal['ssh_import_id']['users'] =
            [{ name: 'deploy',
               github_accounts: new_resource.ssh_import_ids }]

          include_recipe 'ssh-import-id::default'
        end

        capistrano_wordpress_app new_resource.app_name do
          deploy_root "/var/www/#{new_resource.app_name}"
          docroot "/var/www/#{new_resource.app_name}/current/web"
          deployment_user new_resource.deployment_user
          deployment_group new_resource.deployment_group
          server_name new_resource.server_name
        end

        unless new_resource.development
          capistrano_shared_file '.env.ctmpl' do
            template '.env.ctmpl.erb'
            deploy_root "/var/www/#{new_resource.app_name}"
            owner new_resource.deployment_user
            group new_resource.deployment_group
          end

          consul_cluster_client new_resource.datacenter do
            servers new_resource.consul_servers
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

          include_recipe 'consul-services::apache2'
          include_recipe 'consul-services::consul-template'
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

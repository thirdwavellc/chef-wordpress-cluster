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
        include_recipe 'mysql::server'

        capistrano_mysql_database new_resource.environment do
          app_name new_resource.app_name
          user new_resource.user
          user_password new_resource.user_password
          user_host new_resource.user_host
          mysql_root_password new_resource.mysql_root_password
        end


        unless new_resource.development
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

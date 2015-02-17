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

        if new_resource.development
          node.normal['mysql']['server_root_password'] = new_resource.mysql_root_password
          include_recipe 'mysql::server'
        end
        create_user_command = "create user '#{new_resource.user}'@'#{new_resource.user_host}' identified by '#{new_resource.user_password}'"

        execute "create db user '#{new_resource.user}'" do
          command "mysql -u root -p#{new_resource.mysql_root_password} -e \"#{create_user_command}\""
          not_if "mysql -u root -p#{new_resource.mysql_root_password} -D mysql -e \"select User from user\" | grep #{new_resource.user}"
        end

        db_name = "#{new_resource.app_name}_#{new_resource.environment}"
        create_db_command = "create database if not exists #{db_name}"

        execute "create db '#{db_name}'" do
          command "mysql -u root -p#{new_resource.mysql_root_password} -e \"#{create_db_command}\""
        end

        grant_privileges_command = "grant all privileges on #{db_name}.* to '#{new_resource.user}'@'#{new_resource.user_host}'"

        execute "grant '#{new_resource.user}' privileges on db '#{db_name}'" do
          command "mysql -u root -p#{new_resource.mysql_root_password} -e \"#{grant_privileges_command}\""
          not_if "mysql -u #{new_resource.user} -p#{new_resource.user_password} -e \"show databases\" | grep #{db_name}"
        end

        execute 'flush privileges' do
          command "mysql -u root -p#{new_resource.mysql_root_password} -e 'flush privileges'"
          not_if "mysql -u root -p#{new_resource.mysql_root_password} -D mysql -e \"select User from user\" | grep #{new_resource.user}"
        end

        unless new_resource.development
          consul_cluster_client new_resource.datacenter do
            servers new_resource.consul_servers
            bind_interface new_resource.consul_bind_interface
          end

          service 'consul'

          include_recipe 'consul-services::mysql'
        end
      end
    end
  end
end

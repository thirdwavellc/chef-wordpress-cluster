require 'chef/provider/lwrp_base'

class Chef
  class Provider
    class WordpressClusterReplConfig < Chef::Provider::LWRPBase
      include Chef::DSL::IncludeRecipe
      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      action :create do
        include_recipe 'csync2::default'

        file 'csync2.key' do
          path '/etc/csync2.key'
          content new_resource.csync2_key
          action :create
        end

        csync2_config '/etc/csync2.cfg' do
          hosts new_resource.csync2_hosts
          synced_dirs new_resource.synced_dirs
          key_path '/etc/csync2.key'
        end

        node.normal['lsyncd']['watched_dirs'] = new_resource.synced_dirs

        include_recipe 'lsyncd::default'

        service 'consul'

        include_recipe 'consul-services::lsyncd'
      end
    end
  end
end

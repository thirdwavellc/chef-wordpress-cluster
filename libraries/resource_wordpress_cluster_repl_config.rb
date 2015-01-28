require 'chef/resource/lwrp_base'

class Chef
  class Resource
    class WordpressClusterReplConfig < Chef::Resource::LWRPBase
      self.resource_name = :wordpress_cluster_repl_config
      actions :create
      default_action :create

      attribute :name, kind_of: String, name_attribute: true
      attribute :csync2_key, kind_of: String, required: true
      attribute :csync2_hosts, kind_of: Array, required: true
      attribute :synced_dirs, kind_of: Array, required: true
    end
  end
end

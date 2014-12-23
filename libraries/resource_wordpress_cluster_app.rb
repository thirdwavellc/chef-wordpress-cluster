require 'chef/resource/lwrp_base'

class Chef
  class Resource
    class WordpressClusterApp < Chef::Resource::LWRPBase
      self.resource_name = :wordpress_cluster_app
      actions :create, :delete
      default_action :create

      attribute :app_name, kind_of: String, name_attribute: true
      attribute :server_name, kind_of: String, default: nil
      attribute :server_aliases, kind_of: Array, default: []
    end
  end
end

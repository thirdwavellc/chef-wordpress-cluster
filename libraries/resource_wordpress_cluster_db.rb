require 'chef/resource/lwrp_base'

class Chef
  class Resource
    class WordpressClusterDb < Chef::Resource::LWRPBase
      self.resource_name = :wordpress_cluster_db
      actions :create, :delete
      default_action :create

      attribute :environment, kind_of: String, name_attribute: true
      attribute :app_name, kind_of: String, required: true
      attribute :user, kind_of: String, required: true
      attribute :user_password, kind_of: String, required: true
      attribute :user_host, kind_of: String, default: '%'
      attribute :mysql_root_password, kind_of: String, required: true
      attribute :development, equal_to: [true, false], default: false
      attribute :consul_servers, kind_of: Array
      attribute :datacenter, kind_of: String
    end
  end
end

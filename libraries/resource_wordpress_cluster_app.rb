require 'chef/resource/lwrp_base'

class Chef
  class Resource
    class WordpressClusterApp < Chef::Resource::LWRPBase
      self.resource_name = :wordpress_cluster_app
      actions :create, :delete
      default_action :create

      attribute :app_name, kind_of: String, name_attribute: true
      attribute :deployment_user, kind_of: String, default: 'deploy'
      attribute :deployment_group, kind_of: String, default: 'deploy'
      attribute :server_name, kind_of: String, default: nil
      attribute :server_aliases, kind_of: Array, default: []
      attribute :scm, equal_to: ['git', 'hg'], required: true
      attribute :github_accounts, kind_of: Array, required: true
      attribute :csync2_hosts, kind_of: Array, default: nil
      attribute :csync2_key, kind_of: String, default: nil
      attribute :lsyncd_watched_dirs, kind_of: Array, default: nil
      attribute :development, equal_to: [true, false], default: false
      attribute :consul_servers, kind_of: Array
      attribute :consul_bind_interface, kind_of: String, default: nil
      attribute :consul_acl_datacenter, kind_of: String, default: nil
      attribute :consul_acl_token, kind_of: String, default: nil
      attribute :datacenter, kind_of: String
    end
  end
end

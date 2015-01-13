require 'chef/resource/lwrp_base'

class Chef
  class Resource
    class WordpressClusterLb < Chef::Resource::LWRPBase
      self.resource_name = :wordpress_cluster_lb
      actions :create
      default_action :create

      attribute :keepalived_priority, kind_of: String, name_attribute: true
      attribute :keepalived_state, equal_to: ['MASTER', 'BACKUP'], required: true
      attribute :keepalived_virtual_ip, kind_of: String, required: true
      attribute :keepalived_interface, kind_of: String, required: true
      attribute :keepalived_auth_pass, kind_of: String, required: true
      attribute :consul_servers, kind_of: Array
      attribute :consul_acl_datacenter, kind_of: String, default: nil
      attribute :consul_acl_token, kind_of: String, default: nil
      attribute :datacenter, kind_of: String
    end
  end
end

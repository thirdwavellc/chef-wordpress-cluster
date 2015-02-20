#
# Cookbook:: wordpress-cluster
# Resource:: wordpress_cluster_lb
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
      attribute :enable_keepalived, equal_to: [true, false], default: true
      attribute :consul_servers, kind_of: Array
      attribute :consul_bind_interface, kind_of: String, default: nil
      attribute :consul_acl_datacenter, kind_of: String, default: nil
      attribute :consul_acl_token, kind_of: String, default: nil
      attribute :datacenter, kind_of: String
      attribute :sites, kind_of: Array, required: true
      attribute :basic_auth_users, kind_of: Array, default: []
    end
  end
end

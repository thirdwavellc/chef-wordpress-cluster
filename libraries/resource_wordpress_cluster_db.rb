#
# Cookbook:: wordpress-cluster
# Resource:: wordpress_cluster_db
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
      attribute :consul_bind_interface, kind_of: String, default: nil
      attribute :datacenter, kind_of: String
    end
  end
end

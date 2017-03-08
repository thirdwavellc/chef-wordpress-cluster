#
# Cookbook:: wordpress-cluster
# Resource:: wordpress_cluster_repl_config
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
    class WordpressClusterReplConfig < Chef::Resource::LWRPBase
      self.resource_name = :wordpress_cluster_repl_config
      actions :create
      default_action :create

      attribute :name, kind_of: String, name_attribute: true
      attribute :csync2_key, kind_of: String, required: true
      attribute :csync2_hosts, kind_of: Array, required: true
      attribute :lsyncd_sync_id, kind_of: String, required: true
      attribute :synced_dirs, kind_of: Array, required: true
    end
  end
end

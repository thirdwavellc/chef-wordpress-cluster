#
# Cookbook:: wordpress-cluster
# Resource:: wordpress_cluster_app
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
    class WordpressClusterApp < Chef::Resource::LWRPBase
      self.resource_name = :wordpress_cluster_app
      actions :create, :delete
      default_action :create

      attribute :app_name, kind_of: String, name_attribute: true
      attribute :deployment_user, kind_of: String, default: 'deploy'
      attribute :deployment_group, kind_of: String, default: 'deploy'
      attribute :web_root, kind_of: String, default: 'web'
      attribute :server_name, kind_of: String, required: true
      attribute :server_aliases, kind_of: Array, default: nil
      attribute :scm, equal_to: ['git', 'hg'], required: true
      attribute :development, equal_to: [true, false], default: false
      attribute :bedrock, equal_to: [true, false], default: false
    end
  end
end

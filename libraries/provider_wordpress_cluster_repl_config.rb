#
# Cookbook:: wordpress-cluster
# Provider:: wordpress_cluster_repl_config
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

require 'chef/provider/lwrp_base'

class Chef
  class Provider
    class WordpressClusterReplConfig < Chef::Provider::LWRPBase
      include Chef::DSL::IncludeRecipe
      use_inline_resources if defined?(use_inline_resources)
      provides :wordpress_cluster_repl_config

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

        lsyncd_config '/etc/lsyncd/lsyncd.conf.lua' do
          watched_dirs new_resource.synced_dirs
        end

        consul_service 'consul' do
          action :nothing
        end

        include_recipe 'consul-services::lsyncd'
      end
    end
  end
end

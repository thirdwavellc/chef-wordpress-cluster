#
# Cookbook:: wordpress-cluster
# Provider:: wordpress_cluster_lb
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
    class WordpressClusterLb < Chef::Provider::LWRPBase
      include Chef::DSL::IncludeRecipe
      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      action :create do
        include_recipe 'apt::default' if platform_family? 'debian'
        include_recipe 'yum::default' if platform_family? 'rhel'

        include_recipe 'unzip::default'

        include_recipe 'haproxy::install_package'

        service "haproxy" do
          supports :restart => true, :status => true, :reload => true
          action [:enable, :start]
        end

        cookbook_file "/etc/default/haproxy" do
          cookbook "haproxy"
          source "haproxy-default"
          owner "root"
          group "root"
          mode 00644
          notifies :restart, "service[haproxy]", :delayed
        end

        consul_cluster_client new_resource.datacenter do
          servers new_resource.consul_servers
          bind_interface new_resource.consul_bind_interface if new_resource.consul_bind_interface
          acl_datacenter new_resource.consul_acl_datacenter if new_resource.consul_acl_datacenter
          acl_token new_resource.consul_acl_token if new_resource.consul_acl_token
        end

        service 'consul'

        node.normal['consul_template'] = {
          consul: '127.0.0.1:8500'
        }

        template '/etc/haproxy/haproxy.cfg.ctmpl' do
          cookbook 'wordpress-cluster'
          source 'haproxy.cfg.ctmpl.erb'
          variables(sites: new_resource.sites, datacenter: new_resource.datacenter, basic_auth_users: new_resource.basic_auth_users)
          action :create
          notifies :restart, "service[haproxy]", :delayed
        end

        include_recipe 'consul-template::default'

        consul_template_config 'haproxy' do
          templates [{
            source: '/etc/haproxy/haproxy.cfg.ctmpl',
            destination: '/etc/haproxy/haproxy.cfg',
            command: 'service haproxy restart'
          }]
        end

        service 'consul-template' do
          action :restart
        end

        include_recipe 'consul-services::haproxy'
        include_recipe 'consul-services::consul-template'

        if new_resource.enable_keepalived
          unless new_resource.keepalived_priority
            Chef::Application.fatal!('You must specify the keepalived_priority')
          end

          unless new_resource.keepalived_virtual_ip
            Chef::Application.fatal!('You must specify the keepalived_virtual_ip')
          end

          unless new_resource.keepalived_interface
            Chef::Application.fatal!('You must specify the keepalived_interface')
          end

          unless new_resource.keepalived_auth_pass
            Chef::Application.fatal!('You must specify the keepalived_auth_pass')
          end

          node.normal['keepalived'] = {
            instance_defaults: {
              state: new_resource.keepalived_state,
              priority: new_resource.keepalived_priority
            },
            shared_address: "true",
            check_scripts: {
              chk_haproxy: {
                script: 'killall -0 haproxy',
                interval: 2,
                weight: 2
              }
            },
            instances: {
              vi_1: {
                ip_addresses: new_resource.keepalived_virtual_ip,
                interface: new_resource.keepalived_interface,
                track_script: 'chk_haproxy',
                nopreempt: false,
                advert_int: 1,
                auth_type: :pass, # :pass or :ah
                auth_pass: new_resource.keepalived_auth_pass
              }
            }
          }

          include_recipe 'keepalived'
          include_recipe 'consul-services::keepalived'
        end
      end
    end
  end
end

#
# Chef Cookbook   : netdev_cumulus
# File            : recipe/l3_interface.rb
#   
# Copyright 2014 Internet Initiative Japan Inc.
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
databag = node[:netdev_config][:databag_name]
Chef::Log.info "My data bag is #{databag}"
 
hostname = node[:hostname]
Chef::Log.info "My hostname is #{hostname}"
 
netdev_provider = node[:netdev_config][:providers][:netdev_cumulus_l3_interface]
Chef::Log.info "My provider is #{netdev_provider}"
 
config = data_bag_item(databag, hostname)
interfaces = config['netdev_l3_interface']
 
if !interfaces.nil?
  interfaces.each do |name, attribs|
    Chef::Log.info "Processing interface #{name}"
 
    if attribs['admin'] == 'down'
      netdev_cumulus_l3_interface name do
        provider netdev_provider
        action :delete
      end

    else
      netdev_cumulus_l3_interface name do
        provider netdev_provider
        ipaddress attribs['ipaddress'] if attribs['ipaddress']
        netmask attribs['netmask'] if attribs['netmask']
        gateway attribs['gateway'] if attribs['gateway']
        admin attribs['admin'] if attribs['admin']
        action :create
      end
    end
     
  end
end

ruby_block "Fix interfaces include" do
  block do
    class  Chef::Resource::RubyBlock
      include Mod_Network_interfaces
    end
    insert_line_if_no_match("/etc/network/interfaces", "^source /etc/network/interfaces.d/*", 'source /etc/network/interfaces.d/*')
  end
end

directory "/etc/network/interfaces.d" do
        owner "root"
        group "root"
        mode "0755"
        action :create
end

#
# Chef Cookbook   : netdev_cumulus
# File            : provider/l3_interface.rb
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

require 'ipaddr'
 
def whyrun_supported?
  true
end

IPLINK = '/sbin/ip'
 
action :create do 
  converge_by("create interface #{@new_resource.name}") do
    if has_changed?(@current_resource.ipaddress, @new_resource.ipaddress) or
       has_changed?(@current_resource.netmask, @new_resource.netmask)
      create_l3_interface
    else
      Chef::Log.info "skip applying #{@new_resource.name}"
    end
  end
end
 
action :delete do
  converge_by("remove interface #{@new_resource.name}") do
    ip_options = Array.new()
    (ip_options << @new_resource.ipaddress)
    unless ip_options.empty?
      ip_options.unshift ['addr', 'flush']
      ip_options += ['dev', @new_resource.name]
      execute "iplink addr del" do
        command "#{IPLINK} #{ip_options.flatten.join(' ')}"
      end
      rm_target = "/etc/network/interfaces.d/#{@new_resource.name}"
      ::File::unlink(rm_target) if ::File.exist?(rm_target)
    end
  end
end
 
def load_current_resource
  Chef::Log.info "Loading current resource #{@new_resource.name}"
   
  ipaddr = run_command("ip addr show #{@new_resource.name} | grep inet | grep #{@new_resource.name} | awk -F\" \" '{print $2}' | sed -e 's/\\/.*$//'").chomp!
  prefix = run_command("ip addr show #{@new_resource.name} | grep inet | grep #{@new_resource.name} | awk -F\" \" '{print $2}' | sed -e 's/.*\\///'").to_i
  nmask = IPAddr.new('255.255.255.255').mask(prefix).to_s
   
  @current_resource = Chef::Resource::NetdevCumulusL3Interface.new(@new_resource.name)
  @current_resource.ipaddress(ipaddr)
  @current_resource.netmask(nmask)
  @current_resource.exists = true
   
end
 
def has_changed?(curres, newres)
  return curres != newres && !newres.nil?
end

def create_l3_interface
  ip_options = []
  ip_options << @new_resource.ipaddress
  ip_options << ip_options.pop + '/' + netmask_to_prefix(@new_resource.netmask)
  unless ip_options.empty?
    ip_options.unshift ['addr', 'add']
    ip_options += ['dev', @new_resource.name]
    execute "iplink addr add" do
      command "#{IPLINK} #{ip_options.flatten.join(' ')}"
    end
    ::File::open("/etc/network/interfaces.d/#{@new_resource.name}", "w") do |f|
      f.puts "auto #{@new_resource.name}"
      f.puts "iface #{@new_resource.name} inet static"
      f.puts "\taddress #{@new_resource.ipaddress}"
      f.puts "\tnetmask #{@new_resource.netmask}"
    end
  end
end
 
 
def run_command(command)
  Chef::Log.info "Running command: #{command}"
  command = Mixlib::ShellOut.new(command)
  command.run_command()
  return command.stdout
end

def netmask_to_prefix(value)
  netmask = IPAddr.new(value)
  if netmask.ipv4?
    s = netmask.to_i ^ IPAddr::IN4MASK.to_i
    prefix = 32
  elsif netmask.ipv6?
    s = netmask.to_i ^ IPAddr::IN6MASK.to_i if netmask.ipv6?
    prefix = 128
  end

  while s > 0
    s >>= 1
    prefix -= 1
  end
  prefix.to_s
end

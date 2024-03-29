#
# Chef Cookbook   : netdev
# File            : resources/l3_interface.rb
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

actions :create, :delete
default_action :create

attribute :name,            :kind_of => String, :name_attribute => true, :required => true
attribute :admin,           :kind_of => String, :equal_to => ['up', 'down']
attribute :ipaddress,       :kind_of => String
attribute :netmask,         :kind_of => String
attribute :gateway,         :kind_of => String
attribute :description,     :kind_of => String

attr_accessor :exists

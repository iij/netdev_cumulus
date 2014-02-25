name             'netdev_cumulus'
maintainer       'Takashi Sogabe'
maintainer_email 'sogabe@iij.ad.jp'
license          'Apache v2.0'
description      'Implements an Cumulus specific provider for netdev resources'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.0'

depends "netdev"

recipe "interface",
  "Manages physical interface resources on Cumulus based devices"

recipe "vlan",
  "Manages vlan resources on Cumulus based devices"

recipe "l2_interface",
  "Manages switchport resources on Cumulus based devices"

recipe "l3_interface",
  "Manages l3 interface resources on Cumulus based devices"

recipe "lag",
  "Manage lag (port-channel) resources on Cumulus based devices"

attribute 'netdev_config/databag_name',
  :display_name => 'Data Bag Name',
  :description => 'The name of the data bag to use for finding settings',
  :type => 'string',
  :required => 'required',
  :recipes => [ 'netdev_cumulus::vlan', 'netdev_cumulus::interface', 'netdev_cumulus::l2_interface', 'netdev_cumulus::lag' ],
  :default => 'netdev_config'
     
attribute 'netdev_config/providers/netdev_interface',
  :display_name => "Provider for netdev_interface LWRP",
  :description => "Sets the provider to use for implementing the LWRP",
  :type => "string",
  :required => "required",
  :recipes => [ 'netdev_cumulus::interface' ],
  :default => 'netdev_cumulus_interface'
   
attribute 'netdev_config/providers/netdev_vlan',
  :display_name => "Provider for netdev_vlan LWRP",
  :description => "Sets the provider to use for implementing the LWRP",
  :type => "string",
  :required => "required",
  :recipes => [ 'netdev_cumulus::vlan' ],
  :default => 'netdev_cumulus_vlan'
     
attribute 'netdev_config/providers/netdev_l2_interface',
  :display_name => "Provider for netdev_l2_interface LWRP",
  :description => "Sets the provider to use for implementing the LWRP",
  :type => "string",
  :required => "required",
  :recipes => [ 'netdev_cumulus::l2_interface' ],
  :default => 'netdev_cumulus_l2_interface'
       
attribute 'netdev_config/providers/netdev_cumulus_l3_interface',
  :display_name => "Provider for netdev_l3_interface LWRP",
  :description => "Sets the provider to use for implementing the LWRP",
  :type => "string",
  :required => "required",
  :recipes => [ 'netdev_cumulus::l3_interface' ],
  :default => 'netdev_cumulus_l3_interface'
       
attribute 'netdev_config/providers/netdev_lag',
  :display_name => "Provider for netdev_lag LWRP",
  :description => "Sets the provider to use for implementing the LWRP",
  :type => "string",
  :required => "required",
  :recipes => [ 'netdev_cumulus::lag' ],
  :default => 'netdev_cumulus_lag'

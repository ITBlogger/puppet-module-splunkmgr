# Class: splunkmgr
#
# This class deploys and manages Splunk servers and universal forwarders on linux and Windows
#
# Parameters:
#
# Defaults for all parameters are set in params.pp. Use hiera yaml files if any of the defaults need to be overridden for specific nodes, domains, operating systems, Puppet environments or globally 
#
# [*splunk_logging_port*]
#   The port that Splunk forwarders and indexers use to receive splunktcp logs on
# 
# [*splunk_type*]
#   The type of system that a particular node is. Currently the usable values are: 'client', 'cluster-manager', 'clustered-indexer', 'forwarder', 'heavy-forwarder', 'indexer', 'search-head'
#   'client' is used for any Puppet managed Windows or linux systems that require the universal forwarder and will not receive logs from other devices or nodes
#   'cluster-manager' is used for any Puppet managed linux servers that are used to manage a group of clustered indexers
#   'clustered-indexer' is used for any Puppet managed linux servers that are serving as clustered indexers. The Splunk software and services on this type of system is managed by the cluster-manager and not by Puppet.
#      Only linux configurations such as firewall settings are managed by Puppet on these systems
#   'forwarder' is used for any Puppet managed Windows or linux systems that require the universal forwarder and will receive logs (either syslog or Splunk) from other devices or nodes
#   'heavy-forwarder' is used for any Puppet managed linux systems that have the full Splunk product installed, but are only configured to receive logs and forward them to other forwarders or indexers
#   'indexer' is used for any Puppet managed linux systems that will serve as normal non-clustered indexers
#   'search-head' is used for any Puppet managed linux systems that will serve as Splunk search heads
#
# [*splunk_web_port*]
#   The port that admins and analysts use to connect to the Splunk web UI
#
# [*splunkd_port*]
#   The port that search heads use to communicate with indexers and indexer clusters. It is also used by the cluster manager to manage clustered indexers. I can be used by deployment server to manage clients as well, but we leverage
#     Puppet for that
#
# [*syslogging_port*]
#   The port that indexers, forwarders and heavy forwarders will receive syslog traffic on
#
# Requires: Puppet Labs Firewall module and hiera
#
class splunkmgr (
  $forwarder_confdir         = $splunkmgr::params::forwarder_confdir,
  $forwarder_install_options = $splunkmgr::params::forwarder_install_options,
  $forwarder_installer_path  = $splunkmgr::params::forwarder_installer_path,
  $forwarder_package_name    = $splunkmgr::params::forwarder_package_name,
  $forwarder_service         = $splunkmgr::params::forwarder_service,
  $forwarder_splunkd_address = $splunkmgr::params::forwarder_splunkd_address,
  $forwarder_splunkd_port    = $splunkmgr::params::forwarder_splunkd_port,
  $forwarder_src_pkg         = $splunkmgr::params::forwarder_src_pkg,
  $installer_root            = $splunkmgr::params::installer_root,
  $path_delimiter            = $splunkmgr::params::path_delimiter,
  $pkg_provider              = $splunkmgr::params::pkg_provider,
  $server_confdir            = $splunkmgr::params::server_confdir,
  $server_package_name       = $splunkmgr::params::server_package_name,
  $splunk_cluster_port       = $splunkmgr::params::splunk_cluster_port,
  $splunk_logging_port       = $splunkmgr::params::splunk_logging_port,
  $splunk_type               = $splunkmgr::params::splunk_type,
  $splunk_web_port           = $splunkmgr::params::splunk_web_port,
  $splunkd_address           = $splunkmgr::params::splunkd_address,
  $splunkd_port              = $splunkmgr::params::splunkd_port,
  $syslogging_port           = $splunkmgr::params::syslogging_port,
  $tcpout_defaultgroup       = $splunkmgr::params::tcpout_defaultgroup,
  $tcpout_server             = $splunkmgr::params::tcpout_server,
  $tcpout_useack             = $splunkmgr::params::tcpout_useack,
) inherits splunkmgr::params {

  if $::operatingsystem in ['CentOS', 'RedHat'] {
    include splunkmgr::fw
  }

  if $splunk_type in ['client', 'forwarder'] {
    include splunkmgr::forwarder
  }
 
  if $splunk_type in ['cluster-manager', 'heavy-forwarder', 'indexer', 'search-head'] {
    include splunkmgr::server
  }
  
}

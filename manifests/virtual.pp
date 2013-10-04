# Class: splunk::virtual
#
# This class serves to house virtual resources which could be realized in
# splunk, splunk::forwarder, or both. The resources are generated based on
# parameters set in splunk::params.
#
# Parameters: none
#
# Actions:
#
#   Declares and tags virtual resources to be realized by other classes in the
#   splunk module.
#
# Requires: nothing
#
class splunk::virtual inherits splunk {
  include splunk::params

  $virtual_services = unique(flatten([
    $server_service,
    $forwarder_service,
  ]))

  @service { $virtual_services:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

}

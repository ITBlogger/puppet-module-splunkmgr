# Class: splunk::windows_forwarder
#
# Modified version of dhogland/splunk (https://github.com/dhogland/splunk). Modified by Will Ferrer and Ethan Brooks of Run the Business LLC
#
# Further modified by Alex Scoble for use with hiera
#
class splunk::windows_forwarder inherits splunk {

  package { 'Universal Forwarder':
    ensure                     => latest
    source                     => "${installerfilepath}/${installer}",
    install_options            => {
      'AGREETOLICENSE'         => 'Yes',
      'RECEIVING_INDEXER'      => "${logging_server}:${logging_port}",
      'LAUNCHSPLUNK'           => '1',
      'SERVICESTARTTYPE'       => 'auto',
      'WINEVENTLOG_APP_ENABLE' => '1',
      'WINEVENTLOG_SEC_ENABLE' => '1',
      'WINEVENTLOG_SYS_ENABLE' => '1',
      'WINEVENTLOG_FWD_ENABLE' => '1',
      'WINEVENTLOG_SET_ENABLE' => '1',
      'ENABLEADMON'            => '1',
    },
  }
  service { 'SplunkForwarder':
    ensure  => running,
    enable  => true,
    require => Package['Universal Forwarder'],
  }
}

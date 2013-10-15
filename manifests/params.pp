# $splunk_logging_port (default='9997')
# Port used by universal and heavy forwarders to send logs to other forwarders and indexers
# $splunk_type (default='client')
# Default 'client' is for universal forwarders. Allowed values are 'client', 'cluster-manager', 'clustered-indexer', 'forwarder', 'heavy-forwarder', 'indexer' and 'search-head'
# $splunk_web_port (default='8000')
# Port used to connect to the Splunk web admin UI
# $splunkd_port (default='8089')
# Port used by cluster manager to manage clustered indexers and by search heads to query indexers
# $syslogging_port (default='514')
# Port used by forwaders and indexers to receive logs from syslog capable systems
class splunkmgr::params {

  $forwarder_splunkd_address = '127.0.0.1'
  $forwarder_splunkd_port    = '18089'
  $installer_root            = 'http://repo/test/3rdparty/'
  $splunk_cluster_port       = '8080'
  $splunk_logging_port       = '9997' 
  $splunk_type               = 'client' 
  $splunk_web_port           = '8000' 
  $splunk_version            = '6.0-182037'
  $splunkd_address           = '127.0.0.1'
  $splunkd_port              = '8089' 
  $syslogging_port           = '514'  
  $tcpout_defaultgroup       = 'splunkloadbal_autolb_group'
  $tcpout_server             = 'splunkloadbal.ccnlab.dittdsh.org'
  $tcpout_useack             = 'true'

  # Settings common to a kernel
  case $::kernel {
    default: { fail("splunkmgr module does not support kernel ${kernel}") }
    'Linux': {
      $forwarder_confdir = '/opt/splunkforwarder/etc/system/local'
      $forwarder_service = 'splunk'
      $path_delimiter    = '/'
      $server_confdir    = '/opt/splunk/etc/system/local'
    }
    'Windows': {
      $forwarder_confdir         = 'C:/Program Files/SplunkUniversalForwarder/etc/system/local'
      $forwarder_install_options = [
        'AGREETOLICENSE=Yes',
        'LAUNCHSPLUNK=0',
        'SERVICESTARTTYPE=auto',
        'WINEVENTLOG_APP_ENABLE=1',
        'WINEVENTLOG_SEC_ENABLE=1',
        'WINEVENTLOG_SYS_ENABLE=1',
        'WINEVENTLOG_FWD_ENABLE=1',
        'WINEVENTLOG_SET_ENABLE=1',
        'ENABLEADMON=1',
      ]
      $forwarder_service         = 'SplunkForwarder'
      $forwarder_src_subdir      = 'universalforwarder/windows'
      $path_delimiter            = '\\'
    }
  }
      
  # Settings common to an OS family
  case $::osfamily {
    default:   { $pkg_provider = undef } # Don't define a $pkg_provider
    'Debian':  { $pkg_provider = 'apt' }
    'RedHat':  { $pkg_provider = 'yum' }
    'Windows': { $pkg_provider = 'windows' }
  }

  case "${::osfamily} ${::architecture}" {
    default: { fail("unsupported osfamily/architecture ${::osfamily}/${::architecture}") }
    "RedHat x86_64": {
      $forwarder_pkg_name = 'splunkforwarder'
    }
    "Debian amd64": {
      $forwarder_pkg_name = 'splunkforwarder'
    }
    /^(W|w)indows (x86|i386)$/: {
      $package_suffix       = "${splunk_version}-x86-release.msi"
      $forwarder_pkg_name   = 'Universal Forwarder'
    }
    /^(W|w)indows (x64|x86_64)$/: {
      $package_suffix       = "${splunk_version}-x64-release.msi"
      $forwarder_pkg_name   = 'Universal Forwarder'
    }
  }

  $forwarder_src_pkg        = "splunkforwarder-${package_suffix}"
  $forwarder_installer_path = "${installer_root}/${forwarder_src_subdir}/${forwarder_src_pkg}"

}

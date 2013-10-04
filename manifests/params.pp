# Class: splunk::params
#
# Modified version of dhogland/splunk (https://github.com/dhogland/splunk). Modified by Will Ferrer and Ethan Brooks of Run the Business LLC
#
# Further modified by Alex Scoble for use with hiera
#
#  - $deploy: valid values are server, syslog, forwarder (Default: 'forwarder')
#  - $splunk_ver: the username to run the command with (Default: '6.0-182037')
#  - $logging_server: not validated, but should be hostname or IP (Default: undef)
#  - $syslogging_port: syslog port (Default: '514')
#  - $logging_port: forwarder port (Default: '9997')
#  - $splunkd_port: splunk d port (Default: '8089')
#  - $admin_port: admin port (Default: '8000')
#  - $splunk_admin: splunk admin name (Default: 'admin')
#  - $splunk_admin_pass: splunk admin password  (Default: 'changeme')
#  - $installerfilespath: path to the installers downloaded for splunk - only used for Windows...Linux systems use package manager and internal repo servers (Default: "http://repo/test/3rdparty/${module_name}/")
#  - $splunktype: type of splunk system...used to manage certain operations on clustered indexers and cluster managers (Default: 'client')
class splunk::params {
  $deploy              = 'forwarder', #valid values are server, syslog, forwarder
  $splunk_ver          = '6.0-182037',
  $logging_server      = undef, #not validated, but should be hostname or IP
  $syslogging_port     = '514',
  $logging_port        = '9997',
  $splunkd_port        = '8089',
  $admin_port          = '8000',
  $splunk_admin        = 'admin',
  $splunk_admin_pass   = 'changeme',
  $installerfilespath  = "http://repo/test/3rdparty/${module_name}/",	
  $splunktype          = 'client', #valid values are client, indexer, search_head or cluster_manager
  $windows_stage_drive = 'C:',
}

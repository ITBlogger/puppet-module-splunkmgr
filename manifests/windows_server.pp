# Class: splunk::windows_server
#
# Modified version of dhogland/splunk (https://github.com/dhogland/splunk). Modified by Will Ferrer and Ethan Brooks of Run the Business LLC
#
class splunk::windows_server inherits splunk {

  package { 'Splunk':
    source          => "${installerfilepath}${installer}",
    install_options => {
      'SPLUNKD_PORT'           => "${splunkd_port}",
      'WEB_PORT'               => "${admin_port}",
      'LAUNCHSPLUNK'           => '1',
      'WINEVENTLOG_APP_ENABLE' => '1',
      'WINEVENTLOG_SEC_ENABLE' => '1',
      'WINEVENTLOG_SYS_ENABLE' => '1',
      'WINEVENTLOG_FWD_ENABLE' => '1',
      'WINEVENTLOG_SET_ENABLE' => '1',
    },
    require         => File['splunk_installer'],
  }
  service { 'Splunkd':
    ensure  => running,
    enable  => true,
    require => Package['Splunk'],
  }
  service { 'Splunkweb':
    ensure  => running,
    enable  => true,
    require => Service['Splunkd'], 
  }
  exec { 'set_listen_port':
    unless  => "findstr.exe /C:\"[splunktcp\://${logging_port}]\" \"C:\\Program Files\\Splunk\\etc\\apps\\search\\local\\inputs.conf\"",
    command => "\"C:\\Program Files\\Splunk\\bin\\splunk.exe\" enable listen ${logging_port} -auth ${splunk_admin}:${splunk_admin_pass}",
    require => Service['Splunkweb'],
  }
  exec { 'set_syslog_listen_port':
    unless  => "findstr.exe /C:\"[tcp\://${syslogging_port}]\" \"C:\\Program Files\\Splunk\\etc\\apps\\search\\local\\inputs.conf\"",
    command => "\"C:\\Program Files\\Splunk\\bin\\splunk.exe\" add tcp ${syslogging_port} -sourcetype syslog -auth ${splunk_admin}:${splunk_admin_pass}",
    require => Service['Splunkweb'],
  }
  exec { "splunk-${admin_port}-fw":
    command => "netsh.exe firewall add portopening protocol=TCP profile=ALL ${admin_port} \"Splunk Admin ${admin_port}\"",
    unless  => "cmd.exe /c \"netsh.exe firewall show portopening | findstr.exe /C:\"Splunk Admin ${admin_port}\"\"",
    require => Service['Splunkweb'],
  }
  exec { "splunk-${logging_port}-fw":
    command => "netsh.exe firewall add portopening protocol=TCP profile=ALL ${logging_port} \"Splunk splunktcp ${logging_port}\"", 
    unless  => "cmd.exe /c \"netsh.exe firewall show portopening | findstr.exe /C:\"Splunk splunktcp ${logging_port}\"\"",
    require => Service['Splunkd'],
  }
  exec { "splunk-${syslogging_port}-fw":
    command => "netsh.exe firewall add portopening protocol=TCP profile=ALL ${syslogging_port} \"Splunk syslog tcp ${syslogging_port}\"", 
    unless  => "cmd.exe /c \"netsh.exe firewall show portopening | findstr.exe /C:\"Splunk syslog tcp ${syslogging_port}\"\"",
    require => Service['Splunkd'],
  }
  exec { "splunk-${splunkd_port}-fw":
    command => "netsh.exe firewall add portopening protocol=TCP profile=ALL ${splunkd_port} \"Splunk splunkd ${splunkd_port}\"",
    unless  => "cmd.exe /c \"netsh.exe firewall show portopening | findstr.exe /C:\"Splunk splunkd ${splunkd_port}\"\"",
    require => Service['Splunkd'],
  }
}

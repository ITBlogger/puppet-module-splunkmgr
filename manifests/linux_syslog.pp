# Class: splunk::linux_syslog
#
# Modified version of dhogland/splunk (https://github.com/dhogland/splunk). Modified by Will Ferrer and Ethan Brooks of Run the Business LLC
#
# Further modified by Alex Scoble for use with hiera
#
class splunk::linux_syslog inherits splunk {
  
  package { 'rsyslog':
    ensure => installed,
  }
  service { 'rsyslog':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['rsyslog'],
  }
  file { '/etc/rsyslog.conf':
    ensure  => file,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => Package['rsyslog'],
  }
  file_line { 'log_all':
    ensure  => present, 
    path    => '/etc/rsyslog.conf',
    line    => "*.*	@@${logging_server}:${syslogging_port}",
    require => File['/etc/rsyslog.conf'],
    notify  => Service['rsyslog'],
  } 
}

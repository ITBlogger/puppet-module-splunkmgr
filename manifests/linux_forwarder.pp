# Class: splunk::linux_forwarder
#
# Modified version of dhogland/splunk (https://github.com/dhogland/splunk). Modified by Will Ferrer and Ethan Brooks of Run the Business LLC
#
# Further modified by Alex Scoble for use with hiera
#

class splunk::linux_forwarder inherits splunk {

  package { 'splunkforwarder':
    ensure   => latest,
    provider => $::operatingsystem ? {
      /(?i)(centos|redhat)/ => 'yum',
      /(?i)(debian|ubuntu)/ => 'apt',
    },
    notify   => Exec['start_splunk'],
  }
# I'm guessing this is here in case you want to manage forwarders via deployment server? 
#  firewall { '100 allow Splunkd':
#    action => 'accept',
#    proto  => 'tcp',
#    dport  => "${splunkd_port}",
#  }
  exec { 'start_splunk':
    creates => '/opt/splunkforwarder/etc/licenses',
    command => '/opt/splunkforwarder/bin/splunk start --accept-license',
    timeout => 0,
  }
  exec { 'set_forwarder_port':
    unless  => "/bin/grep \"server \= ${logging_server}:${logging_port}\" /opt/splunkforwarder/etc/system/local/outputs.conf",
    command => "/opt/splunkforwarder/bin/splunk add forward-server ${logging_server}:${logging_port} -auth ${splunk_admin}:${splunk_admin_pass}",
    require => Exec['set_monitor_default'],
    notify  => Service['splunk'],
  }
  exec { 'set_monitor_default':
    unless  => "/bin/grep \"\/var\/log\" /opt/splunkforwarder/etc/apps/search/local/inputs.conf",
    command => "/opt/splunkforwarder/bin/splunk add monitor \"/var/log/\" -auth ${splunk_admin}:${splunk_admin_pass}",
    require => Exec['start_splunk','set_boot'],
  }
  exec { 'set_boot':
    creates => '/etc/init.d/splunk',
    command => '/opt/splunkforwarder/bin/splunk enable boot-start',
    require => Exec['start_splunk'],
  }
  file { '/etc/init.d/splunk':
    ensure  => file,
    require => Exec['set_boot']
  }
  service { 'splunk':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => File['/etc/init.d/splunk'],
  }
}

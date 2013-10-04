# Class: splunk::linux_server
#
# Modified version of dhogland/splunk (https://github.com/dhogland/splunk). Modified by Will Ferrer and Ethan Brooks of Run the Business LLC
#
# Further modified by Alex Scoble for use with hiera
#

class splunk::linux_server inherits splunk {

  firewall { '100 allow Splunk Console':
    action => 'accept',
    proto  => 'tcp',
    dport  => "${admin_port"},
  }
  firewall { '100 allow Splunkd':
    action => 'accept',
    proto  => 'tcp',
    dport  => "${splunkd_port}",
  }
  firewall { '100 allow splunktcp logging in':
    action => 'accept',
    proto  => 'tcp',
    dport  => "${logging_port}",
  }
  firewall { '100 allow tcp syslog logging in':
    action => 'accept',
    proto  => 'tcp',
    dport  => "${syslogging_port}",
  }

  unless ($splunktype == 'indexer') {
    package { 'splunk':
      ensure   => installed,
      provider => $::operatingsystem ? {
        /(?i)(centos|redhat)/ => 'yum',
        /(?i)(debian)/        => 'apt',
      },
      notify   => Exec['start_splunk'],
    }
    exec { 'start_splunk':
      creates => '/opt/splunk/etc/auth/splunkweb',
      command => '/opt/splunk/bin/splunk start --accept-license',
      timeout => 0,
      notify  => Exec['set_boot','set_listen_port','set_tcp_listen_port'], 
    }
    exec { 'set_boot':
      creates => '/etc/init.d/splunk',
      command => '/opt/splunk/bin/splunk enable boot-start',
    }
    exec { 'set_listen_port':
      unless  => "/bin/grep '\[splunktcp\:\/\/$splunklogging_port\]' /opt/splunk/etc/apps/search/local/inputs.conf",
      command => "/opt/splunk/bin/splunk enable listen ${logging_port} -auth ${splunk_admin}:${splunk_admin_pass}",
    }
    exec { 'set_tcp_listen_port':
      unless  => "/bin/grep '\[tcp\:\/\/${syslogging_port}\]' /opt/splunk/etc/apps/search/local/inputs.conf",
      command => "/opt/splunk/bin/splunk add tcp ${syslogging_port} -sourcetype syslog -auth ${splunk_admin}:${splunk_admin_pass}",
    }
    service { 'splunk':
      enable      => true,
      require     => Exec['set_boot'],
    }
    service { 'splunkd':
      ensure   => running,
      provider => 'base',
      restart  => '/opt/splunk/bin/splunk restart splunkd',
      start    => '/opt/splunk/bin/splunk start splunkd',
      stop     => '/opt/splunk/bin/splunk stop splunkd',
      pattern  => "splunkd -p ${splunkd_port} (restart|start)",
      require  => Service['splunk'],
    }
    service { 'splunkweb':
      ensure   => running,
      provider => 'base',
      restart  => '/opt/splunk/bin/splunk restart splunkweb',
      start    => '/opt/splunk/bin/splunk start splunkweb',
      stop     => '/opt/splunk/bin/splunk stop splunkweb',
      pattern  => 'python -O /opt/splunk/lib/python.*/splunk/.*/root.py (restart|start)',
      require  => Service['splunk'],
    }
  }

}

class splunkmgr::combo inherits splunkmgr {

  package { 'splunkforwarder':
    ensure   => installed,
    provider => 'yum',
    before   => Exec['license_splunkforwarder'],
  }
  exec { 'license_splunkforwarder':
    path    => '/opt/splunkforwarder/bin',
    command => 'splunk start --accept-license --answer-yes',
    creates => '/opt/splunkforwarder/etc/auth/splunk.secret',
    timeout => 0,
    require => Package['splunkforwarder'],
  }
  exec { 'enable_splunkforwarder':
    path    => '/opt/splunkforwarder/bin',
    command => 'splunk enable boot-start',
    creates => '/etc/init.d/splunk',
    require => Exec['license_splunkforwarder'],
  }
  package { 'splunk':
    ensure   => installed,
    provider => 'yum',
    require  => Exec['enable_splunkforwarder'],
    notify   => Exec['license_splunk'],
  }
  exec { 'license_splunk':
    path    => '/opt/splunk/bin',
    command => 'splunk start --accept-license --answer-yes',
    timeout => 0,
    creates => '/opt/splunk/etc/auth/splunk.secret',
    require => Package['splunk'],
  }
  exec { 'enable_splunk':
    path    => '/opt/splunk/bin',
    command => 'splunk enable boot-start',
    creates => '/etc/init.d/splunk',
    require => Exec['license_splunk'],
  }
  splunk_conf { 'forwarder_tcpout':
    config_file    => "${forwarder_confdir}/outputs.conf",
    stanza         => 'tcpout',
    set            => {
      defaultGroup => "${tcpout_defaultgroup}",
    },
    ensure         => 'present',
    require        => Exec['enable_splunk'],
  }
  splunk_conf { 'forwarder_tcpout_defaultgroup':
    config_file => "${forwarder_confdir}/outputs.conf",
    stanza      => "tcpout:${tcpout_defaultgroup}",
    set         => {
      server    => "${tcpout_server}:${splunk_logging_port}",
      useACK    => "${tcpout_useack}",
    },
    ensure      => 'present',
    require     => Splunk_conf['forwarder_tcpout'],
  }
  splunk_conf { 'monitor:///var/log/messages':
    config_file  => "${forwarder_confdir}/inputs.conf",
    stanza       => 'monitor:///var/log/messages',
    set          => {
      sourcetype => 'syslog',
    },
    ensure       => 'present',
    require      => Splunk_conf['forwarder_tcpout_defaultgroup'],
  }
  splunk_conf { 'forwarder_webconf_settings':
    config_file    => "${forwarder_confdir}${path_delimiter}web.conf",
    stanza         => 'settings',
    set            => {
      mgmtHostPort => "${forwarder_splunkd_address}:${forwarder_splunkd_port}",
    },
    ensure         => 'present',
    require        => Splunk_conf['monitor:///var/log/messages'],
  }
  splunk_conf { 'server_webconf_settings':
    config_file    => "${server_confdir}${path_delimiter}web.conf",
    stanza         => 'settings',
    set            => {
      mgmtHostPort => "${splunkd_address}:${splunkd_port}",
    },
    ensure         => 'present',
    require        => Splunk_conf['forwarder_webconf_settings'],
    notify         => Service['splunk'],
  }
  service { 'splunk':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Splunk_conf['server_webconf_settings'],
  }
  service { 'splunkd':
    restart    => '/opt/splunk/bin/splunk restart splunkd',
    start      => '/opt/splunk/bin/splunk start splunkd',
    stop       => '/opt/splunk/bin/splunk stop splunkd',
#    pattern    => "splunkd -p ${splunkd_port} (restart|start)",
    ensure     => true,
#    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Service['splunk'],
  }
  service { 'splunkweb':
    restart    => '/opt/splunk/bin/splunk restart splunkweb',
    start      => '/opt/splunk/bin/splunk start splunkweb',
    stop       => '/opt/splunk/bin/splunk stop splunkweb',
#    pattern    => "python -O /opt/splunk/lib/python.*/splunk/.*/root.py (restart|start)",
    ensure     => true,
 #   enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Service['splunkd'],
  }

}

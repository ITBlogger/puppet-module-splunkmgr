class splunkmgr::server inherits splunkmgr {

  if $::osfamily in ['Debian', 'RedHat'] {

    package { 'splunk':
      ensure   => installed,
      provider => 'yum',
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
    
    if $splunk_type in ['cluster-manager', 'search-head'] {
      splunk_conf { 'server_tcpout':
        config_file    => "${server_confdir}/outputs.conf",
        stanza         => 'tcpout',
        set            => {
          defaultGroup => "${tcpout_defaultgroup}",
        },
        ensure         => 'present',
        require        => Exec['enable_splunk'],
      }
      splunk_conf { 'server_tcpout_defaultgroup':
        config_file => "${server_confdir}/outputs.conf",
        stanza      => "tcpout:${tcpout_defaultgroup}",
        set         => {
          server    => "${tcpout_server}:${splunk_logging_port}",
          useACK    => "${tcpout_useack}",
        },
        ensure      => 'present',
        require     => Splunk_conf['server_tcpout'],
        notify      => Service['splunk'],
      }
    }

    if $splunk_type in ['heavy-forwarder'] {

      splunk_conf { 'heavy_forwarder_tcpout':
        config_file    => "${server_confdir}${path_delimiter}outputs.conf",
        stanza         => 'tcpout',
        set            => {
          defaultGroup => "${tcpout_defaultgroup}",
        },
        ensure         => 'present',
      }
      splunk_conf { 'heavy_forwarder_tcpout_defaultgroup':
        config_file => "${server_confdir}${path_delimiter}outputs.conf",
        stanza      => "tcpout:${tcpout_defaultgroup}",
        set         => {
          server    => "${tcpout_server}:${splunk_logging_port}",
          useACK    => "${tcpout_useack}",
        },
        ensure      => 'present',
        require     => Splunk_conf['heavy_forwarder_tcpout'],
      }
      splunk_conf { 'heavy-forwarder_receive_tcp_splunkport':
        config_file => "${server_confdir}${path_delimiter}inputs.conf",
        stanza      => "splunktcp://${splunk_logging_port}",
        ensure      => 'present',
        require     => Splunk_conf['heavy_forwarder_tcpout_defaultgroup'],
      }
      splunk_conf { 'heavy-forwarder_receive_tcp_syslogport':
        config_file => "${server_confdir}${path_delimiter}inputs.conf",
        stanza      => "splunktcp://${syslogging_port}",
        ensure      => 'present',
        require     => Splunk_conf['heavy_forwarder_receive_tcp_splunkport'],
      }
      splunk_conf { 'heavy-forwarder_receive_udp_syslogport':
        config_file => "${server_confdir}${path_delimiter}inputs.conf",
        stanza      => "splunkudp://${syslogging_port}",
        ensure      => 'present',
        require     => Splunk_conf['heavy_forwarder_receive_tcp_syslogport'],
        notify      => Service['splunk'],
      }
    }

    splunk_conf { 'monitor_var_log_messages':
      config_file  => "${server_confdir}/inputs.conf",
      stanza       => 'monitor:///var/log/messages',
      set          => {
        sourcetype => 'syslog',
      },
      ensure       => 'present',
      require      => Exec['enable_splunk'],
    }
    splunk_conf { 'server_webconf_settings':
      config_file    => "${server_confdir}${path_delimiter}web.conf",
      stanza         => 'settings',
      set            => {
        mgmtHostPort => "${splunkd_address}:${splunkd_port}",
      },
      ensure         => 'present',
      require        => Splunk_conf['monitor_var_log_messages'],
      notify         => Service['splunk'],
    }
     
    service { 'splunk':
      ensure     => true,
#      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      require    => Splunk_conf['server_webconf_settings'],
    }
    service { 'splunkd':
      provider   => 'base',
      restart    => '/opt/splunk/bin/splunk restart splunkd',
      start      => '/opt/splunk/bin/splunk start splunkd',
      stop       => '/opt/splunk/bin/splunk stop splunkd',
      pattern    => "splunkd -p ${splunkd_port} (restart|start)",
      ensure     => true,
#      enable     => true,
      hasstatus  => true,
#      hasrestart => true,
      require    => Service['splunk'],
    }
    service { 'splunkweb':
      provider   => 'base',
      restart    => '/opt/splunk/bin/splunk restart splunkweb',
      start      => '/opt/splunk/bin/splunk start splunkweb',
      stop       => '/opt/splunk/bin/splunk stop splunkweb',
      pattern    => 'python -O /opt/splunk/lib/python.*/splunk/.*/root.py (restart|start)',
      ensure     => true,
#      enable     => true,
      hasstatus  => true,
#      hasrestart => true,
      require    => Service['splunkd']
    }

  }

  else { fail("${osfamily} not supported for running Splunk server. Please change splunk_type parameter from ${splunk_type} to a value supported by this OS") }

}

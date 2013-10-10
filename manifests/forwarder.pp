class splunkmgr::forwarder inherits splunkmgr {

  package { 'splunkforwarder':
    ensure   => installed,
    provider => 'yum',
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

  if $splunk_type in ['client', 'forwarder'] {

    if $splunk_type in ['client'] {

      splunk_conf { 'client_tcpout':
        config_file    => "${forwarder_confdir}${path_delimiter}outputs.conf",
        stanza         => 'tcpout',
        set            => {
          defaultGroup => "${tcpout_defaultgroup}",
        },
        ensure         => 'present',
      }
      splunk_conf { 'client_tcpout_defaultgroup':
        config_file => "${forwarder_confdir}${path_delimiter}outputs.conf",
        stanza      => "tcpout:${tcpout_defaultgroup}",
        set         => {
          server    => "${tcpout_server}:${splunk_logging_port}",
          useACK    => "${tcpout_useack}",
        },
        ensure      => 'present',
        require     => Splunk_conf['client_tcpout'],
        notify      => Service['splunk'],
      }
    }
    
    if $splunk_type in ['forwarder'] {

      splunk_conf { 'forwarder_tcpout':
        config_file    => "${forwarder_confdir}${path_delimiter}outputs.conf",
        stanza         => 'tcpout',
        set            => {
          defaultGroup => "${tcpout_defaultgroup}",
        },
        ensure         => 'present',
      }
      splunk_conf { 'forwarder_tcpout_defaultgroup':
        config_file => "${forwarder_confdir}${path_delimiter}outputs.conf",
        stanza      => "tcpout:${tcpout_defaultgroup}",
        set         => {
          server    => "${tcpout_server}:${splunk_logging_port}",
          useACK    => "${tcpout_useack}",
        },
        ensure      => 'present',
        require     => Splunk_conf['forwarder_tcpout'],
      }
      splunk_conf { 'forwarder_receive_tcp_splunkport':
        config_file => "${forwarder_confdir}${path_delimiter}inputs.conf",
        stanza      => "splunktcp://${splunk_logging_port}",
        ensure      => 'present',
        require     => Splunk_conf['forwarder_tcpout_defaultgroup'],
      }
      splunk_conf { 'forwarder_receive_tcp_syslogport':
        config_file => "${forwarder_confdir}${path_delimiter}inputs.conf",
        stanza      => "splunktcp://${syslogging_port}",
        ensure      => 'present',
        require     => Splunk_conf['forwarder_receive_tcp_splunkport'],
      }
      splunk_conf { 'forwarder_receive_udp_syslogport':
        config_file => "${forwarder_confdir}${path_delimiter}inputs.conf",
        stanza      => "splunkudp://${syslogging_port}",
        ensure      => 'present',
        require     => Splunk_conf['forwarder_receive_tcp_syslogport'],
        notify      => Service['splunk'],
      }
    }
    
    splunk_conf { 'forwarder_deployment-client':
      config_file => "${forwarder_confdir}${path_delimiter}deploymentclient.conf",
      stanza      => 'deployment-client',
      set         => {
        disabled  => 'true',
      },
      ensure      => 'present',
      require     => Exec['enable_splunkforwarder'],
    }
    splunk_conf { 'forwarder_target-broker_deploymentServer':
      config_file => "${forwarder_confdir}${path_delimiter}deploymentclient.conf",
      stanza      => 'target-broker:deploymentServer',
      set         => {
        targetURI => "${forwarder_splunkd_address}:${forwarder_splunkd_port}",
      },
      ensure      => 'present',
      require     => Splunk_conf['forwarder_deployment-client'],
    }
    splunk_conf { 'forwarder_webconf_settings':
      config_file    => "${forwarder_confdir}${path_delimiter}web.conf",
      stanza         => 'settings',
      set            => {
        mgmtHostPort => "${forwarder_splunkd_address}:${forwarder_splunkd_port}",
      },
      ensure         => 'present',
      require        => Splunk_conf['forwarder_target-broker_deploymentServer'],
      notify         => Service['splunk'],
    }

    if $::osfamily in ['Debian', 'RedHat'] {
      splunk_conf { 'monitor_var_log_messages':
        config_file  => "${forwarder_confdir}${path_delimiter}inputs.conf",
        stanza       => 'monitor:///var/log/messages',
        set          => {
          sourcetype => 'syslog',
        },
        ensure       => 'present',
        require      => Splunk_conf['forwarder_webconf_settings'],
        notify       => Service['splunk'],
      }
    }
    elsif $::osfamily == 'Windows' {
    }
  }

  service { 'splunk':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Exec['enable_splunkforwarder'],
  }
 
}

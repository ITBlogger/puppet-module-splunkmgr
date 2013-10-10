class splunkmgr::fw inherits splunkmgr {

  if $splunk_type in ['cluster-manager', 'clustered-indexer', 'heavy-forwarder', 'indexer', 'search-head'] {
    firewall { '100 Accept new tcp Splunk web connections':
      proto  => 'tcp',
      state  => 'NEW',
      dport  => "${splunk_web_port}",
      action => 'accept',
    }
  }

  if $splunk_type in ['clustered-indexer', 'forwarder', 'heavy-forwarder', 'indexer'] {
    firewall { '100 Accept new tcp Splunk logging connections':
      proto  => 'tcp',
      state  => 'NEW',
      dport  => "${splunk_logging_port}",
      action => 'accept',
    }
    firewall { '100 Accept new tcp syslog connections':
      proto  => 'tcp',
      state  => 'NEW',
      dport  => "${syslogging_port}",
      action => 'accept',
    }
    firewall { '100 Accept new udp syslog connections':
      proto  => 'udp',
      state  => 'NEW',
      dport  => "${syslogging_port}",
      action => 'accept',
    }
  }

  if $splunk_type in ['cluster-manager', 'clustered-indexer', 'indexer'] {
    firewall { '100 Accept new tcp Splunk daemon connections':
      proto  => 'tcp',
      state  => 'NEW',
      dport  => "${splunkd_port}",
      action => 'accept',
    }
  }

  if $splunk_type in ['clustered-indexer'] {
    firewall { '100 Accept new tcp Splunk peer cluster connections':
      proto  => 'tcp',
      state  => 'NEW',
      dport  => "${splunk_cluster_port}",
      action => 'accept',
    }
  }

}

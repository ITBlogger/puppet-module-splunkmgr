class splunk::fw inherits splunk {

  if ($splunktype in ['cluster_manager', 'clustered_indexer', 'heavy_forwarder', 'indexer', 'search_head']) {
    
    firewall { '100 allow Splunk Console':
      action => 'accept',
      proto  => 'tcp',
      dport  => "${web_port}",
    }
  }

  if ($splunktype in ['clustered_indexer', 'indexer']) {
    firewall { '100 allow Splunkd':
      action => 'accept',
      proto  => 'tcp',
      dport  => "${splunkd_port}",
    }
  }

  if ($splunktype in ['clustered_indexer', 'heavy_forwarder', 'indexer']) {

    firewall { '100 allow splunktcp logging in':
      action => 'accept',
      proto  => 'tcp',
      dport  => "${logging_port}",
    }
  }

  if ($splunktype in ['clustered_indexer', 'forwarder', 'heavy_forwarder', 'indexer']) {
    firewall { '100 allow tcp syslog logging in':
      action => 'accept',
      proto  => 'tcp',
      dport  => "${syslogging_port}",
    }
    firewall { '100 allow udp syslog logging in':
      action => 'accept',
      proto  => 'udp',
      dport  => "${syslogging_port}",
    }
  }

}

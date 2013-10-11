# itblogger-splunk

This class is a work in progress and currently is only tested to work with CentOS/RedHat. It has functionality for Windows, but has not been tested and isn't yet complete.

This class installs and configures splunk. It has been parameteritized for use with hiera 
It includes work from puppetlabs-seteam/puppet-module-splunk (https://github.com/puppetlabs-seteam/puppet-module-splunk)
and includes some tweaks and refactoring.

Example global.yaml:

	---
	classes:
	  - splunkmgr
	splunkmgr::tcpout_server:	'<your logging server>'
	splunkmgr::splunk_type:		'client'

Example <splunksearchheadnamehere>.yaml:

	---
	classes:
	  - splunkmgr
	splunkmgr::tcpout_server:	'<your logging server>' # You would enter a different FQDN for a forwarder if necessary, otherwise leave this out and use the default set in global or params.pp
	splunkmgr::splunk_type:		'search_head'

Example <splunkclusteredindexernamehere>.yaml:

	---
	classes:
	  - splunkmgr
	splunkmgr::splunk_type:		'clustered-indexer' # This makes sure that puppet doesn't control the splunk package or services, but allows it to control firewall rules

Possible parameters that can be overridden in hiera and their defaults are:

    splunkmgr::params::forwarder_splunkd_address:	'127.0.0.1'
    splunkmgr::params::forwarder_splunkd_port:		'18089'
    splunkmgr::params::server_package_name:		'splunk'
    splunkmgr::params::splunk_cluster_port:		'8080'
    splunkmgr::params::splunk_logging_port:		'9997'
    splunkmgr::params::splunk_type:			'client'
    splunkmgr::params::splunk_web_port:			'8000'
    splunkmgr::params::splunkd_address:			'127.0.0.1'
    splunkmgr::params::splunkd_port:			'8089'
    splunkmgr::params::syslogging_port:			'514'
    splunkmgr::params::tcpout_defaultgroup:		'splunkloadbal_autolb_group'
    splunkmgr::params::tcpout_server:			'splunkloadbal'
    splunkmgr::params::tcpout_useack:			'true'

Parameters that shouldn't be overridden by hiera, but are called out in init.pp (as pointers to the respective params in params.pp) so they can be used by any of the subclasses

    splunkmgr::params::forwarder_service
    splunkmgr::params::pkg_provider
    splunkmgr::params::forwarder_install_options
    splunkmgr::params::forwarder_installer_path
    splunkmgr::params::forwarder_package_name
    splunkmgr::params::forwarder_src_pkg
    splunkmgr::params::installer_root			
    splunkmgr::params::path_delimiter			
    splunkmgr::params::server_confdir

-------

- Module is only compatible with Puppet 3.x or PE 3.x because of hiera requirement and because of 'unless' logic type
- Just about all variables available in the module are compatible with hiera and can be overridden by yamls in the hierarchy
- Module matches up with style of Puppet Labs recommendations (see the Puppet Labs NTP module as I used that as my reference)
- Class paramaritized so it can work with out the enterprise console (hiera is the one true way)
- Switched installers to use an internal repo instead of Puppet (our repos are all configured to be at http://repo but you can use whatever you want)

Authors
-------
Alex Scoble

Based on work from Puppet Labs SETeam as well as dhogland

License
-------
Licensed under the terms of the Apache License, Version 2.0

Contact
-------
itblogger@gmail.com

Support
-------

Please send tickets and issues to my contact email address or at: https://github.com/itblogger/splunk/issues

Project Url
-------
https://github.com/itblogger/puppet-splunk

dependencies 'puppetlabs/firewall', '>=0.0.4'
             'Puppet Labs Puppet', '>=3.0'
             'wcooley/puppet-splunk_conf', '>=0.1.1'


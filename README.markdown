# itblogger-splunk

This class is a work in progress and does not currently function. The SETeam module that I'm basing this off of
does a lot of complicated procedures that are unnecessary when using a private repo with yum or apt. Some logic is
still required for Windows to make sure that the Windows Puppet provider is able to pull down the correct file
depending on the version of Windows that the Puppet agent is running on.


This class installs and configures splunk. It has been parameteritized for use with hiera 
It includes work from puppetlabs-seteam/puppet-module-splunk (https://github.com/puppetlabs-seteam/puppet-module-splunk)
and includes some tweaks and refactoring.

Example global.yaml:

	---
	classes:
	  - splunk::forwarder
	splunk::logging_server:         '<your logging server>' # this can also be set in params.pp
	splunk::splunktype:             'client'		# this isn't strictly necessary as this is the default set in params.pp

Example <splunksearchheadnamehere>.yaml:

	---
	classes:
	  - splunk
	splunk::logging_server:         '<your logging server>' # You would enter a different FQDN for a forwarder if necessary, otherwise leave this out and use the default set in global or params.pp
	splunk::splunktype:             'search_head'

Example <splunkclusteredindexernamehere>.yaml:

	---
	classes:
	  - splunk
	splunk::splunktype:		'clustered_indexer' # This makes sure that puppet doesn't control the splunk package or services, but allows it to control firewall rules

Possible parameters that can be overriden in hiera and their defaults are:
	splunk::splunktype:			'client'	# used to set type of splunk system. Allows more granular control than just is it a universal forwarder or server
	splunk::build:          	 	'182037'	# used to set the build of splunk to be installed
	splunk::forwarder_splunkd_port 		'18089'		# used to set the universal forwarder splunkd port that allows management by Splunk Deployment Server
								# although this seems unnecessary since we are managing Splunk with Puppet.:D
	splunk::forwarder_splunkd_listen	'127.0.0.1'	# used to set IP addresses that are allowed to manage UF via splunkd port
	splunk::logging_port    	      	'9997'		# used to change the port that Splunk uses to collect logs from universal forwarders
	splunk::package_name             	'splunk'	# 
	splunk::purge_inputs             	false		# used if the inputs.conf file is to be purged for Splunk servers and agents
	splunk::purge_outputs            	false		#
								# should make a separate set of these for universal forwarders and use the above for servers
	splunk::server                   	'splunk'	#
	splunk::splunkd_listen           	'127.0.0.1'	#
	splunk::splunkd_port             	'8089'		#
	splunk::splunktype               	'client' 	# valid values are client (non-forwarding universal forwarder), cluster_manager, clustered_indexer, forwarder (forwarding universal forwarder), heavy_forwarder, indexer, search_head
	splunk::src_root                 	'http://repo/test/3rdparty/splunk'	# where the Windows installers live
	splunk::staging_subdir           	'splunk'	#
	splunk::syslogging_port          	'514'		#
	splunk::version                  	'6.0'		#
	splunk::web_port                 	'8000		#

Changes from puppetlabs-seteam/puppet-module-splunk
-------

- Module is only compatible with Puppet 3.x or PE 3.x because of hiera requirement and because of 'unless' logic type
- Changed how parameters work so that module is compatible with hiera
- Fixed module so that it matches up with style of Puppet Labs recommendations (see the Puppet Labs NTP module as I used that as my reference)
- Made splunk class paramaritized so it can work with out the enterprise console (hiera is the one true way)
- Switched installers to use an internal repo instead of Puppet
- Simplified logic so that Debian and RedHat/CentOS systems just grab installer from private repo

Authors
-------
dhogland and reidmv from puppetlabs-seteam

Modifying Authors
-------
Alex Scoble

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


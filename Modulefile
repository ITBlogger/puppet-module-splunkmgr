name 'itblogger-splunk'
version '1.0.0'

author 'Alex Scoble modifying work done by dhogland, Will Ferrer and Ethan Brooks (Run the Business)'
license 'Apache License, Version 2.0'
project_page 'https://github.com/itblogger/splunk'
source ''
summary 'This class installs and configurs splunk. It is a paramaritized version for use with hiera of runthebusiness/puppet-splunk (https://github.com/runthebusiness/puppet-splunk) 
and includes some small bug fixes, default values added and other tweaks.'
description 'splunk

Example global.yaml:

---
classes:
  - splunk
splunk::logging_server:		'<your logging server>'
splunk::splunktype:		'client'
splunk::deploy:			'forwarder'

Example <splunksearchheadnamehere>.yaml:

---
splunk::logging_server:		'<your logging server>'
splunk::splunktype:		'search_head'
splunk::deploy:			'server'

Changes from dhogland/splunk
-------

- Module is only compatible with Puppet 3.x or PE 3.x because of hiera requirement and because of 'unless' logic type
- Changed how parameters work so that module is compatible with hiera
- Fixed module so that it matches up with style of Puppet Labs recommendations (see the Puppet Labs NTP module as I used that as my reference)
- Made splunk class paramaritized so it can work with out the enterprise console (hiera is the one true way)
- Switched installers to use an internal repo instead of Puppet
- Added support for amd64 systems
- Fixed variable name "installer" in windows set ups to reference: ${installer} (untested by probably fixed issues with windows installs)
- Add the installerfilespath option. This allows you to store your installer files in a seperate module or else where on the disk.

Author
-------
dhogland

Modifying Authors
-------
Alex Scoble
Will Ferrer, Ethan Brooks

Contributing Authors  
-------
Brendan Murtagh

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

'
dependencies 'puppetlabs/firewall', '>=0.0.4'
             'Puppet Labs Puppet', '>=3.0'

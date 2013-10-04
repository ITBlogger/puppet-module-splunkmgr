name 'itblogger-splunk'
version '1.0.0'

author 'Alex Scoble modifying work done by dhogland and (reidmv from puppetlabs-seteam)'
license 'Apache License, Version 2.0'
project_page 'https://github.com/itblogger/splunk'
source ''
summary 'This class installs and configures splunk. It is a parameteritized version for use with hiera of runthebusiness/puppet-splunk (https://github.com/runthebusiness/puppet-splunk) 

Example global.yaml:

---
classes:
  - splunk::forwarder
splunk::logging_server:		'<your logging server>'
splunk::splunktype:		'client'

Example <splunksearchheadnamehere>.yaml:

---
classes:
   - splunk
splunk::logging_server:		'<your logging server>'
splunk::splunktype:		'search_head'

---
classes:
  - splunk
splunk::splunktype:             'clustered_indexer' # This makes sure that puppet doesn't control the splunk package or services, but allows it to control firewall rules

Changes from puppetlabs-seteam/puppet-module-splunk
-------

- Module is only compatible with Puppet 3.x or PE 3.x because of hiera requirement and because of 'unless' logic type
- Changed how parameters work so that module is compatible with hiera
- Fixed module so that it matches up with style of Puppet Labs recommendations (see the Puppet Labs NTP module as I used that as my reference)
- Made splunk class paramaritized so it can work with out the enterprise console (hiera is the one true way)
- Switched installers to use an internal repo instead of Puppet

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

'
dependencies 'puppetlabs/firewall', '>=0.0.4'
             'Puppet Labs Puppet', '>=3.0'

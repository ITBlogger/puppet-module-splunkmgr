# Class: splunk
#
# This class installs and configurs splunk. It is a paramaritized version of dhogland/splunk (https://github.com/dhogland/splunk) and includes some small bug fixes and tweaks as well. Modified by Will Ferrer and Ethan Brooks of Run the Business LLC
#
# Further modified by Alex Scoble for use with hiera
#

class splunk (
  $deploy              = $splunk::params::deploy,
  $splunk_ver          = $splunk::params::splunk_ver,
  $logging_server      = $splunk::params::logging_server,
  $syslogging_port     = $splunk::params::syslogging_port,
  $logging_port        = $splunk::params::logging_port,
  $splunkd_port        = $splunk::params::splunkd_port,
  $admin_port          = $splunk::params::admin_port,
  $splunk_admin        = $splunk::params::splunk_admin,
  $splunk_admin_pass   = $splunk::params::splunk_admin_pass,
  $installerfilespath  = $splunk::params::installerfilespath,
  $windows_stage_drive = $splunk::params::windows_stage_drive,
  $splunktype          = $splunk::params::splunktype,
) inherits splunk::params {

  $installer = $deploy ? {
    'server' => $::architecture ? {
      'i386' => $::operatingsystem ? {
        /(?i)(windows)/       => $::path ? {
          #This evaluation is in here because of an issue identifying some windows architectures
          /\(x86\)/           => "splunk-${splunk_ver}-x64-release.msi",
          default             => "splunk-${splunk_ver}-x86-release.msi",
          },
      },
      'x86_64' => $::operatingsystem ? {
        /(?i)(windows)/       => "splunk-${splunk_ver}-x64-release.msi",
      },
      'amd64' => $::operatingsystem ? {
        /(?i)(windows)/       => "splunk-${splunk_ver}-x64-release.msi",
      },
    },
    'forwarder' => $::architecture ? {
      'i386' => $::operatingsystem ? {
        /(?i)(windows)/       => $::path ? {
          #This evaluation is in here because of an issue identifying some windows architectures
          /\(x86\)/           => "splunkforwarder-${splunk_ver}-x64-release.msi",
          default             => "splunkforwarder-${splunk_ver}-x86-release.msi",
        },
      },
      'x86_64' => $::operatingsystem ? {
        /(?i)(windows)/       => "splunkforwarder-${splunk_ver}-x64-release.msi",
      },
      'amd64' => $::operatingsystem ? {
        /(?i)(windows)/       => "splunkforwarder-${splunk_ver}-x64-release.msi",
      },
    },
    'syslog' => undef,
    }
  }

  if $logging_server == undef {
    fail('Error: no splunk logging server specified')
  }

  case $::kernel {
    /(?i)linux/: { include "$deploy" }
    /(?i)windows/: { 
      if $deploy == 'syslog' { 
        notify {"Err":
          message => "Syslog configuration is not available for ${::kernel} in this module.",
        }
      }
      else { 
        include "splunk::windows_$deploy" 
#        Exec {
#          path => "${::path}\;\"C:\\Program Files\\Splunk\\bin\""
#        }
      }
    }
  }

}

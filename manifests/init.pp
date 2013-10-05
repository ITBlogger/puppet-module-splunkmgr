# Class: splunk
#
# This class deploys Splunk on Linux, Windows, Solaris platforms.
#
# Parameters:
# 
#   Please see params.pp for a description of parameters used
#
# Actions:
#
#   Declares parameters to be consumed by other classes in the splunk module.
#
# Requires: Puppet 3 and Puppet Labs Firewall module
#
class splunk (
  $forwarder_confdir         = $splunk::params::forwarder_confdir,
  $forwarder_install_options = $splunk::params::forwarder_install_options,
  $forwarder_package_source  = $splunk::params::forwarder_package_source,
  $forwarder_package_name    = $splunk::params::forwarder_package_name,
  $forwarder_service         = $splunk::params::forwarder_service,
  $forwarder_splunkd_port    = $splunk::params::forwarder_splunkd_port,
  $forwarder_splunkd_listen  = $splunk::params::forwarder_splunkd_listen,
  $logging_port              = $splunk::params::logging_port,
  $package_source            = $splunk::params::package_source,
  $path_delimiter            = $splunk::params::path_delimiter,
  $pkg_provider              = $splunk::params::pkg_provider,
  $purge_inputs              = $splunk::params::purge_inputs,
  $purge_outputs             = $splunk::params::purge_outputs,
  $server                    = $splunk::params::server,
  $server_confdir            = $splunk::params::server_confdir,
  $server_package_name       = $splunk::params::server_package_name,
  $server_service            = $splunk::params::server_service,
  $splunkd_port              = $splunk::params::splunkd_port,
  $splunkd_listen            = $splunk::params::splunkd_listen,
  $splunktype                = $splunk::params::splunktype,
  $staging_subdir            = $splunk::params::staging_subdir,
  $syslogging_port           = $splunk::params::syslogging_port,
  $web_port                  = $splunk::params::web_port,
) inherits splunk::params {

  include splunk::fw

  unless ($splunktype == 'clustered_indexer') {
    include staging

    $staged_package  = staging_parse($package_source)
    $pkg_path_parts  = [$staging::path, $staging_subdir, $staged_package]
    $pkg_source      = join($pkg_path_parts, $path_delimiter)

    staging::file { $staged_package:
      source => $package_source,
      subdir => $staging_subdir,
      before => Package[$package_name],
    }

    package { $server_package_name:
      ensure   => installed,
      provider => $pkg_provider,
      source   => $pkg_source,
      before   => Service[$server_service],
      tag      => 'splunk_server',
    }

    splunk_input { 'default_host':
      section => 'default',
      setting => 'host',
      value   => $::clientcert,
      tag     => 'splunk_server',
    }
    splunk_input { 'default_splunktcp':
      section => "splunktcp://:${logging_port}",
      setting => 'connection_host',
      value   => 'dns',
      tag     => 'splunk_server',
    }
    ini_setting { "splunk_server_splunkd_port":
      path    => "${server_confdir}/web.conf",
      section => 'settings',
      setting => 'mgmtHostPort',
      value   => "${splunkd_listen}:${splunkd_port}",
      require => Package[$server_package_name],
      notify  => Service[$server_service],
    }
    ini_setting { "splunk_server_web_port":
      path    => "${server_confdir}/web.conf",
      section => 'settings',
      setting => 'httpport',
      value   => $web_port,
      require => Package[$server_package_name],
      notify  => Service[$server_service],
    }

    # If the purge parameters have been set, remove all unmanaged entries from
    # the inputs.conf and outputs.conf files, respectively.
    if $purge_inputs  {
      resources { 'splunkforwarder_input':  purge => true; }
    }
    if $purge_outputs {
      resources { 'splunkforwarder_output': purge => true; }
    }

    # This is a module that supports multiple platforms. For some platforms
    # there is non-generic configuration that needs to be declared in addition
    # to the agnostic resources declared here.
    case $::kernel {
      default: { } # no special configuration needed
      'Linux': { include splunk::platform::posix   }
      'SunOS': { include splunk::platform::solaris }
    }

    # Realize resources shared between server and forwarder profiles, and set up
    # dependency chains.
    include splunk::virtual

    # This realize() call is because the collectors don't seem to work well with
    # arrays. They'll set the dependencies but not realize all Service resources
    realize(Service[$server_service])

    Package       <| title == $package_name   |> ->
    Exec          <| tag   == 'splunk_server' |> ->
    Service       <| title == $server_service |>

    Package       <| title == $package_name   |> ->
    Splunk_input  <| tag   == 'splunk_server' |> ~>
    Service       <| title == $server_service |>

    Package       <| title == $package_name   |> ->
    Splunk_output <| tag   == 'splunk_server' |> ~>
    Service       <| title == $server_service |>

    # Validate: if both Splunk and Splunk Universal Forwarder are installed on
    # the same system, then they must use different admin ports.
    if (defined(Class['splunk']) and defined(Class['splunk::forwarder'])) {
      if $splunkd_port == $forwarder_splunkd_port {
        fail(regsubst("Both splunk and splunk::forwarder are included, but both
          are configured to use the same splunkd port (${splunkd_port}). Please either
          include only one of splunk, splunk::forwarder, or else configure them
          to use non-conflicting splunkd ports.", '\s\s+', ' ', 'G')
        )
      }
    }
  }

}

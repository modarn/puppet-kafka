# Author::    Liam Bennett  (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Class: kafka::consumer::service
#
# This private class is meant to be called from `kafka::consumer`.
# It manages the kafka-consumer service
#
class kafka::consumer::service(
  String $user                               = $kafka::consumer::user,
  String $group                              = $kafka::consumer::group,
  Stdlib::Absolutepath $config_dir           = $kafka::consumer::config_dir,
  Stdlib::Absolutepath $log_dir              = $kafka::consumer::log_dir,
  Stdlib::Absolutepath $bin_dir              = $kafka::consumer::bin_dir,
  String $service_name                       = $kafka::consumer::service_name,
  Boolean $service_install                   = $kafka::consumer::service_install,
  Enum['running', 'stopped'] $service_ensure = $kafka::consumer::service_ensure,
  Boolean $service_requires_zookeeper        = $kafka::consumer::service_requires_zookeeper,
  Integer $limit_nofile                      = $kafka::consumer::limit_nofile,
  Hash $env                                  = $kafka::consumer::env,
  $consumer_jmx_opts                         = $kafka::consumer::consumer_jmx_opts,
  $consumer_log4j_opts                       = $kafka::consumer::consumer_log4j_opts,
  $service_config                            = $kafka::consumer::service_config,
  $service_defaults                          = $kafka::consumer::service_defaults,
) {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $service_install {
    $consumer_service_config = deep_merge($service_defaults, $service_config)

    if $consumer_service_config['topic'] == '' {
      fail('[Consumer] You need to specify a value for topic')
    }
    if $consumer_service_config['zookeeper'] == '' {
      fail('[Consumer] You need to specify a value for zookeeper')
    }

    $env_defaults = {
      'KAFKA_JMX_OPTS'   => $consumer_jmx_opts,
      'KAFKA_LOG4J_OPTS' => $consumer_log4j_opts,
    }
    $environment = deep_merge($env_defaults, $env)

    if $::service_provider == 'systemd' {
      include ::systemd

      file { "/etc/systemd/system/${service_name}.service":
        ensure  => file,
        mode    => '0644',
        content => template('kafka/unit.erb'),
      }

      file { "/etc/init.d/${service_name}":
        ensure => absent,
      }

      File["/etc/systemd/system/${service_name}.service"]
      ~> Exec['systemctl-daemon-reload']
      -> Service[$service_name]

    } else {
      file { "/etc/init.d/${service_name}":
        ensure  => file,
        mode    => '0755',
        content => template('kafka/init.erb'),
        before  => Service[$service_name],
      }
    }

    service { $service_name:
      ensure     => $service_ensure,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
    }
  }
}

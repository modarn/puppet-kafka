# Author::    Liam Bennett  (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Class: kafka::producer::install
#
# This private class is meant to be called from `kafka::producer`.
# It downloads the package and installs it.
#
class kafka::producer::install {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if !defined(Class['::kafka']) {
    class { '::kafka':
      version       => $kafka::producer::version,
      scala_version => $kafka::producer::scala_version,
      install_dir   => $kafka::producer::install_dir,
      mirror_url    => $kafka::producer::mirror_url,
      install_java  => $kafka::producer::install_java,
      package_dir   => $kafka::producer::package_dir,
      user          => $kafka::producer::user,
      group         => $kafka::producer::group,
      user_id       => $kafka::producer::user_id,
      group_id      => $kafka::producer::group_id,
    }
  }
}

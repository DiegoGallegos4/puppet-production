# Class: nhproduction
# ===========================
#
# Full description of class nhproduction here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'nhproduction':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2017 Your name here, unless otherwise noted.
#

class nhproduction($app, ) {
  $dirname = lookup('dirname')
  $servername = lookup("servername")
  class {'nginx': }
  notify{ 'vars' : message => "${server_name} ${dir_name}"}
  file { '/var/www':
    ensure  => 'directory',
  }
  
  file{ "001-${app}.conf":
    path    => "/etc/nginx/conf.d/001-${app}.conf",
    ensure  => 'file',
    require => Class['nginx'],
    content => template('nhproduction/vhost.erb'),
  }
  
  class { '::php::globals':
    php_version => '7.0',
    config_root => '/etc/php/7.0',
  }->
  class { '::php': 
    ensure       => latest,
    manage_repos => true,
    fpm          => true,
    composer     => true,
    phpunit      => true,
    extensions   => {
      imagick => {},
      intl    => {},
      mcrypt  => {},
      xmlrpc  => {},
      opcache => {},
      pgsql => {}
    }
  }
  
  class { '::postgresql::server': }

  postgresql::server::db { 'nh': 
    user     => 'nh',
    password => postgresql_password('nh', 'nh17'),
  }

  postgresql::server::role { 'admin':
    password_hash => postgresql_password('nh','nh17'),
    superuser     =>  true,
  }

  postgresql::server::database_grant { "nh":
    privilege => 'ALL',
    db        => 'nh',
    role      => 'admin',
  }


}

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
  $certname = lookup("certname")
  $certdir = lookup("certdir")
  $path = ['/bin/','/sbin/','/usr/bin/','/usr/sbin/'] 
  $github_token = lookup("github_token")
  
  class {'nginx': 
    before => Class['nhproduction::ssl'],
  }
  
  class {'nhproduction::ssl':
    certname => $certname,
    certdir  => $certdir,
  }

  file { '/var/www':
    ensure => 'directory',
    owner  => 'www-data',
    group  => 'www-data',
    mode   => '755',
  }
  
  file{ "001-${app}.conf":
    path    => "/etc/nginx/sites-available/001-${app}.conf",
    ensure  => 'file',
    require => Class['nginx'],
    content => template('nhproduction/vhost.erb'),
  }

  ->
  exec { 'symlink configuration file to sites-enabled':
    command => "ln -s /etc/nginx/sites-available/001-${app}.conf /etc/nginx/sites-enabled/001-${app}.conf",
    creates => ["/etc/nginx/sites-enabled/001-${app}.conf"],
    path    => $path
  }


  file {"/etc/nginx/ssl": 
    ensure  => "directory",
    require =>  Class['nginx'],
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
      imagick  => {},
      mbstring => {},
      intl     => {},
      mcrypt   => {},
      xmlrpc   => {},
      pgsql    => {},
      zip      => {},
      xml      => {},
      curl     => {},
      gd       => {},
      
    }
  }
  
  exec { 'change permissions to composer bin':
    command => 'chmod 755 /usr/local/bin/composer',
    path    => $path,
    require => Class['::php'],
  }
  
  ->
  exec { 'set composer github token':
    command     => "composer config --global github-oauth.github.com ${github_token}",
    path        => '/usr/bin:/usr/local/bin:~/.composer/vendor/bin',
    environment => ["COMPOSER_HOME=/usr/local/bin"],
  }
  
  ->
  exec { 'install fxp plugin':
    command => 'composer global require "fxp/composer-asset-plugin:^1.2.0"',
    path        => '/usr/bin:/usr/local/bin:~/.composer/vendor/bin',
    environment => ["COMPOSER_HOME=/usr/local/bin"],
  }

  ->
  exec{ 'composer install codeception':
    command =>  'composer global require "codeception/codeception"',
    path        => '/usr/bin:/usr/local/bin:~/.composer/vendor/bin',
    environment => ["COMPOSER_HOME=/usr/local/bin"],
  }
  
#->
# exec { 'change ownership to .composer directory':
#   command => 'chown -R it:it /home/it/.composer',
#   path    => $path
# }

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

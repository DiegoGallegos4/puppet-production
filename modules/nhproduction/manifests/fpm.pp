class nhproduction::fpm{
  exec{ 'fpm sock config':
    command => "sed -i 's/listen = 127.0.0.1:9000/listen = /var/run/php/php7.0-fpm.sock/g' /etc/php/7.0/fpm/pool.d/www.conf",
    path    => $path,
  }
  
  ->
  exec{ 'fpm user':
    command => "sed -i 's/;listen.owner = nobody/listen.owner = www-data/g' /etc/php/7.0/fpm/pool.d/www.conf",
    path    => $path,
  }

  ->
  exec{ 'fpm group':
    command => "sed -i 's/;listen.group = nobody/listen.group = www-data/g' /etc/php/7.0/fpm/pool.d/www.conf",
    path    => $path,
  }

  ->
  exec{ 'fpm mode':
    command => "sed -i 's/;listen.mode = 0660/listen.mode = 0600'",
    path    => $path,
  }
}

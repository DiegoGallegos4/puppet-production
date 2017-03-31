  exec{ 'fpm sock config':
    command => "sed -i 's/listen = 127.0.0.1:9000/listen = /var/run/php/php7.0-fpm.sock/g' /etc/php/7.0/fpm/pool.d/www.conf",
    path    => $path,
  }
  
  ->
  exec{ 'fpm user':
    command => "sed -i 's/;user = nobody/user = www-data/g' /etc/php/7.0/fpm/pool.d/www.conf",
    path    => $path,
  }

  ->
  exec{ 'fpm group':
    command => "sed -i 's/;group = nobody/group = www-data/g' /etc/php/7.0/fpm/pool.d/www.conf",
    path    => $path,
  }

  ->

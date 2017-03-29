# CRM
node "nhvla09.nuevoshorizontes.com"{
  $dirname = 'crm.panoramalife.com'
  $servername= 'crm.panoramalife.com'
  
  class {'linux': }
  class {'nhproduction': 
    app => 'crm',
  }

}

# Frontdesk
node "nhvla10.nuevoshorizontes.com"{
  $dirname = 'frontdesk.panoramalife.com'
  $servername = 'frontdesk.panoramalife.com' 
  class {'nhproduction':
    app => 'frontdesk',
  }
}

# ERP
node "nhvla11.nuevoshorizontes.com"{

}

class linux{
  $admintools = ['git', 'vim', 'screen']

  package{ $admintools: 
    ensure => 'installed',
  }

  $ntpservice = $osfamily ? {
    'redhead' =>  'ntpd',
    'debian'  =>  'ntp',
    default =>  'ntp',
  }

  file { "/info.txt":
    ensure  => "present",
    content => inline_template("Created Puppet at <%= Time.now %>\n"),
  }

  package { 'ntp':
    ensure =>  'installed',
  }

  service { $ntpservice:
    ensure => 'running',
    enable =>  true,
  }
}

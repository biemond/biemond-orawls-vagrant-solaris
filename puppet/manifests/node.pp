# test
#
# one machine setup with weblogic 12.1.2
# creates an WLS Domain with JAX-WS (advanced, soap over jms)
# needs jdk7, orawls, orautils, fiddyspence-sysctl, erwbgy-limits puppet modules
#

node 'nodesol1.example.com', 'nodesol2.example.com' {
  
  include os, ssh
#  include java, orawls::weblogic, bsu, orautils, copydomain, nodemanager

#  Class['java'] -> Class['orawls::weblogic'] 
}

# operating settings for Middleware
class os {

  notify { "class os ${operatingsystem}":} 

  host{"adminsol":
    ip => "10.10.10.10",
    host_aliases => ['adminsol.example.com','adminsol'],
  }


  group { 'dba' :
    ensure => present,
  }

  # http://raftaman.net/?p=1311 for generating password
  user { 'oracle' :
    ensure     => present,
    groups     => 'dba',
    shell      => '/bin/bash',
    password   => '$1$DSJ51vh6$4XzzwyIOk6Bi/54kglGk3.',
    home       => "/export/home/oracle",
    comment    => 'Oracle user created by Puppet',
    managehome => true,
    require    => Group['dba'],
  }

}

class ssh {
  require os

  file { "/export/home/oracle/.ssh/":
    owner  => "oracle",
    group  => "dba",
    mode   => "700",
    ensure => "directory",
    alias  => "oracle-ssh-dir",
  }
  
  file { "/export/home/oracle/.ssh/id_rsa.pub":
    ensure  => present,
    owner   => "oracle",
    group   => "dba",
    mode    => "644",
    source  => "/vagrant/ssh/id_rsa.pub",
    require => File["oracle-ssh-dir"],
  }
  
  file { "/export/home/oracle/.ssh/id_rsa":
    ensure  => present,
    owner   => "oracle",
    group   => "dba",
    mode    => "600",
    source  => "/vagrant/ssh/id_rsa",
    require => File["oracle-ssh-dir"],
  }
  
  file { "/export/home/oracle/.ssh/authorized_keys":
    ensure  => present,
    owner   => "oracle",
    group   => "dba",
    mode    => "644",
    source  => "/vagrant/ssh/id_rsa.pub",
    require => File["oracle-ssh-dir"],
  }        
}


class java {
  require os


}

class bsu {
  require orawls::weblogic

  notify { 'class bsu':} 
  $default_params = {}
  $bsu_instances = hiera('bsu_instances', [])
  create_resources('orawls::bsu',$bsu_instances, $default_params)
}

class copydomain {
  require orawls::weblogic, bsu


  notify { 'class copydomain':} 
  $default_params = {}
  $copy_instances = hiera('copy_instances', [])
  create_resources('orawls::copydomain',$copy_instances, $default_params)

}


class nodemanager {
  require orawls::weblogic, bsu, copydomain

  notify { 'class nodemanager':} 
  $default_params = {}
  $nodemanager_instances = hiera('nodemanager_instances', [])
  create_resources('orawls::nodemanager',$nodemanager_instances, $default_params)
}
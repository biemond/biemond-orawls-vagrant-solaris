# test
#
# one machine setup with weblogic 12.1.2
# creates an WLS Domain with JAX-WS (advanced, soap over jms)
# needs jdksolaris, orawls, orautils
#

node 'nodesol1.example.com', 'nodesol2.example.com' {
  
  include os, ssh
  include java, orawls::weblogic, opatch, orautils, copydomain, nodemanager

  Class['java'] -> Class['orawls::weblogic'] 
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

  notice 'class java'

  jdksolaris::install7{'jdk1.7.0_45':
    version              => '7u45',
    fullVersion          => 'jdk1.7.0_45',
    x64                  => true,
    downloadDir          => '/data/install',
    sourcePath           => "/vagrant",
  }  


}

class opatch{
  require orawls::weblogic

  notice 'class opatch'
  $default_params = {}
  $opatch_instances = hiera('opatch_instances', [])
  create_resources('orawls::opatch',$opatch_instances, $default_params)
}


class copydomain {
  require orawls::weblogic, opatch


  notify { 'class copydomain':} 
  $default_params = {}
  $copy_instances = hiera('copy_instances', [])
  create_resources('orawls::copydomain',$copy_instances, $default_params)

}


class nodemanager {
  require orawls::weblogic, opatch, copydomain

  notify { 'class nodemanager':} 
  $default_params = {}
  $nodemanager_instances = hiera('nodemanager_instances', [])
  create_resources('orawls::nodemanager',$nodemanager_instances, $default_params)
}
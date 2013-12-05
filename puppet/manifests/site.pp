# test
#
# one machine setup with weblogic 12.1.2
# creates an WLS Domain with JAX-WS (advanced, soap over jms)
# needs jdk7, orawls, orautils, fiddyspence-sysctl, erwbgy-limits puppet modules
#

node 'adminsol.example.com' {

  
   include os, ssh
   include java
#   include orawls::weblogic, orautils
#  include bsu, domains, nodemanager, startwls, userconfig
#  include machines, managed_servers
#  include clusters
#  include jms_servers,jms_saf_agents
#  include jms_modules,jms_module_subdeployments
#  include jms_module_foreign_server_objects,jms_module_foreign_server_entries_objects
#  include jms_module_quotas,jms_module_cfs,jms_module_objects_errors
#  include jms_module_objects
#  include pack_domain
#
#  Class['java'] -> Class['orawls::weblogic']
}


# operating settings for Middleware
class os {

  notice "class os ${operatingsystem}"

  host{"node1":
    ip => "10.10.10.100",
    host_aliases => ['nodesol1.example.com','node1'],
  }

  host{"node2":
    ip => "10.10.10.200",
    host_aliases => ['nodesol2.example.com','node2'],
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

  notice 'class ssh'

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


class bsu{
  require orawls::weblogic

  notice 'class bsu'
  $default_params = {}
  $bsu_instances = hiera('bsu_instances', [])
  create_resources('orawls::bsu',$bsu_instances, $default_params)
}

class domains{
  require orawls::weblogic, bsu

  notice 'class domains'
  $default_params = {}
  $domain_instances = hiera('domain_instances', [])
  create_resources('orawls::domain',$domain_instances, $default_params)
}

class nodemanager {
  require orawls::weblogic, domains

  notify { 'class nodemanager':} 
  $default_params = {}
  $nodemanager_instances = hiera('nodemanager_instances', [])
  create_resources('orawls::nodemanager',$nodemanager_instances, $default_params)
}

class startwls {
  require orawls::weblogic, domains,nodemanager


  notify { 'class startwls':} 
  $default_params = {}
  $control_instances = hiera('control_instances', [])
  create_resources('orawls::control',$control_instances, $default_params)
}

class userconfig{
  require orawls::weblogic, domains, nodemanager, startwls 

  notify { 'class userconfig':} 
  $default_params = {}
  $userconfig_instances = hiera('userconfig_instances', [])
  create_resources('orawls::storeuserconfig',$userconfig_instances, $default_params)
} 

class machines{
  require userconfig

  notify { 'class machines':} 
  $default_params = {}
  $machines_instances = hiera('machines_instances', [])
  create_resources('orawls::wlstexec',$machines_instances, $default_params)
}

class managed_servers{
  require machines

  notify { 'class managed_servers':} 
  # lookup all managed_servers_instances in all hiera files
  $allHieraEntries = hiera_array('managed_servers_instances')
  orawls::utils::wlstbulk{ 'managed_servers_instances':
    entries_array => $allHieraEntries,
  }

}

class clusters{
  require managed_servers

  notify { 'class clusters':} 
  # lookup all managed_servers_instances in all hiera files
  $allHieraEntries = hiera_array('cluster_instances')
  orawls::utils::wlstbulk{ 'cluster_instances':
    entries_array => $allHieraEntries,
  }

}


class jms_servers{
  require clusters

  notify { 'class jms_servers':} 
  # lookup all managed_servers_instances in all hiera files
  $allHieraEntries = hiera_array('jms_servers_instances')
  orawls::utils::wlstbulk{ 'jms_servers_instances':
    entries_array => $allHieraEntries,
  }

}

class jms_saf_agents{
  require jms_servers

  notify { 'class jms_saf_agents':} 
  # lookup all managed_servers_instances in all hiera files
  $allHieraEntries = hiera_array('jms_saf_agents_instances')
  orawls::utils::wlstbulk{ 'jms_saf_agents_instances':
    entries_array => $allHieraEntries,
  }

}

class jms_modules{
  require jms_saf_agents

  notify { 'class jms_modules':} 

  # lookup all managed_servers_instances in all hiera files
  $allHieraEntries = hiera_array('jms_module_instances')
  orawls::utils::wlstbulk{ 'jms_module_instances':
    entries_array => $allHieraEntries,
  }

}

class jms_module_subdeployments{
  require jms_modules

  notify { 'class jms_module_subdeployments':} 
  # lookup all managed_servers_instances in all hiera files
  $allHieraEntries = hiera_array('jms_module_subdeployments_instances')
  orawls::utils::wlstbulk{ 'jms_module_subdeployments_instances':
    entries_array => $allHieraEntries,
  }

}
class jms_module_quotas{
  require jms_module_subdeployments

  notify { 'class jms_module_quotas':} 
  # lookup all managed_servers_instances in all hiera files
  $allHieraEntries = hiera_array('jms_module_quotas_instances')
  orawls::utils::wlstbulk{ 'jms_module_quotas_instances':
    entries_array => $allHieraEntries,
  }

}

class jms_module_cfs{
  require jms_module_quotas

  notify { 'class jms_module_cfs':} 
  # lookup all managed_servers_instances in all hiera files
  $allHieraEntries = hiera_array('jms_module_cf_instances')
  orawls::utils::wlstbulk{ 'jms_module_cf_instances':
    entries_array => $allHieraEntries,
  }
}

class jms_module_objects_errors{
  require jms_module_cfs

  notify { 'class jms_module_objects_errors':} 
  # lookup all managed_servers_instances in all hiera files
  $allHieraEntries = hiera_array('jms_module_jms_errors_instances')
  orawls::utils::wlstbulk{ 'jms_module_jms_errors_instances':
    entries_array => $allHieraEntries,
  }
}

class jms_module_objects{
  require jms_module_objects_errors

  notify { 'class jms_module_objects':} 
  # lookup all jms_instances in all hiera files
  $allHieraEntries = hiera_array('jms_module_jms_instances')

  orawls::utils::wlstbulk{ 'jms_module_jms_instances':
    entries_array => $allHieraEntries,
  }
}

class jms_module_foreign_server_objects{
  require jms_module_objects

  notify { 'class jms_module_foreign_server_objects':} 
  # lookup all jms_instances in all hiera files
  $allHieraEntries = hiera_array('jms_module_foreign_server_instances')

  orawls::utils::wlstbulk{ 'jms_module_foreign_server_objects':
    entries_array => $allHieraEntries,
  }
}

class jms_module_foreign_server_entries_objects{
  require jms_module_foreign_server_objects

  notify { 'class jms_module_foreign_server_entries_objects':} 
  # lookup all jms_instances in all hiera files
  $allHieraEntries = hiera_array('jms_module_foreign_server_objects_instances')

  orawls::utils::wlstbulk{ 'jms_module_foreign_server_objects_instances':
    entries_array => $allHieraEntries,
  }
}


class pack_domain{
  require jms_module_foreign_server_entries_objects

  notify { 'class pack_domain':} 
  $default_params = {}
  $pack_domain_instances = hiera('pack_domain_instances', $default_params)
  create_resources('orawls::packdomain',$pack_domain_instances, $default_params)
}
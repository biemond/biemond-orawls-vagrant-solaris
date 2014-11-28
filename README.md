## biemond-orawls-vagrant-solaris

The reference implementation of https://github.com/biemond/biemond-orawls
optimized for linux, solaris

creates a 12.1.3 WebLogic cluster ( adminsol,nodesol1 , nodesol2 )

site.pp is located here:
https://github.com/biemond/biemond-orawls-vagrant-solaris/blob/master/puppet/manifests/site.pp

The used hiera files https://github.com/biemond/biemond-orawls-vagrant-solaris/tree/master/puppet/hieradata

###Vagrant
Update the vagrant /software share to your local binaries folder


###Software
JDK
- jdk-7u71-solaris-i586.gz
- jdk-7u71-solaris-x64.gz

Weblogic 12.1.3
- fmw_12.1.3.0.0_wls.jar

### admin server
vagrant up adminsol

### node1
vagrant up nodesol1

#### node2
vagrant up nodesol2


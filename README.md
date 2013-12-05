biemond-orawls-vagrant-solaris
==============================

The reference implementation of https://github.com/biemond/biemond-orawls  
optimized for linux,solaris and the use of Hiera  


creates a patched 10.3.6 WebLogic cluster ( adminsol,nodesol1 , nodesol2 )


site.pp is located here:  
https://github.com/biemond/biemond-orawls-vagrant-solaris/blob/master/puppet/manifests/site.pp  

The used hiera files https://github.com/biemond/biemond-orawls-vagrant-solaris/tree/master/puppet/hieradata

used the following software
- jdk..

weblogic 10.3.6
- wls1036_generic.jar
- p17071663_1036_Generic.zip

- ofm_osb_generic_11.1.1.7.0_disk1_1of1.zip
- ofm_soa_generic_11.1.1.7.0_disk1_1of2.zip
- ofm_soa_generic_11.1.1.7.0_disk1_2of2.zip

Using the following facts

- environment => "development"
- vm_type     => "vagrant"
- env_app1    => "application_One"
- env_app2    => "application_Two"

also need to set "--parser future" to the puppet configuration, cause it uses lambda expressions for collection of yaml entries from application_One and application_Two


Should also work for WebLogic 12.1.2

weblogic 12.1.2
- wls_121200.jar or fmw_infra_121200.jar
- p16175470_121200_Generic.zip


# admin server  
vagrant up adminsol

# node1  
vagrant up nodesol1

# node2  
vagrant up nodesol2


Detailed vagrant steps (setup) can be found here:

http://vbatik.wordpress.com/2013/10/11/weblogic-12-1-2-00-with-vagrant/

For Mac Users.  The procedure has been and run tested on Mac.

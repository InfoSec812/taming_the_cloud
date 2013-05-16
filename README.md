<center><big>Taming The Cloud</big></center>

<center>Managing Massive Network with Minimal Manpower</center>

This repository contains a "standard" puppet layout for use with the 
<a href="https://plus.google.com/s/%23MOSSCon13" target="_blank">MOSSCon13</a> 
workshop by the same name. Using this repository as a starting point for 
building your puppet configuration would probably simplify your initial setup.

In order to configure your puppetmaster to use these folders, clone this
repository into a folder called "production" under the /etc/puppet directory:

    cd /etc/puppet
    git clone git@github.com:InfoSec812/taming_the_cloud.git production
    

After cloning the repo, modify the /etc/puppet/puppet.conf file to look like:

    [main]
            logdir=/var/log/puppet
            vardir=/var/lib/puppet
            ssldir=/etc/puppet/ssl
            rundir=/var/run/puppet
            factpath=$vardir/lib/facter
            prerun_command=/etc/puppet/etckeeper-commit-pre
            postrun_command=/etc/puppet/etckeeper-commit-post
            server=puppetmaster
            certname=puppetmaster
    
    [master]
            # These are needed when the puppetmaster is run by passenger
            # and can safely be removed if webrick is used.
            ssl_client_header = SSL_CLIENT_S_DN
            ssl_client_verify_header = SSL_CLIENT_VERIFY
            storeconfigs=true
            certname=puppetmaster
            server=puppetmaster
    [production]
            manifest = $confdir/production/manifests/site.pp
            modules = $confdir/production/modules
            templatedir = $confdir/production/templates
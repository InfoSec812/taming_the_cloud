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
            templatedir=$confdir/templates
            prerun_command=/etc/puppet/etckeeper-commit-pre
            postrun_command=/etc/puppet/etckeeper-commit-post
            server = lou1
            certname = lou1
    
    [master]
            # These are needed when the puppetmaster is run by passenger
            # and can safely be removed if webrick is used.
            ssl_client_header = SSL_CLIENT_S_DN
            ssl_client_verify_header = SSL_CLIENT_VERIFY
            modulepath=/etc/puppet/modules
            storeconfigs=true
            dbadapter=postgresql
            dbuser=foreman
            dbpassword=foreman
            dbserver=localhost
            dbname=foreman
            reports=log, foreman
            certname=lou1
            server=lou1
    [production]
            manifest = $confdir/manifests/site.pp

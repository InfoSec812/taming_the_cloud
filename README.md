# Taming The Cloud

## Managing Massive Networks with Minimal Manpower

This repository contains a **standard** puppet layout for use with the 
<a href="https://plus.google.com/s/%23MOSSCon13" target="_blank">MOSSCon13</a> 
workshop by the same name. Using this repository as a starting point for 
building your puppet configuration would probably simplify your initial setup.

In order to configure your puppetmaster to use these folders, clone this
repository into a folder called **production** under the **/etc/puppet** directory:

    cd /etc/puppet
    git clone git@github.com:InfoSec812/taming_the_cloud.git production
    

After cloning the repo, add the following section to the **/etc/puppet/puppet.conf** file:

    [production]
            manifest = $confdir/production/manifests/site.pp
            modules = $confdir/production/modules
            templatedir = $confdir/production/templates

The Prezi presentation can be found <a href="http://prezi.com/c91nyhid0gsw/taming-the-cloud/?utm_source=prezi-view&utm_medium=ending-bar&utm_content=Title-link&utm_campaign=ending-bar-tryout" target="__blank">HERE</a>.

# Class: puppetlabs_repo
#
# Thei class configured the DNS.com package repositories
#
# Parameters:
#
# Actions:
#   Based on the distribution being managed, installs the appropriate repo configuration
#
# Sample Usage:
#

class puppetlabs_repo {
  $repoType = $operatingsystem ? {
    /(redhat|centos|fedora|RedHat|CentOS|Fedora)/ => "yum",
    default => "apt",
  }

  $pkgArch = $hardwaremodel ? {
    /i[356]86/ => "i386",
    default    => "x86_64",
  }

  case $repoType {
    yum     : {
      yumrepo { "puppetlabs-main":
        baseurl  => "http://yum.puppetlabs.com/el/5/products/${pkgArch}/",
        name     => "puppetlabs-main",
        enabled  => 1,
        gpgcheck => 0,
        notify   => Exec['instantRepoUpdate'],
      }

      yumrepo { "puppetlabs-deps":
        baseurl  => "http://yum.puppetlabs.com/el/5/dependencies/${pkgArch}/",
        name     => "puppetlabs-deps",
        enabled  => 1,
        gpgcheck => 0,
        notify   => Exec['instantRepoUpdate'],
      }

      yumrepo { "puppetlabs-extras":
        baseurl  => "http://yum.puppetlabs.com/el/5/extras/${pkgArch}/",
        name     => "puppetlabs-extras",
        enabled  => 1,
        gpgcheck => 0,
        notify   => Exec['instantRepoUpdate'],
      }
    }

    apt     : {
      file { "/etc/apt/sources.list.d/puppetlabs.list":
        owner   => "root",
        group   => "root",
        mode    => "0644",
        ensure  => present,
        source  => "puppet:///modules/conffiles/generic_node/etc/apt/sources.list.d/puppetlabs.list",
        require => Exec['addPuppetLabsAptKey'],
        notify  => Exec['instantRepoUpdate'],
      }

      exec { "addPuppetLabsAptKey":
        command => '/usr/bin/wget -O- -q "http://apt.puppetlabs.com/pubkey.gpg" | /usr/bin/apt-key add -',
        unless  => "/usr/bin/apt-key list | /bin/grep 4BD6EC30",
        notify  => Exec['instantRepoUpdate'],
      }
    }

    default : {
    }
  }
}

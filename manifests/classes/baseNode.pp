class baseNode (
  $puppetHostName,
  $puppetMasterServer  = "puppetmaster.zanclus.com",
  $installPuppet       = true,
  $installDhcp         = false,
  $setHosts            = true,
  $puppetEnvironment   = "production",
  $installShellHelpers = true,
  $puppetDebug         = false) {

  package { "rubygems": ensure => latest, }

  if $operatingsystem == "ubuntu" or $operatingsystem == "debian" {
    package { "augeas-tools": ensure => latest, }
  } else {
    package { "augeas":
      ensure => latest,
      alias  => "augeas-tools",
    }
  }

  if $installDhcp {
    if $operatingsystem == "Ubuntu" or $operatingsystem == "Debian" or $operatingsystem == "ubuntu" or $operatingsystem == "debian" 
    {
      package { "dhcpcd": ensure => latest, }

      package { "pump": ensure => absent, }

      package { "isc-dhcp-client": ensure => absent, }
    } else {
      package { "dhcp":
        ensure => latest,
        alias  => "dhcpcd",
      }

      package { "pump": ensure => absent, }

      package { "isc-dhcp-client":
        ensure => absent,
        alias  => "isc-dhcp-client",
      }
    }
  }

  class { mcollective:
    identity           => $puppetHostName,
  }

  if ($installPuppet) {
    service { "puppet":
      enable  => false,
      require => Package['puppet'],
    }

    file { "/etc/puppet/puppet.conf":
      content => template('puppet.conf.erb'),
      owner   => "root",
      group   => "root",
      mode    => "0644",
      ensure  => present,
    }

    if ($operatingsystem == "debian" or $operatingsystem == "ubuntu" or $operatingsystem == "Debian" or $operatingsystem == "Ubuntu"
    ) {
      $puppetVersion = "3.1.0-1puppetlabs1"

      package { "puppet-common": ensure => $puppetVersion, }

      package { "puppet":
        ensure  => $puppetVersion,
        require => Package['puppet-common'],
      }

      augeas { "puppet-defaults":
        context => "/files/etc/default/puppet",
        changes => ["set START no",],
        require => Package['puppet'],
      }
    } else {
      $puppetVersion = "3.1.0-1.el5"

      package { "puppet": ensure => $puppetVersion, }
    }

  }

  if ($installShellHelpers) {
    package { "htop": ensure => latest, }

    package { "bash": ensure => latest, }

    package { "tcpdump": ensure => latest, }

    if ($operatingsystem == "debian" or $operatingsystem == "ubuntu" or $operatingsystem == "Debian" or $operatingsystem == "Ubuntu"
    ) {
      package { "dnstop": ensure => latest, }

      file { "/etc/bash.bashrc":
        content => template('bashrc.erb'),
        owner   => "root",
        group   => "root",
        mode    => "0644",
        ensure  => present,
      }

      package { "vim": ensure => latest, }
    } else {
      package { "epel-release": ensure => latest, }

      file { "/etc/bashrc":
        content => template('bashrc.erb'),
        owner   => "root",
        group   => "root",
        mode    => "0644",
        ensure  => present,
      }

      package { "vim-enhanced":
        ensure => latest,
        alias  => "vim"
      }
    }

    package { "screen": ensure => latest, }

    file { "/etc/screenrc":
      content => template('screenrc.erb'),
      owner   => "root",
      group   => "root",
      mode    => "0644",
      ensure  => present,
    }
  }

  include ntp
}

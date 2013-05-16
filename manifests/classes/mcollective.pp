class mcollective (
  $installMaster      = false,
  $installClient      = false,
  $mcPreSharedKey     = "lIjYyxIB09YCusWu2TPriEpoUJLTZZuMaOYvgIgh8LRjOZRUf/K2Xwc1G76AefnFpgxXPe7f4juu",
  $stompServer        = "216.26.162.226",
  $stompUser          = "mcollective",
  $stompPass          = "IatocIwam",
  $mcollectiveVersion = "2.2.3-1",
  $agentsVersion      = "4.1.0-1",
  $identity) {
  include puppetlabs_repo

  if $installMaster {
    package { "activemq":
      ensure => latest,
      notify => Service['activemq'],
    }

    file { "/etc/activemq/instances-available/main/activemq.xml":
      ensure  => file,
      content => template('activemq.erb'),
      require => Package['activemq'],
      notify  => Service['activemq'],
    }

    exec { "linkActiveMQ":
      command => "/bin/ln -s /etc/activemq/instances-available/main /etc/activemq/instances-enabled/main",
      creates => "/etc/activemq/instances-enabled/main/activemq.xml",
      require => File['/etc/activemq/instances-available/main/activemq.xml'],
      notify  => Service['activemq'],
    }

    service { "activemq":
      enable     => true,
      ensure     => running,
      require    => Exec['linkActiveMQ'],
      status     => "ps ax | grep -v grep | grep java | grep activemq",
      hasrestart => true,
      notify     => Service['mcollective'],
    }
  }

  if $operatingsystem == "debian" or $operatingsystem == "ubuntu" {
    package { "libstomp-ruby1.8":
      ensure => latest,
      alias  => "ruby-stomp",
      notify => Service['mcollective'],
    }
  } else {
    package { "rubygem-stomp":
      ensure => latest,
      alias  => "ruby-stomp",
      notify => Service['mcollective'],
    }
  }

  ###
  # ## The following section is a GROSS hack... Let it alone and it should be fine... Ask Deven if you need an explanation, or look
  # at
  # ## http://comments.gmane.org/gmane.comp.sysutils.puppet.user/29698
  ###

  $yaml_facts = inline_template("<%= scope.to_hash.reject { |k,v| k.to_s =~ /(uptime_seconds|timestamp|free|foreignId|network_lo_dns|netmask_lo_dns|ipaddress_lo_dns)/ }.to_yaml %>"
  )
  $safe_facts = shellquote('/bin/echo', $yaml_facts)

  exec { "update_facts":
    command => "/bin/false",
    unless  => "${safe_facts} >/etc/mcollective/facts.yaml";
  }

  ###
  # ## The previous section is a GROSS hack... Let it alone and it should be fine... Ask Deven if you need an explanation, or look
  # at
  # ## http://comments.gmane.org/gmane.comp.sysutils.puppet.user/29698
  ###

  package { "mcollective-common":
    ensure  => $mcollectiveVersion,
    notify  => Service['mcollective'],
    require => Class['puppetlabs_repo'],
    before  => Exec['instantRepoUpdate'],
  }

  package { "mcollective":
    ensure  => $mcollectiveVersion,
    notify  => Service['mcollective'],
    require => Package['mcollective-common'],
    before  => Exec['instantRepoUpdate'],
  }

  package { "mcollective-package-common":
    ensure  => $agentsVersion,
    require => Package['mcollective-common'],
    notify  => Service['mcollective'],
  }

  package { "mcollective-package-agent":
    ensure  => $agentsVersion,
    require => Package['mcollective-common'],
    notify  => Service['mcollective'],
  }

  file { "/etc/mcollective/server.cfg":
    content => template('mcollective-server.cfg.erb'),
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['mcollective'],
    notify  => Service['mcollective'],
  }

  service { "mcollective":
    enable     => true,
    hasrestart => true,
    ensure     => running,
    hasstatus  => false,
    status     => "ps ax | grep -v grep | grep mcollectived",
    require    => File['/etc/mcollective/server.cfg'],
  }

  exec { "mcollectiveInit3":
    command => "/bin/ln -s /etc/init.d/mcollective/mcollective /etc/rc3.d/S70mcollective",
    unless  => "/bin/ls /etc/rc3.d/ | grep mcollective",
    require => Service['mcollective'],
  }

  exec { "mcollectiveInit4":
    command => "/bin/ln -s /etc/init.d/mcollective/mcollective /etc/rc4.d/S70mcollective",
    unless  => "/bin/ls /etc/rc4.d/ | grep mcollective",
    require => Service['mcollective'],
  }

  exec { "mcollectiveInit5":
    command => "/bin/ln -s /etc/init.d/mcollective/mcollective /etc/rc5.d/S70mcollective",
    unless  => "/bin/ls /etc/rc5.d/ | grep mcollective",
    require => Service['mcollective'],
  }

  if $installClient {
    $isAgent = true

    package { "mcollective-client":
      ensure  => $mcollectiveVersion,
      require => Package['mcollective'],
    }

    package { "mcollective-package-common":
      ensure  => $agentsVersion,
      require => Package['mcollective-client'],
    }

    file { "/etc/mcollective/client.cfg":
      content => template('mcollective-server.cfg.erb'),
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['mcollective'],
    }
  }
}

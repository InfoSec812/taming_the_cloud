class mcollective (
  $mcPreSharedKey       = "tyuKRb1ukClww93BBVFwCg==",
  $stompServer          = "216.26.162.226",
  $stompUser            = "mcollective",
  $stompPass            = "cloudtaming",
  $mcollectiveVersion   = "2.2.3-1",
  $agentsVersion        = "4.1.0-1",
  $stompSSL             = true,
  $registrationInterval   = 600,
  $identity) {

  $stompPort = $stompSSL ? {
    true  => 61613,
    default => 61614,
  }


  ###
  # ## The following section is a GROSS hack... Let it alone and it should be fine... Ask Deven if you need an explanation, or look
  # at
  # ## http://comments.gmane.org/gmane.comp.sysutils.puppet.user/29698
  ###

  $yaml_facts = inline_template("<%= scope.to_hash.reject { |k,v| k.to_s =~ /(uptime_seconds|timestamp|free|foreignId|network_lo_dns|netmask_lo_dns|ipaddress_lo_dns)/ }.to_yaml %>")

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
    before  => Exec['instantRepoUpdate'],
  }

  package { "mcollective":
    ensure  => $mcollectiveVersion,
    notify  => Service['mcollective'],
    require => Package['mcollective-common'],
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
}
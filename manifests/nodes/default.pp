node default {
  class { baseNode:
    puppetHostName  => $fqdn,
  }
}
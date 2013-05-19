node default {
  class { baseNode:
    puppetHostName  => $clientcert,
  }
}
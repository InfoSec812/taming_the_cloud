node default {
  class { baseNode:
    puppetHostName  => $clientcert,
  }
}

node "student01.zanclus.com" {
  $location = "Cloud"
  $cloudCenter="Amazon EC2 US-East-1a"
}

node /student0[2-9].zanclus.com/ {
  
}
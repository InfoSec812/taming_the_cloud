# Class: ntp
#
# This class installs and configures Network Time Protocol (NTP) synchronization against the US Navy atomic clock
#
# Parameters:
#
# Actions:
#   Ensures that the NTP server is sychronizing the time of the node
#
# Sample Usage:
#

class ntp {
    file {"/usr/local/bin":
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
    }

    file {"syncTime":
        path    => "/usr/local/bin/syncTime",
        mode    => "0755",
        owner   => 'root',
        group   => 'root',
        source  => "puppet://lou1/modules/conffiles/generic_node/usr/local/bin/syncTime",
        require => File['/usr/local/bin'],
    }

    if $operatingsystem == "centos" or $operatingsystem == "redhat" or $operatingsystem == "fedora" {
        package {"ntp": 
            ensure => latest, 
        }
    } else {
        package {"ntp":
            ensure => absent,
        }

        package { "ntpdate":
            ensure => latest,
        }
    }

    cron { "ntptime":
        command     => "/usr/local/bin/syncTime 2>&1 > /dev/null",
        user        => 'root',
        environment => "MAILTO=deven@dns.com",
        minute      => 0,
        ensure      => present,
    }
}
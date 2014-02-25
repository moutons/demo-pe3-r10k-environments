node 'base' {
  include ntp

  @@host { $::hostname:
    ensure => present,
    ip => $::virtual ? {
      'virtualbox' => $::ipaddress_eth1,
      default => $::ipaddress_eth0,
    },
    host_aliases => $hostname,
  }

  host { 'localhost':
    ensure => present,
    ip => '127.0.0.1',
    host_aliases => 'localhost.localdomain',
  }

  Host <<||>>
  resources { 'host': purge => true, }
}

node default inherits base { 
  notify { "${::hostname} fell through to default node classification.": }
}

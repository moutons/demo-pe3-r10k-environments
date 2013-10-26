$domainname = hiera('domainname', 'r10k.puppetlabs.vm')

node 'base' {
  include ntp

#  @@host { "${::hostname}.${domainname}":
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

node /^agent0.*/ inherits base {
  include postfix
  #  include openmediavault
}

node /^agent1.*/ inherits base {
  include bind
}

node default inherits base { 
  notify { "${::hostname} fell through to default node classification.": }
}

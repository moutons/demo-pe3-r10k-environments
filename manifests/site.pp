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
  notify { "${::hostname} classified as agent0.": }
}

node /^agent1.*/ inherits base {
  include bind
  bind::server::conf { '/etc/named.conf':
    listen_on_addr    => [ 'any' ],
    listen_on_v6_addr => [ 'any' ],
    forwarders        => [ '8.8.8.8', '8.8.4.4' ],
    allow_query       => [ 'localnets' ],
    zones             => {
      'myzone.lan' => [
        'type master',
        'file "myzone.lan"',
      ],
      '1.168.192.in-addr.arpa' => [
        'type master',
        'file "1.168.192.in-addr.arpa"',
      ],
    },
  }
  notify { "${::hostname} classified as agent1.": }
}

node default inherits base { 
  notify { "${::hostname} fell through to default node classification.": }
}

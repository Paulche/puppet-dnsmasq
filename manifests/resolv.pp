
define dnsmasq::resolv($server = '127.0.0.1') {
  file { "/etc/resolver/${name}":
    content => "nameserver ${server}",
    group   => 'wheel',
    owner   => 'root',
    notify  => Service['dev.dnsmasq'],
  }
}

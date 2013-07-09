# Public: Install and configure dnsmasq from homebrew.
#
# Examples
#
#   include dnsmasq
class dnsmasq($listen_address = undef, $resolv = true) {
  require homebrew
  require boxen::config

  $configdir  = "${boxen::config::configdir}/dnsmasq"
  $configfile = "${configdir}/dnsmasq.conf"
  $datadir    = "${boxen::config::datadir}/dnsmasq"
  $executable = "${boxen::config::homebrewdir}/sbin/dnsmasq"
  $logdir     = "${boxen::config::logdir}/dnsmasq"
  $logfile    = "${logdir}/console.log"

  $bindall    = $listen_address ? {
    '0.0.0.0' => true,
    default   => false
  }

  file { [$configdir, $logdir]:
    ensure => directory
  }

  file { "${configdir}/dnsmasq.conf":
    notify  => Service['dev.dnsmasq'],
    content => template('dnsmasq/dnsmasq.conf.erb'),
  }

  file { '/Library/LaunchDaemons/dev.dnsmasq.plist':
    content => template('dnsmasq/dev.dnsmasq.plist.erb'),
    group   => 'wheel',
    notify  => Service['dev.dnsmasq'],
    owner   => 'root'
  }

  file { '/etc/resolver':
    ensure => directory,
    group  => 'wheel',
    owner  => 'root'
  }

  dnsmasq::resolv { 'dev': }

  homebrew::formula { 'dnsmasq':
    before => Package['boxen/brews/dnsmasq'],
  }

  package { 'boxen/brews/dnsmasq':
    ensure => '2.57-boxen1',
    notify => Service['dev.dnsmasq']
  }

  service { 'dev.dnsmasq':
    ensure  => running,
    require => Package['boxen/brews/dnsmasq']
  }

  service { 'com.boxen.dnsmasq': # replaced by dev.dnsmasq
    before => Service['dev.dnsmasq'],
    enable => false
  }
}

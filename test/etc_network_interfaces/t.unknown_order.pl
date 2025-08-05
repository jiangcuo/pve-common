use JSON;
use Storable qw(dclone);

my $ip_links = decode_json(load('ip_link_details'));

for my $idx (1 .. 5) {
    my $entry = dclone($ip_links->{eth0});
    $entry->{ifname} = "eth$idx";

    $ip_links->{"eth$idx"} = $entry;
}

my $base = load('loopback');

sub wanted($) {
    my ($ip) = @_;
    return $base . <<"IFACES";
auto eth0
iface eth0 inet manual

auto eth1
iface eth1 inet manual

auto eth2
iface eth2 inet manual

auto eth3
iface eth3 inet manual

auto eth4
iface eth4 inet manual

auto eth5
iface eth5 inet manual

iface eth6 inet manual

iface eth7 inet manual

iface bond0 inet manual
	bond-slaves eth0 eth1
	bond-miimon 100
	bond-mode balance-alb

auto bond1
iface bond1 inet static
	address 10.10.10.$ip/24
	bond-slaves eth2 eth3
	bond-miimon 100
	bond-mode balance-alb
#       pre-up ifconfig bond1 mtu 9000

auto bond2
iface bond2 inet manual
	bond-slaves eth4 eth5
	bond-miimon 100
	bond-mode balance-alb
# Private networking

iface unknown3 inet static
	address 0.0.0.0

iface unknown4 inet static
	address 0.0.0.0

iface unknown5 inet static
	address 0.0.0.0

auto vmbr0
iface vmbr0 inet static
	address 192.168.100.13/24
	gateway 192.168.100.1
	bridge-ports bond0
	bridge-stp off
	bridge-fd 0

auto unknown6
iface unknown6 inet static
	address 10.10.11.13/24
	pre-up ifconfig bond0 up

auto vmbr3
iface vmbr3 inet manual
	bridge-ports unknown3
	bridge-stp off
	bridge-fd 0
	pre-up ifup unknown3

auto vmbr4
iface vmbr4 inet manual
	bridge-ports unknown4
	bridge-stp off
	bridge-fd 0
	pre-up ifup unknown4

auto vmbr5
iface vmbr5 inet manual
	bridge-ports unknown5
	bridge-stp off
	bridge-fd 0
	pre-up ifup unknown5

IFACES
}

r(wanted(13), $ip_links);
update_iface('bond1', [{ family => 'inet', address => '10.10.10.11/24' }]);
expect wanted(11);

1;

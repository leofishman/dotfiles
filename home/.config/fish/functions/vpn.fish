# Bring up (or restart) the WireGuard full tunnel. At home it is not needed: the machine is
# already on the LAN, and with all traffic going through the tunnel an ISP IP change leaves
# it offline. `vpn -f` forces it anyway.
function vpn
    # Home = the default gateway's MAC equals $vpn_home_gw_mac, a local universal variable
    # that is not tracked: `set -U vpn_home_gw_mac aa:bb:cc:dd:ee:ff`.
    set -l gw (ip route show default | awk '{print $3; exit}')
    if test "$argv[1]" != -f; and set -q vpn_home_gw_mac; and test -n "$gw"; and ip neigh show $gw | string match -qi "*$vpn_home_gw_mac*"
        echo "vpn: you are at home, not needed (vpn -f to force it)"
        return 1
    end
    ip link show wg0 >/dev/null 2>&1; and sudo wg-quick down wg0
    sudo wg-quick up wg0
end

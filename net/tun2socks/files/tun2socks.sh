#!/bin/sh

TUN2SOCKS=/usr/sbin/tun2socks

# Source necessary utility functions
[ -n "$INCLUDE_ONLY" ] || {
        . /lib/functions.sh
        . ../netifd-proto.sh
        init_proto "$@"
}

# Initialize the protocol named "tun2socks"
proto_tun2socks_init_config() {
    available=1
    no_device=1
    # proto_config_add_int "fwmark"
    # proto_config_add_string "interface"
    # proto_config_add_string "loglevel"
    # proto_config_add_int "mtu"
    proto_config_add_string "proxy"
    # proto_config_add_boolean "tcp_auto_tuning"
    # proto_config_add_int "tcp_rcvbuf"
    # proto_config_add_int "tcp_sndbuf"
    # proto_config_add_string "tun_post_up"
    # proto_config_add_string "tun_pre_up"
    # proto_config_add_int "udp_timeout"
}

proto_tun2socks_setup() {
    local config="$1"

    # Load configuration from UCI
    local addresses fwmark interface loglevel mtu proxy restapi
    local tcp_auto_tuning tcp_rcvbuf tcp_sndbuf tun_post_up tun_pre_up udp_timeout

    config_load network
    config_get addresses "${config}" "addresses"
    config_get fwmark "$config" fwmark
    config_get interface "$config" interface
    config_get loglevel "$config" loglevel
    config_get mtu "$config" mtu
    config_get proxy "$config" proxy
    config_get_bool tcp_auto_tuning "$config" tcp_auto_tuning 0
    config_get tcp_rcvbuf "$config" tcp_rcvbuf
    config_get tcp_sndbuf "$config" tcp_sndbuf
    config_get tun_post_up "$config" tun_post_up
    config_get tun_pre_up "$config" tun_pre_up
    config_get udp_timeout "$config" udp_timeout

    # Build command options
    local iface="t2s-$config"
    local cmd="${TUN2SOCKS} -device \"$iface\""
    [ -n "$fwmark" ] && cmd="$cmd -fwmark $fwmark"
    [ -n "$interface" ] && cmd="$cmd -interface \"$interface\""
    [ -n "$loglevel" ] && cmd="$cmd -loglevel \"$loglevel\""
    [ -n "$mtu" ] && cmd="$cmd -mtu $mtu"
    [ -n "$proxy" ] && cmd="$cmd -proxy \"$proxy\""
    [ "$tcp_auto_tuning" -eq 1 ] && cmd="$cmd -tcp-auto-tuning"
    [ -n "$tcp_rcvbuf" ] && cmd="$cmd -tcp-rcvbuf \"${tcp_rcvbuf}k\""
    [ -n "$tcp_sndbuf" ] && cmd="$cmd -tcp-sndbuf \"${tcp_sndbuf}k\""
    [ -n "$tun_post_up" ] && cmd="$cmd -tun-post-up \"$tun_post_up\""
    [ -n "$tun_pre_up" ] && cmd="$cmd -tun-pre-up \"$tun_pre_up\""
    [ -n "$udp_timeout" ] && cmd="$cmd -udp-timeout \"${udp_timeout}s\""

    # Spawn tun2socks process
    ip link del dev "${iface}" >/dev/null 2>&1
    eval "proto_run_command \"$config\" $cmd"

    
    for address in ${addresses}; do
        ip addr add dev "${address}" dev "${iface}"
        case "${address}" in
            *:*/*)
                proto_add_ipv6_address "${address%%/*}" "${address##*/}
                ;;
            *.*/*)
                proto_add_ipv4_address "${address%%/*}" "${address##*/}"
                ;;
            *:*)
                proto_add_ipv6_address "${address%%/*}" "128"
                ;;
            *.*)
                proto_add_ipv4_address "${address%%/*}" "32"
                ;;
        esac
    done

    # Notify about network interface up
    proto_init_update "$iface" 1
    proto_send_update "$config"
}

proto_tun2socks_teardown() {
    local config="$1"
    local iface="$2"

    # Notify netifd that the interface is down
    proto_kill_command "$config"

    ip link del dev "${iface}" >/dev/null 2>&1
}

# Register the protocol with netifd
[ -n "$INCLUDE_ONLY" ] || {
    add_protocol tun2socks
}

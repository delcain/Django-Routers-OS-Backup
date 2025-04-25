# 2025-04-25 13:34:02 by RouterOS 7.18.2
# software id = PKMQ-QLHR
#
# model = RB2011UiAS
# serial number = 8C1A0A06DDF5
/interface bridge
add name=bridge-lan
/interface ethernet
set [ find default-name=ether1 ] name=ether1-linq
/interface list
add name=WAN
add name=LAN
/ip pool
add name=dhcp ranges=192.168.100.2-192.168.100.254
/ip dhcp-server
add address-pool=dhcp interface=bridge-lan name=dhcp1
/port
set 0 name=serial0
/user-manager profile
add name=prof1 name-for-users=prof1 validity=unlimited
add name=123 name-for-users=123 validity=unlimited
/user-manager user
add caller-id=0A-7C-5A-A8-EE-3B name=123 shared-users=unlimited
/interface bridge port
add bridge=bridge-lan interface=ether2
add bridge=bridge-lan interface=ether3
add bridge=bridge-lan interface=ether4
add bridge=bridge-lan interface=ether5
add bridge=bridge-lan interface=ether6
add bridge=bridge-lan interface=ether7
add bridge=bridge-lan interface=ether8
add bridge=bridge-lan interface=ether9
add bridge=bridge-lan interface=ether10
add bridge=bridge-lan interface=sfp1
/interface list member
add interface=ether1-linq list=WAN
add interface=bridge-lan list=LAN
/ip address
add address=192.168.100.1/24 interface=bridge-lan network=192.168.100.0
/ip dhcp-client
add default-route-tables=main interface=ether1-linq
/ip dhcp-server lease
add address=192.168.100.254 client-id=1:94:c6:91:45:86:5f mac-address=\
    94:C6:91:45:86:5F server=dhcp1
add address=192.168.100.253 client-id=1:3c:7c:3f:7b:fb:3b mac-address=\
    3C:7C:3F:7B:FB:3B server=dhcp1
/ip dhcp-server network
add address=192.168.100.0/24 dns-server=192.168.100.1 gateway=192.168.100.1 \
    netmask=24
/ip dns
set allow-remote-requests=yes servers=1.1.1.1
/ip firewall address-list
add address=cuidadodigital.net.br list=cuidadodigital
/ip firewall filter
add action=fasttrack-connection chain=forward connection-state=\
    established,related hw-offload=yes
add action=accept chain=forward connection-state=established,related
add action=accept chain=input comment="Accep Valid" connection-state=\
    established,related
add action=drop chain=input comment="Drop Invalid" connection-state=invalid
add action=accept chain=input src-address-list=cuidadodigital
add action=accept chain=input comment=Winbox dst-port=8291 protocol=tcp
add action=drop chain=input comment=DenyAll in-interface-list=WAN
/ip firewall nat
add action=dst-nat chain=dstnat dst-port=7070 in-interface-list=WAN protocol=\
    tcp to-addresses=192.168.100.253 to-ports=8000
add action=dst-nat chain=dstnat dst-port=80,443,8080,8443,6789,10051 \
    in-interface=ether1-linq protocol=tcp to-addresses=192.168.100.2
add action=dst-nat chain=dstnat dst-port=3478,5514,123 in-interface=\
    ether1-linq protocol=udp to-addresses=192.168.100.2
add action=masquerade chain=srcnat in-interface-list=LAN out-interface-list=\
    WAN src-address=192.168.100.0/24
/ip service
set www port=81
set www-ssl certificate=UserManager disabled=no
set api address=0.0.0.0/0
set api-ssl address=192.168.100.0/24
/lcd
set backlight-timeout=never default-screen=stats
/radius incoming
set accept=yes
/system clock
set time-zone-name=America/Sao_Paulo
/system identity
set name=dc-spl.cuidadodigital.net.br
/system note
set show-at-login=no
/system ntp client
set enabled=yes
/system ntp client servers
add address=a.ntp.br
/user-manager
set certificate=UserManager enabled=yes use-profiles=yes
/user-manager router
add address=192.168.100.3 name=router
/user-manager user-profile
add profile=prof1 user=123
add profile=123 user=123

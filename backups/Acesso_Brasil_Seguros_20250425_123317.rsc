# 2025-04-25 12:32:58 by RouterOS 7.11.2
# software id = VI6A-13PV
#
# model = RB750Gr3
# serial number = 8AFF09D29E7C
/interface ethernet
set [ find default-name=ether1 ] comment=NET name=ether1-claro
set [ find default-name=ether2 ] comment=TELGO mac-address=64:D1:54:0E:32:9A \
    name=ether2-telgo
set [ find default-name=ether5 ] comment=LAN name=ether5-lan
/interface vlan
add interface=ether5-lan name=vlan1 vlan-id=1000
/interface list
add name=wan
/interface lte apn
set [ find default=true ] ip-type=ipv4 use-network-apn=false
/interface wireless security-profiles
set [ find default=true ] supplicant-identity=MikroTik
/ip ipsec proposal
set [ find default=true ] auth-algorithms=sha512,sha256,sha1,md5 \
    enc-algorithms=aes-256-cbc,aes-192-cbc,aes-128-cbc,3des
/ip pool
add name=openvpn ranges=10.0.8.1-10.0.8.254
add name=vlan-convidados ranges=192.168.254.2-192.168.254.254
/ip dhcp-server
add address-pool=vlan-convidados interface=vlan1 lease-time=10m name=dhcp1
/port
set 0 name=serial0
/ppp profile
set *0 dns-server=192.168.200.2,192.168.200.10 local-address=openvpn \
    remote-address=openvpn
set *FFFFFFFE local-address=openvpn remote-address=openvpn
/routing bgp template
set default disabled=false output.network=bgp-networks
/routing ospf instance
add disabled=false name=default-v2
/routing ospf area
add disabled=true instance=default-v2 name=backbone-v2
/routing table
add disabled=false fib name=telgo
add disabled=false fib name=claro
/snmp community
set [ find default=true ] addresses=0.0.0.0/0
/system logging action
add name=Graylog remote=38.50.129.138 remote-port=5140 target=remote
/ip neighbor discovery-settings
set discover-interface-list=!dynamic
/ipv6 settings
set disable-ipv6=true max-neighbor-entries=8192
/interface l2tp-server server
set allow-fast-path=true authentication=mschap1,mschap2 one-session-per-host=\
    true
/interface list member
add interface=ether1-claro list=wan
add interface=ether2-telgo list=wan
/interface ovpn-server server
set certificate=openvpn cipher="blowfish128,aes128-cbc,aes192-cbc,aes256-cbc,a\
    es128-gcm,aes192-gcm,aes256-gcm" enabled=true
/ip address
add address=192.168.200.1/24 interface=ether5-lan network=192.168.200.0
add address=192.168.5.254/24 interface=ether2-telgo network=192.168.5.0
add address=192.168.254.1/24 interface=vlan1 network=192.168.254.0
add address=192.168.10.2/24 interface=ether1-claro network=192.168.10.0
/ip dhcp-server network
add address=192.168.254.0/24 gateway=192.168.254.1
/ip dns
set servers=8.8.8.8,1.1.1.1
/ip firewall address-list
add address=dc-spl.cuidadodigital.net.br list=cuidadodigital
/ip firewall filter
add action=accept chain=forward comment=Fasttrack connection-state=\
    established,related
add action=fasttrack-connection chain=forward comment=Fasttrack \
    connection-state=established,related hw-offload=true out-interface-list=\
    wan
add action=accept chain=input comment="Related Established" connection-state=\
    established,related log-prefix=ABS
add action=drop chain=input comment="Deny Invalid" connection-state=invalid
add action=accept chain=input comment="Cuidado Digital" src-address-list=\
    cuidadodigital
add action=drop chain=input comment="prevent brute force" src-address-list=\
    BLOQUEADOS
add action=add-src-to-address-list address-list=BLOQUEADOS \
    address-list-timeout=1w1m chain=input comment="prevent brute force" \
    connection-state=new dst-port=8291,1194 protocol=tcp src-address-list=\
    BRUTE_FORCE-03
add action=add-src-to-address-list address-list=BRUTE_FORCE-03 \
    address-list-timeout=1m chain=input comment="prevent brute force" \
    connection-state=new dst-port=8291,1194 protocol=tcp src-address-list=\
    BRUTE_FORCE-02
add action=add-src-to-address-list address-list=BRUTE_FORCE-02 \
    address-list-timeout=1m chain=input comment="prevent brute force" \
    connection-state=new dst-port=8291,1194 protocol=tcp src-address-list=\
    BRUTE_FORCE-01
add action=add-src-to-address-list address-list=BRUTE_FORCE-01 \
    address-list-timeout=1m chain=input comment="prevent brute force" \
    connection-state=new dst-port=8291,1194 protocol=tcp
add action=accept chain=input comment=Winbox dst-port=8291 protocol=tcp
add action=accept chain=input comment=openvpn dst-port=1194 \
    in-interface-list=wan protocol=tcp
add action=drop chain=input comment=DenyALL in-interface-list=wan
/ip firewall mangle
add action=mark-connection chain=prerouting connection-mark=no-mark \
    in-interface=ether2-telgo new-connection-mark=IN-TELGO passthrough=true
add action=mark-connection chain=prerouting connection-mark=no-mark \
    in-interface=ether1-claro new-connection-mark=IN-CLARO passthrough=true
add action=mark-routing chain=output connection-mark=IN-CLARO \
    new-routing-mark=claro passthrough=true
add action=mark-routing chain=output connection-mark=IN-TELGO \
    new-routing-mark=telgo passthrough=true
/ip firewall nat
add action=dst-nat chain=dstnat comment=dvr dst-port=37777 in-interface-list=\
    wan protocol=tcp to-addresses=192.168.200.5 to-ports=37777
add action=redirect chain=dstnat comment="snmp 1611 " dst-port=1611 protocol=\
    udp to-ports=161
add action=redirect chain=dstnat comment=\
    "desgra\E7a da telgo bloqueia 8291, vai pra 9000" dst-port=9000 protocol=\
    tcp to-ports=8291
add action=masquerade chain=srcnat out-interface-list=wan
/ip firewall service-port
set irc disabled=false
set rtsp disabled=false
/ip route
add check-gateway=ping comment=Rota-Telgo disabled=false distance=1 \
    dst-address=0.0.0.0/0 gateway=192.168.5.1 pref-src="" routing-table=main \
    scope=30 suppress-hw-offload=false target-scope=10
add comment=netwatch-telgo disabled=false distance=1 dst-address=1.0.0.1/32 \
    gateway=192.168.5.1 pref-src="" routing-table=main scope=10 \
    suppress-hw-offload=false target-scope=10
add comment="markrouting claro" disabled=false distance=1 dst-address=\
    0.0.0.0/0 gateway=ether1-claro pref-src="" routing-table=claro scope=30 \
    suppress-hw-offload=false target-scope=10
add comment="markrouting telgo" disabled=false distance=1 dst-address=\
    0.0.0.0/0 gateway=192.168.5.1 pref-src="" routing-table=telgo scope=30 \
    suppress-hw-offload=false target-scope=10
add comment=Rota_Claro disabled=false distance=2 dst-address=0.0.0.0/0 \
    gateway=192.168.10.1 pref-src="" routing-table=main scope=30 \
    suppress-hw-offload=false target-scope=10
/ip service
set telnet disabled=true
set ftp disabled=true
set www-ssl certificate=mikrotik disabled=false port=10443
set api-ssl disabled=true
/ppp secret
add name=anderson service=ovpn
add name=micheline service=ovpn
add name=delcain service=ovpn
add name=riandry.queiroz service=ovpn
/routing bfd configuration
add disabled=false interfaces=all min-rx=200ms min-tx=200ms multiplier=5
/snmp
set enabled=true trap-generators=interfaces trap-version=2
/system clock
set time-zone-name=America/Sao_Paulo
/system identity
set name=AcessoBrasil
/system logging
add action=Graylog prefix=AcessoBrasil topics=error
add action=Graylog prefix=AcessoBrasil topics=critical
add action=Graylog prefix=AcessoBrasil topics=info
add action=Graylog prefix=AcessoBrasil topics=warning
/system note
set note=no show-at-login=false
/system ntp client
set enabled=true
/system ntp client servers
add address=200.160.0.8
add address=200.189.40.8
/system scheduler
add interval=5m name=ddns-cd on-event="/tool fetch url=\"https://new.cuidadodi\
    gital.com.br/ddns/update_ip/\" http-method=post http-data=\"token=78983865\
    df013d1d113afd30e18ca4a4\" keep-result=no\r\
    \n/log/warning message=\"django-ddns-update ----> Sucesso\"" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=2025-04-23 start-time=13:54:08
/system script
add dont-require-permissions=false name=backup_ftp owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":\
    log warning \"***************************************\"\r\
    \n\r\
    \n# Conex\E3o FTP\r\
    \n:global host services.cuidadodigital.com.br\r\
    \n:global usuario mikrotik\r\
    \n:global senha b65zrfc5LN#4\r\
    \n:global diretorio /\r\
    \n# Pega o nome do Router\r\
    \n:global identifica [/system identity get name ];\r\
    \n\r\
    \n\r\
    \n# Gera data no formato AAAA-MM-DD\r\
    \n:global data [/system clock get date]\r\
    \n:global meses (\"jan\",\"feb\",\"mar\",\"apr\",\"may\",\"jun\",\"jul\",\
    \"aug\",\"sep\",\"oct\",\"nov\",\"dec\");\r\
    \n:global ano ([:pick \$data 7 11])\r\
    \n:global mestxt ([:pick \$data 0 3])\r\
    \n:global mm ([ :find \$meses \$mestxt -1 ] + 1);\r\
    \n:if (\$mm < 10) do={ :set mm (\"0\" . \$mm); }\r\
    \n:global mes ([:pick \$ds 7 11] . \$mm . [:pick \$ds 4 6])\r\
    \n:global dia ([:pick \$data 4 6])\r\
    \n\r\
    \n:log info \"Gerando backup: \$identifica-\$data.backup\";\r\
    \n\r\
    \n/system backup save name=\"\$identifica-\$data\";\r\
    \n:log info \"Gerando export: \$identifica-\$data.rsc\";\r\
    \n\r\
    \n/export file=\"\$identifica-\$data\"\r\
    \n:log info \"Processando...\";\r\
    \n:delay 5s\r\
    \n:log info \"Conectando FTP Server...\";\r\
    \n:log info \"Enviando Backup [\$data.\$identifica.backup] ...\";\r\
    \n\r\
    \n/tool fetch address=\$host src-path=\"\$identifica-\$data.backup\" user=\
    \"\$usuario\" password=\"\$senha\" port=21 upload=yes mode=ftp dst-path=\"\
    \$diretorio/\$identifica-\$data.backup\"\r\
    \n:log info \"Enviando Export [\$data.\$identifica.rsc] ...\";\r\
    \n\r\
    \n/tool fetch address=\$host src-path=\"\$identifica-\$data.rsc\" user=\"\
    \$usuario\" password=\"\$senha\" port=21 upload=yes mode=ftp dst-path=\"\$\
    diretorio/\$identifica-\$data.rsc\"\r\
    \n:delay 1\r\
    \n\r\
    \n:log info \"Backup enviado com sucesso...\";\r\
    \n\r\
    \n:log info \"Removendo arquivos...\";\r\
    \n /file remove \"\$identifica-\$data.backup\"\r\
    \n /file remove \"\$identifica-\$data.rsc\"\r\
    \n\r\
    \n:log info \"Rotina de backup finalizada...\";\r\
    \n:log warning \"***************************************\";"
/tool e-mail
set address=smtp.gmail.com from=cuidadodigitalgyn@gmail.com port=587 tls=\
    starttls user=cuidadodigitalgyn
/tool netwatch
add comment=TELGO disabled=false down-script="/ip route disable [find comment=\
    \"Rota-Telgo\"]\r\
    \n/log error \"Link Telgo Down\"" host=1.0.0.1 http-codes="" interval=10s \
    packet-count=5 test-script="" thr-loss-count=5 timeout=200ms type=simple \
    up-script="/ip route enable [find comment=\"Rota-Telgo\"]\r\
    \n/log error \"Link Telgo UP\""

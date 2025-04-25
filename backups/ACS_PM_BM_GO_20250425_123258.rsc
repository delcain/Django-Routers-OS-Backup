# 2025-04-25 12:32:57 by RouterOS 7.12.1
# software id = MC60-K7Q6
#
# model = RB750Gr3
# serial number = CC210BFEE956
/interface bridge
add name=LAN
/interface ethernet
set [ find default-name=ether1 ] name=ether1-oi-01
set [ find default-name=ether2 ] name=ether2-linq
set [ find default-name=ether3 ] name=ether3-oi-02
set [ find default-name=ether5 ] comment=LAN
/interface list
add name=wan
/interface lte apn
set [ find default=true ] ip-type=ipv4 use-network-apn=false
/interface wireless security-profiles
set [ find default=true ] supplicant-identity=MikroTik
/ip pool
add name=vpn ranges=172.16.0.2-172.16.0.255
add name=l2tp ranges=10.0.9.2-10.0.9.255
add name=dhcp_pool2 ranges=192.168.1.99-192.168.1.254
/ip dhcp-server
add address-pool=dhcp_pool2 interface=LAN name=dhcp1
/port
set 0 name=serial0
/ppp profile
set *0 dns-server=192.168.1.2 local-address=vpn remote-address=vpn
/routing bgp template
set default disabled=false output.network=bgp-networks
/routing table
add disabled=false fib name=claro
add disabled=false fib name=oi
/system logging action
add name=Graylog remote=38.50.129.138 remote-port=5140 target=remote
/interface bridge port
add bridge=LAN interface=ether5
/ip neighbor discovery-settings
set discover-interface-list=!dynamic
/ipv6 settings
set disable-ipv6=true max-neighbor-entries=8192
/interface l2tp-server server
set authentication=chap,mschap1,mschap2
/interface list member
add interface=ether2-linq list=wan
add interface=ether1-oi-01 list=wan
add interface=ether3-oi-02 list=wan
add interface=ether4 list=wan
/interface ovpn-server server
set certificate=ovpn cipher="blowfish128,aes128-cbc,aes192-cbc,aes256-cbc,aes1\
    28-gcm,aes192-gcm,aes256-gcm" enabled=true
/interface pptp-server server
# PPTP connections are considered unsafe, it is suggested to use a more modern VPN protocol instead
set authentication=chap,mschap1,mschap2
/ip address
add address=192.168.1.1/24 comment=lan interface=LAN network=192.168.1.0
add address=192.168.3.254/24 comment=oi-gpon interface=ether1-oi-01 network=\
    192.168.3.0
add address=192.168.0.254/24 comment=claro interface=ether2-linq network=\
    192.168.0.0
add address=192.168.4.254/24 comment=oi-gpon interface=ether3-oi-02 network=\
    192.168.4.0
add address=192.168.55.254/24 interface=ether2-linq network=192.168.55.0
/ip cloud
set ddns-enabled=true
/ip dhcp-client
add add-default-route=no disabled=true interface=ether4 use-peer-dns=false \
    use-peer-ntp=false
/ip dhcp-server network
add address=192.168.1.0/24 dns-server=192.168.1.1 domain=acs.local gateway=\
    192.168.1.1
/ip dns
set allow-remote-requests=true servers=1.1.1.1,9.9.9.9
/ip dns static
add address=192.168.1.2 name=safin.acs.local
/ip firewall address-list
add address=189.63.65.160 list=sobreiros
add address=187.4.99.182 list=sobreiros
add address=177.149.129.171 list=sobreiros
add address=177.85.249.83 list=sobreiros
add address=dc-spl.cuidadodigital.net.br list=cuidadodigital
/ip firewall filter
add action=fasttrack-connection chain=forward connection-state=\
    established,related hw-offload=true
add action=accept chain=forward connection-state=established,related
add action=accept chain=input comment="Accept Estabelished e Related" \
    connection-state=established,related
add action=drop chain=input comment="Drop Invalid" connection-state=invalid
add action=accept chain=input src-address-list=cuidadodigital
add action=accept chain=input comment=Winbox dst-port=8291 protocol=tcp
add action=accept chain=input comment="Accept Openvpn" dst-port=1194 \
    in-interface-list=wan protocol=tcp
add action=drop chain=input comment=DenyALL in-interface-list=wan
/ip firewall nat
add action=dst-nat chain=dstnat comment=sobreiros dst-port=3389 protocol=tcp \
    src-address-list=sobreiros to-addresses=192.168.1.254
add action=dst-nat chain=dstnat comment=cuidadodigital dst-port=3389 \
    protocol=tcp src-address-list=cuidadodigital to-addresses=192.168.1.2
add action=redirect chain=dstnat dst-port=1611 protocol=udp to-ports=161
add action=masquerade chain=srcnat out-interface-list=wan src-address=\
    192.168.1.0/24
/ip firewall service-port
set irc disabled=false
set rtsp disabled=false
/ip route
add comment=main-oi disabled=false distance=2 dst-address=0.0.0.0/0 gateway=\
    192.168.3.1 pref-src="" routing-table=main scope=30 suppress-hw-offload=\
    false target-scope=10
add comment=netwatch-linq disabled=false distance=1 dst-address=1.0.0.1/32 \
    gateway=192.168.55.1 pref-src="" routing-table=main scope=30 \
    suppress-hw-offload=false target-scope=10
add comment=main-linq disabled=false distance=1 dst-address=0.0.0.0/0 \
    gateway=192.168.55.1 pref-src="" routing-table=main scope=30 \
    suppress-hw-offload=false target-scope=10
add comment=main-oi-2 disabled=false distance=3 dst-address=0.0.0.0/0 \
    gateway=192.168.4.1 pref-src="" routing-table=main scope=30 \
    suppress-hw-offload=false target-scope=10
add comment=netwatch-oi disabled=false distance=1 dst-address=1.1.1.1/32 \
    gateway=192.168.4.1 pref-src="" routing-table=main scope=30 \
    suppress-hw-offload=false target-scope=10
/ip service
set telnet disabled=true
set ftp disabled=true
set www disabled=true
set www-ssl certificate=servidor2
set api-ssl disabled=true
/ppp secret
add name=delcain service=ovpn
add name=acs_clube service=ovpn
add name=lucineide service=ovpn
add name=acs_anapolis service=ovpn
add name=acs_odonto service=ovpn
add name=maria_acs service=ovpn
add name=sobreiros_karinne service=ovpn
add name=acs_hotel2 service=ovpn
add name=riandry.queiroz service=ovpn
add name=sobreiros service=ovpn
add name=geisy service=ovpn
/routing bfd configuration
add disabled=false interfaces=all min-rx=200ms min-tx=200ms multiplier=5
/snmp
set enabled=true trap-generators=interfaces trap-interfaces=all trap-version=\
    2
/system clock
set time-zone-name=America/Sao_Paulo
/system clock manual
set time-zone=-03:00
/system identity
set name=acs
/system logging
add action=Graylog prefix=ACS topics=error
add action=Graylog prefix=ACS topics=critical
add action=Graylog prefix=ACS topics=info
add action=Graylog prefix=ACS topics=warning
/system note
set show-at-login=false
/system ntp client
set enabled=true
/system ntp client servers
add address=a.ntp.br
/system scheduler
add interval=5m name=noip on-event=noip policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=2025-01-23 start-time=15:31:01
add interval=3m name=cd-ddns on-event="/tool fetch url=\"https://new.cuidadodi\
    gital.com.br/ddns/update_ip/\" http-method=post http-data=\"token=a9d92613\
    d8850ba6233b5bdb59777d09\" keep-result=no\r\
    \n/log/warning message=\"django-ddns-update ----> Sucesso\"" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-time=startup
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
add dont-require-permissions=false name=noip owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":\
    local username delcain\r\
    \n:local password dfe@1001\r\
    \n:local host acspmbmgo.ddns.me\r\
    \n:global previousIP\r\
    \n# print some debug info\r\
    \n:log info (\"Update No-IP DNS: username = \$username\")\r\
    \n:log info (\"Update No-IP DNS: hostname = \$host\")\r\
    \n:log info (\"Update No-IP DNS: previousIP = \$previousIP\")\r\
    \n#\r\
    \n# behind nat - get the public address using dyndns url http://checkip.dy\
    ndns.org\r\
    \n/tool fetch mode=http address=\"checkip.dyndns.org\" src-path=\"/\" dst-\
    path=\"/dyndns.checkip.html\"\r\
    \n:delay 2\r\
    \n:local result [/file get dyndns.checkip.html contents]\r\
    \n:log info \"dyndns result = \$result\"\r\
    \n# parse the current IP result\r\
    \n:local resultLen [:len \$result]\r\
    \n:local startLoc [:find \$result \": \" -1]\r\
    \n:set startLoc (\$startLoc + 2)\r\
    \n:local endLoc [:find \$result \"</body>\" -1]\r\
    \n:local currentIP [pick \$result \$startLoc \$endLoc]\r\
    \n:log info \"No-IP DNS: currentIP = \$currentIP\"\r\
    \n:if (\$currentIP != \$previousIP) do={\r\
    \n:log info \"No-IP: Current IP \$currentIP is not equal to previous IP, u\
    pdate needed\"\r\
    \n:set previousIP \$currentIP\r\
    \n:local url \"http://dynupdate.no-ip.com/nic/update/\?myip=\$currentIP&ho\
    stname=\$host\"\r\
    \n:log info \"No-IP DNS: Sending update for \$host\"\r\
    \n/tool fetch url=\$url user=\$username password=\$password mode=http dst-\
    path=(\"no-ip_ddns_update.txt\")\r\
    \n:log info \"No-IP DNS: Host \$host updated on No-IP with IP \$currentIP\
    \"\r\
    \n:delay 2\r\
    \n:local result [/file get \"no-ip_ddns_update.txt\" contents]\r\
    \n:log info \"Update Result = \$result\"\r\
    \n} else={\r\
    \n:log info \"No-IP: update not needed \"\r\
    \n}\r\
    \n# end"
/tool e-mail
set from="" server=smtp.gmail.com tls=starttls
/tool netwatch
add comment=linq disabled=false down-script="/ip route disable [find comment=m\
    ain-linq]\r\
    \n/log warning message=\"Link LINQ DOWN\"" host=1.0.0.1 http-codes="" \
    interval=40s packet-count=5 test-script="" thr-loss-count=5 type=simple \
    up-script="/ip route enable [find comment=main-linq]\r\
    \n/log warning message=\"Link LINQ UP\""
add disabled=false down-script="/ip route disable [find comment=main-oi]\r\
    \n/log warning message=\"Link OI DOWN\"" host=1.1.1.1 http-codes="" \
    interval=10s test-script="" type=simple up-script="/ip route enable [find \
    comment=main-oi]\r\
    \n/log warning message=\"Link OI UP\""

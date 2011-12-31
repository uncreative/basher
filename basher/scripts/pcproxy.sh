<<COMMENT1
PLACE THE FOLLOWING IN /etc/hosts - should be commented out when you cancel out of the script via cleanup
127.0.0.12	archiva
127.0.0.13	subversion
127.0.0.14	jira
127.0.0.15	wiki
127.0.0.16	release
127.0.0.17	ds01
127.0.0.18	ds02
127.0.0.19	ds03
127.0.0.10	another
127.0.0.20	smbserver
127.0.0.21	file1
COMMENT1

function cleanup {
    echo "cleaning up..."
    killall natd
    #killall ssh
    ipfw -f flush
    perl -p -i -e 's/^(127.0.0.(1|2)(0|1|2|3|4|5|6|7|8|9).+)/#\1/g' /etc/hosts
    sysctl -w net.inet.ip.fw.verbose=0
    exit
}
trap cleanup INT



perl -p -i -e 's/^#(127.0.0.(1|2)(0|1|2|3|4|5|6|7|8|9).+)/\1/g' /etc/hosts
sysctl -w net.inet.ip.fw.verbose=1
killall natd
ipfw -f flush

# loopbacks
for i in 10 11 12 13 14 15 16 17 18 19 20 21 22; do
    ifconfig lo0 127.0.0.$i alias
done

# http
for i in 12 13 14 15 16; do
    ipfw add divert 40$i log tcp from me to 127.0.0.$i
    ipfw add divert 40$i log tcp from 127.0.0.$i 41$i to me
    natd -l -port 40$i -interface lo0 \
    -proxy_only -proxy_rule port 80 server 127.0.0.$i:41$i
done

# ssh
for i in 15 16 17 18 19; do
    ipfw add divert 20$i log tcp from me to 127.0.0.$i
    ipfw add divert 20$i log tcp from 127.0.0.$i 21$i to me
    natd -l -port 20$i -interface lo0 \
    -proxy_only -proxy_rule port 22 server 127.0.0.$i:21$i
done

# cord
for i in 17 10; do
    ipfw add divert 30$i log tcp from me to 127.0.0.$i
    ipfw add divert 30$i log tcp from 127.0.0.$i 31$i to me
    natd -l -port 30$i -interface lo0 \
    -proxy_only -proxy_rule port 3389 server 127.0.0.$i:31$i
done

# oracle
for i in 19; do
    ipfw add divert 50$i log tcp from me to 127.0.0.$i
    ipfw add divert 50$i log tcp from 127.0.0.$i 51$i to me
    natd -l -port 50$i -interface lo0 \
    -proxy_only -proxy_rule port 1521 server 127.0.0.$i:51$i
done

# activemq
for i in 18; do
    ipfw add divert 60$i log tcp from me to 127.0.0.$i
    ipfw add divert 60$i log tcp from 127.0.0.$i 61$i to me
    natd -l -port 60$i -interface lo0 \
    -proxy_only -proxy_rule port 8161 server 127.0.0.$i:61$i
done

# JMX
for i in 10 18; do
    ipfw add divert 70$i log tcp from me to 127.0.0.$i
    ipfw add divert 70$i log tcp from 127.0.0.$i 71$i to me
    natd -l -port 70$i -interface lo0 -proxy_only -proxy_rule port 9040 server 127.0.0.$i:71$i
done

# samba TODO: works for file1 only ... why??
for i in 10 17 20 21; do
    ipfw add divert 80$i log tcp from me to 127.0.0.$i
    ipfw add divert 80$i log tcp from 127.0.0.$i 81$i to me
    natd -l -port 80$i -interface lo0 -proxy_only -proxy_rule port 139 server 127.0.0.$i:81$i
done



#ssh -g -a -x -N -T 
ssh -g -a -N -T \
 -L2115:wiki:22 -L2116:release:22 -L2117:ds01:22 -L2118:ds02:22 -L2119:ds03:22 \
 -L3117:ds01:3389 -L3110:another:3389 \
 -L4112:archiva:80 -L4113:subversion:80 -L4114:jira:80 -L4115:wiki:80 -L4116:release:80 \
 -L5119:ds03:1521 \
 -L6118:ds02:8161 \
 -L7110:another:9040  -L7118:ds02:9040 \
 -L8110:another:139 -L8117:ds01:139 -L8120:smbserver:139  -L8121:file1:139 \
 -p 15000 someone@localhost

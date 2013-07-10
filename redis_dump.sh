#!/bin/bash

IFS=$'\n'
echoerr() { echo "$@" 1>&2; }

help()
{
    echo "I'm help to help for redis dump shell script."
    echo "-h <hostname> Redis server hostname (default: 127.0.0.1)"
    echo "-p <port> Redis server port (default: 6379)"
    echo "-r <path to redis-cli> Path to redis-cli, such as \"/user/share/redis/bin/\""
    echo "-k <key> Key to dump, support the patterns which is provided by redis-cli, such as \"h*llo\"" 
    exit 0
}

set_output()
{
    k=$1
    voutput=`$redis_command "-h" $host "-p" $port --csv smembers $k`
    varr=$(echo $voutput|tr "," "\n")
    for v in $varr;do
        echo $(echo $k|tr ":" ",")","$v
    done    
}
list_output()
{
    k=$1
    vlen=`$redis_command -h $host -p $port llen $k`
    voutput=`$redis_command -h $host -p $port --csv lrange $k 0 $vlen`
    varr=$(echo $voutput|tr "," "\n")
    for v in $varr;do
        echo $(echo $k|tr ":" ",")","$v
    done    
}
hash_output()
{
    k=$1
    voutput=`$redis_command -h $host -p $port --csv hgetall $k`
    i=0
    IFS=$'\n'
    varr=$(echo $voutput|tr "," "\n")

    v1=""
    v2=""
    for v in $varr;do
        if [ $(($i%2)) -eq 0 ];then
            v1=$v
        else
            v2=$v    
            echo $(echo $k|tr ":" ",")","$v1","$v2
        fi
        let i++
    done    
}
string_output()
{
    k=$1
    voutput=`$redis_command -h $host -p $port --csv get $k`
    echo $(echo $k|tr ":" ",")","$voutput
}

#main function
#default value
host="localhost"
port=6379
format="csv"
delimiter=":"
input_key="*"

while [ -n "$1" ]; do
case "$1" in
   -help) help;; # function help is called
   -h) host=$2;shift 2;; 
   -p) port=$2;shift 2;; 
   -r) redis_path=$2;shift 2;;
   -f) format=$2;shift 2;;
   -d) delimiter=$2;shift 2;;
   -k) input_key=$2;shift 2;;
   --) shift;break;; # end of options
   -*) echoerr "error: no such option $1. -help for help";exit 1;;
   *) break;;
esac
done

echoerr "host is $host"
echoerr "port is $port"
echoerr "redis path is $redis_path"
echoerr "file format is $format"
echoerr "delimiter is $delimiter"

redis_command=$redis_path"redis-cli"
output=`$redis_command "-h" $host "-p" $port --csv "keys" $input_key `

if [ -z $output ];then
    echoerr "Can't find any available keys."
    exit 0
fi
keys_arr=$(echo $output|tr "," "\n")
if [ $? -eq 0 ]; then
    echoerr "Start to fetch the keys" 
else
    echoerr "Don't panic, I die."
    exit 1
fi
for key in $keys_arr;do
   echoerr "fetching key "$key
   key=`echo $key|tr -d "\""`
   vtype=$($redis_command -h $host -p $port type $key)

   case $vtype in
       set) set_output $key;;
       list) list_output $key;; 
       hash) hash_output $key;; 
       string) string_output $key;; 
       *) break;;
   esac
done 


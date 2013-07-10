redis_dump.sh
=============

A bash shell script for dump redis as a file

###Useage

    > ./redis_dump.sh -help   
    I'm help to help for redis dump shell script.
    -h <hostname> Redis server hostname (default: 127.0.0.1)
    -p <port> Redis server port (default: 6379)
    -r <path to redis-cli> Path to redis-cli, such as "/user/share/redis/bin/"
    -k <key> Key to dump, support the patterns which is provided by redis-cli, such as "h*llo"

###Converter
Map,set,string and list can be stored in redis. This shell will convert these type as following:

1.Map

    key1:{field1, value1}{field2, value2} 
 will be convert to
 
    key1,field1,value1
    key2,field2,value2
  
2.List

	key1:[value1,value2,value3]
will be convert to
	
	key1,value1
	key2,value2
	key3,value3

3.Set

	key1:{value1,value2,value3}
will be convert to
	
	key1,value1
	key2,value2
	key3,value3

###Todo
1. Improve the performance.
2. Refactor code.
3. Support zset and other types.
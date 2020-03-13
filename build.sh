
#!/bin/bash

PROJECT_NAME="demo"
URL="http://ali-app:1337/app?where=%7B%22name%22:%22$PROJECT_NAME%22%7D"
RETRYTIME=0

publish() {
    tar -czf $PROJECT_NAME.tgz *  --exclude node_modules
    if [ $? != 0 ]
    then
	echo "\n=========> compress failed\n"
	exit 1
    fi
    echo "\n=========> compress finished\n"

    for server in "${WORKERSERVERLIST[@]}"
    do
	scp -i /var/lib/jenkins/azure.pem $PROJECT_NAME.tgz root@$server:/tmp/
	if [ $? != 0 ]
	then
	    echo "\n=========> deliver to "$server" failed\n"
	    rm $PROJECT_NAME.tgz
	    exit 1
	fi
	echo "\n=========> deliver to "$server" finished\n"
    done
    
    rm $PROJECT_NAME.tgz
    echo "\n=========> $PROJECT_NAME.tgz deleted\n"
    
    for server in "${WORKERSERVERLIST[@]}"
    do
	ssh -i /var/lib/jenkins/azure.pem root@$server "find /root/jenkins/$PROJECT_NAME/* -type d -name "node_modules" -prune -o -print|xargs rm -rf;mkdir -p /root/jenkins/$PROJECT_NAME;tar -xzf /tmp/$PROJECT_NAME.tgz -C /root/jenkins/$PROJECT_NAME/;rm -rf /tmp/$PROJECT_NAME.tgz; mkdir -p /var/log/bda/$PROJECT_NAME; mkdir -p /data/$PROJECT_NAME; cd /root/jenkins/$PROJECT_NAME; npm --registry=https://registry.npm.taobao.org i --production --no-optional"
	if [ $? != 0 ]
	then
	    echo "\n=========> operation on "$server" failed\n"
	    exit 1
	fi
	echo "\n=========> "$server" done\n"
    done
}

getClientInfo(){
python3 -c '
import json
import sys
import os

result = os.environ["RESULT"]
data = json.loads(result)
ele = data[0]
if("clientServer" in ele):
    client = ele["clientServer"]
    print(client)
else:
	print("null")
'
}

getServerInfo(){
python3 -c '
import json
import sys
import os

result = os.environ["RESULT"]
data = json.loads(result)
ele = data[0]
if("server" in ele):
    server = ",".join(ele["server"])
    print(server)
else:
	print("null")
'
}


isValid(){
python3 -c '
import json
import sys
import os

result = os.environ["RESULT"]
data = json.loads(result)
print(len(data))

'
}

#get server and clientserver info from bdaservice
until [ $RETRYTIME -ge 3 ]
do
   RESULT=$(curl -s $URL)
   if [ $? != 0 ]
   then
   RETRYTIME=$[$RETRYTIME+1]
   echo "\n=========> url of  "$PROJECT_NAME" parser failed\n"
   echo "\n=========> retry in 5 seconds, it is the "$RETRYTIME" times try\n"
   sleep 5
   else
   break
   fi
done

if [ $RETRYTIME -ge 3 ]
then
echo "\n=========> retried totally 3 times\n"
exit 1
fi

export RESULT

RESULTLENGTH=$(isValid)

if [ "$RESULTLENGTH" != "1" ]
then
echo "\n=========> the result of "$PROJECT_NAME" is wrong\n"
exit 1
fi

WORKERSERVER=$(getServerInfo)
CLIENTSERVER=$(getClientInfo)
if [ "$WORKERSERVER" == "null" ] || [ "$CLIENTSERVER" == "null" ]
then
echo "\n=========> does not have server or clientServer info\n"
exit 1
fi
echo "\n=========> url of "$PROJECT_NAME" parser succeed\n"


WORKERINDEX=1
while true
do
    if [[ -z $WORKERSERVER ]]; then
	break
	fi

    if [[ $WORKERSERVER != *,* ]]; then
	WORKERSERVERLIST=$WORKERSERVER
	break
	fi

    cutelement=$(echo $WORKERSERVER | cut -d, -f $WORKERINDEX)
    
    if [[ -z ${cutelement} ]]; then
	break
	else
	WORKERSERVERLIST[$((WORKERINDEX-1))]=${cutelement}
	WORKERINDEX=$((WORKERINDEX+1))
	fi
done

if [ -z ${WORKERSERVERLIST} ] || [ -z ${CLIENTSERVER} ]; then
    echo 'client or worker server list is not specified'
    exit 1
else
    echo CLIENTSERVER="${CLIENTSERVER}"
    echo WORKERSERVER="${WORKERSERVERLIST[@]}"
fi

echo "node version: "`node -v`
echo "npm version: "`npm -v`
echo `pwd`
npm --registry=https://registry.npm.taobao.org install --no-optional
if [ $? = 0 ]
then
    echo "\n=========> npm install succeeded\n"
else
    echo "\n=========> npm install failed\n"
    exit 1
fi
npm test
echo "\n=========> test passed\n"
echo "\n=========> start publishing\n"
publish 
echo "\n=========> publish finished\n"
echo "\n=========> BDA-Dashboard update finished\n"
echo "
8I___________,8I______88____________\"8ba,. 
(8,_________,8P'______88______________88\"\"8bma,. 
_8I________,8P'_______88,______________\"8b___\"\"P8ma, 
_(8,______,8d\"________\`88,_______________\"8b_____\`\"8a 
__8I_____,8dP_________,8X8,________________\"8b.____:8b 
__(8____,8dP'__,I____,8XXX8,________________\`88,____8) 
___8,___8dP'__,I____,8XxxxX8,_____I,_________8X8,__,8 
___8I___8P'__,I____,8XxxxxxX8,_____I,________\`8X88,I8 
___I8,__\"___,I____,8XxxxxxxxX8b,____I,________8XXX88I, 
___\`8I______I'__,8XxxxxxxxxxxxXX8____I________8XXxxXX8, 
____8I_____(8__,8XxxxxxxxxxxxxxxX8___I________8XxxxxxXX8, 
___,8I_____I[_,8XxxxxxxxxxxxxxxxxX8__8________8XxxxxxxxX8, 
___d8I,____I[_8XxxxxxxxxxxxxxxxxxX8b_8_______(8XxxxxxxxxX8, 
___888I____\`8,8XxxxxxxxxxxxxxxxxxxX8_8,_____,8XxxxxxxxxxxX8 
___8888,____\"88XxxxxxxxxxxxxxxxxxxX8)8I____.8XxxxxxxxxxxxX8 
__,8888I_____88XxxxxxxxxxxxxxxxxxxX8_\`8,__,8XxxxxxxxxxxxX8\" 
__d88888_____\`8XXxxxxxxxxxxxxxxxxX8'__\`8,,8XxxxxxxxxxxxX8\" 
__888888I_____\`8XXxxxxxxxxxxxxxxX8'____\"88XxxxxxxxxxxxX8\" 
__88888888bbaaaa88XXxxxxxxxxxxXX8)______)8XXxxxxxxxxXX8\" 
__8888888I,_\`\`\"\"\"\"\"\"8888888888888888aaaaa8888XxxxxXX8\" 
__(8888888I,______________________.__\`\`\`\"\"\"\"\"88888P\" 
___88888888I,___________________,8I___8,_______I8\" 
____\"\"\"88888I,________________,8I'____\"I8,____;8\" 
___________\`8I,_____________,8I'_______\`I8,___8) 
____________\`8I,___________,8I'__________I8__:8' 
_____________\`8I,_________,8I'___________I8__:8 
______________\`8I_______,8I'_____________\`8__(8 
_______________8I_____,8I'________________8__(8; 
_______________8I____,8\"__________________I___88, 
"



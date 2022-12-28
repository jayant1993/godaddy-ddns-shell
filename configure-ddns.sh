 #!/bin/bash

# record names to modify
apps_arr=("@", "subdomain1" "subdomain2")

#domain
domain="example.com"

#key & secret from developer API
key="Your godaddy developer key"
secret="Your godaddy developer secret"

#declaring header
headers="Authorization: sso-key $key:$secret"

#status variable
api_status=true
echo -n "processing"
#looping services
for sr in ${apps_arr[@]}; do
        echo -n "."
        #name of the record
        name=$sr

        #Get current record details     
        result=$(curl -s -X GET -H "$headers" \
                 "https://api.godaddy.com/v1/domains/$domain/records/A/$name")

        #log result
        echo "Getting current DNS record $result" >> ./log.file
        dnsIp=$(echo $result | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
        echo "dnsIp:" $dnsIp >> ./log.file

        #Get public ip address there are several websites that can do this.
        currentIp=$(curl -s GET "http://ipinfo.io/json" | jq '.ip')
        echo "currentIp:" $currentIp >> ./log.file

        #comparing the existing and new IP
        if [ "$dnsIp" != "$currentIp" ];
        then
                echo "Ips are not equal" >> ./log.file
                request='[{"data":'$currentIp',"ttl":600}]'
                echo "request parms for updating:" $request >> ./log.file
                nresult=$(curl -i -s -X PUT \
                        -H "$headers" \
                        -H "Content-Type: application/json" \
                        -d $request "https://api.godaddy.com/v1/domains/$domain/records/A/$name")
                echo "DNS record update response:" $nresult >> ./log.file
        fi

done
echo " "
echo "finished updating the DNS record"
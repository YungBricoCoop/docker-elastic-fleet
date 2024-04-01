#!/bin/bash

CA_CERT="/usr/share/elasticsearch/config/certs/ca/ca.crt"

display_info() {
    echo -e "\e[93mThis script is only meant to be use if you DON'T HAVE any PUBLIC SSL CERTIFICATE for Elasticsearch.\e[0m"
	echo -e "You only need to update the elastic hosts url if not already done, then copy paste the CA and the CA fingerprint to the Fleet settings. \e[96mFleet -> Settings -> Edit default output\e[0m"
}

display_change_elastic_url() {
	echo "1. [Hosts]"
	echo -e "\e[95mhttps://elastic-search:9200\e[0m"
	echo ""
}

display_ca_fingerprint() {
    echo "2. [Elasticsearch CA trusted fingerprint (optional)]"
    local fingerprint=$(openssl x509 -fingerprint -sha256 -noout -in ${CA_CERT} | awk -F"=" '{ print $2 }' | sed 's/://g')
    echo -e "\e[95m${fingerprint}\e[0m"  
    echo ""  
}

display_ca() {
    echo "3. [Advanced YAML Configuration]"
    
    echo -e "\e[95mssl:\n  certificate_authorities:\n  - |\e[0m"
    sed 's/^/    /' ${CA_CERT} | while IFS= read -r line; do
        echo -e "\e[95m${line}\e[0m"
    done
    echo ""  
}

display_info
display_change_elastic_url
display_ca_fingerprint
display_ca

#!/bin/bash
# You are NOT allowed to change the files' names!
domainNames="domainNames.txt"
domainNames2="domainNames2.txt"
IPAddressesSame="IPAddressesSame.txt"
IPAddressesDifferent="IPAddressesDifferent.txt"
adblockRules="adblockRules"

function adBlock() {
    if [ "$EUID" -ne 0 ];then
        printf "Please run as root.\n"
        exit 1
    fi
    if [ "$1" = "-domains"  ]; then
        sort $domainNames > 'sortedDoms.txt'
        sort $domainNames2 > 'sortedDoms2.txt'
        # Here the domainNames files are being sorted
        sortedDoms='sortedDoms.txt'
        sortedDoms2='sortedDoms2.txt'

        # The Sorted files are being compared to find same and different domains
        comm -12 $sortedDoms $sortedDoms2 >> sameDoms.txt
        comm -3 $sortedDoms $sortedDoms2 >> diffDoms.txt
        
        lines=$(sed -n '$=' sameDoms.txt)
        count=1
        while IFS= read -r line
        do
            echo -ne "Generating same IPs... $count/$lines\r"   # Show progress
            count=$(($count+1))
            # Extracting IP Address from each domain
            host $line | grep 'has address' | awk '{print $4}' >> $IPAddressesSame
        done < sameDoms.txt 
        echo 'IPAddressesSame.txt was generated!'

        lines=$(sed -n '$=' diffDoms.txt)
        count=1
        while IFS= read -r line
        do
            echo -ne "Generating different IPs... $count/$lines\r"  # Show progress
            count=$(($count+1))
            # Extracting IP Address from each domain
            host $line | grep 'has address' | awk '{print $4}' >> $IPAddressesDifferent
        done < diffDoms.txt 
        echo 'IPAddressesDifferent.txt was generated!'

        rm -rf sameDoms.txt diffDoms.txt
        rm -rf sortedDoms.txt sortedDoms2.txt
        true
            
    elif [ "$1" = "-ipssame"  ]; then
        # Configure the DROP adblock rule based on the IP addresses of $IPAddressesSame file.
        while IFS= read -r line
        do
            iptables -A INPUT -s $line -j DROP
        done < $IPAddressesSame
        true
    elif [ "$1" = "-ipsdiff"  ]; then
        # Configure the REJECT adblock rule based on the IP addresses of $IPAddressesDifferent file.
        
        while IFS= read -r line
        do
            iptables -A INPUT -s $line -j REJECT
        done < $IPAddressesDifferent
        true
        
    elif [ "$1" = "-save"  ]; then
        # Save rules to $adblockRules file.
        iptables-save > adblockRules
        true
        
    elif [ "$1" = "-load"  ]; then
        # Load rules from $adblockRules file.
        iptables-restore < adblockRules
        true

        
    elif [ "$1" = "-reset"  ]; then
        # Reset rules to default settings (i.e. accept all).
        iptables -F
        true

        
    elif [ "$1" = "-list"  ]; then
        # List current rules.
        iptables --list -n
        true
        
    elif [ "$1" = "-help"  ]; then
        printf "This script is responsible for creating a simple adblock mechanism. It rejects connections from specific domain names or IP addresses using iptables.\n\n"
        printf "Usage: $0  [OPTION]\n\n"
        printf "Options:\n\n"
        printf "  -domains\t  Configure adblock rules based on the domain names of '$domainNames' file.\n"
        printf "  -ipssame\t\t  Configure the DROP adblock rule based on the IP addresses of $IPAddressesSame file.\n"
	    printf "  -ipsdiff\t\t  Configure the DROP adblock rule based on the IP addresses of $IPAddressesDifferent file.\n"
        printf "  -save\t\t  Save rules to '$adblockRules' file.\n"
        printf "  -load\t\t  Load rules from '$adblockRules' file.\n"
        printf "  -list\t\t  List current rules.\n"
        printf "  -reset\t  Reset rules to default settings (i.e. accept all).\n"
        printf "  -help\t\t  Display this help and exit.\n"
        exit 0
    else
        printf "Wrong argument. Exiting...\n"
        exit 1
    fi
}

adBlock $1
exit 0

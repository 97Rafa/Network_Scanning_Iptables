# Network Scanning and Iptables

This is a bash script which sets a firewall against specific set of domain names.
It reads the domain names from the files and it compares them with the command `comm -12`
to find the same ones and `comm -3` to find the different ones. Then by manipulating them as
described below you can build some adblock rules.

## Usage:
    - domains  
        Compares the domainNames files and generates IPAddressesSame.txt and IPAddressesDifferent.txt
    - ipssame  
        Configure the DROP adblock rule based on the IP addresses of $IPAddressesSame file
    - ipsdiff  
        Configure the DROP adblock rule based on the IP addresses of $IPAddressesDifferent file
    - save  
        Save rules to '$adblockRules' file
    - load  
        Load rules from '$adblockRules' file
    - list  
        List current rule
    - reset  
        Reset rules to default settings (i.e. accept all)
    - help  
        Display this help and exit

## Notes:


# get-azure-cdn-ips
A simple bash script to get IP subnets from [Azure's CDN EdgeNodes API](https://docs.microsoft.com/en-us/rest/api/cdn/edgenodes/list)

This repository contains two bash scripts that query the EdgeNodes API to return a list of IPv4 or IPv6 subnets.
  - getips.sh - very simple bash script that returns a list of subnets to stdout
  - getips-cron.sh - based off the above script, except it has more error checking, outputs the list of subnets to text files, and the original JSON response. It is responsible for generating the files in [azure-cdn-ips](https://github.com/Gelob/azure-cdn-ips/).

### Requirements
- bash
- curl
- jq
- git

### Usage
##### getips.sh
You need to edit the script to provide your Azure App API token details. See my [blog](https://medium.com/@what_if/automatically-query-the-azure-cdn-edge-nodes-list-5024951bd420) post for details on how to generate one.

You'll need 3 things: 
1. Directory (tenant) ID - [tenantid]
2. Application (client) ID - [clientid]
3. Client Secret - [clientsecret]
Run `./getips.sh` to get a list of IPv4 subnets.
Run `./getips.sh 6` to get a list of IPv6 subnets

##### getips-cron.sh
Same as above but you also need edit two additional variables:
1. installdir - Where the bash script will live and log file will be written to (default: /opt/azure)
2. gitdir - Where the downloaded files will live, you will have to run `git init` in this directory and setup a remote repoistory if you want it to push) (default: /opt/azure/getips)

The script will write 4 files to the directory specified in gitdir upon successful execution
- edgenodes-ipv4.txt - contains IP/CIDR formatted list of IPv4 Addresses
- edgenodes-ipv6.txt - contains IP/CIDR formatted list of IPv6 Addresses
- edgenodes.json - contains raw JSON output from the Azure API
- lastrun - contains the date the script last ran

If any errors are detected they will be logged to the directory specified in installdir/getips.log

### Community
Want to contribute, or have comments? Feel free to open an [issue](https://github.com/Gelob/get-azure-cdn-ips/issues/new)

### License
[Clear BSD License](https://github.com/Gelob/get-azure-cdn-ips/blob/master/LICENSE)

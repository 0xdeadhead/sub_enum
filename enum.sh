#! /bin/bash
mkdir $1
##Passive Subdomain enumeration
echo "[+] Started passive Enumeration"
findomain -c fd_config.ini -t "${1}"  -u "$1/${1}.subs"
assetfinder -subs-only "${1}" | anew "${1}/${1}.subs" >> "${1}/${1}.subs"
subfinder -d "${1}" -silent | anew "${1}/${1}.subs" >> "${1}/${1}.subs"

##Getting subdomains from Rapid7 FDNS Dataset
echo "[+] Getting Subdomains from FDNS Dataset"
crobat -s "${1}" | anew "${1}/${1}.subs" >> "${1}/${1}.subs"

##Updating CommonSpeak2 Wordlist
[[ -f etag.txt ]] || touch etag.txt
echo "[+] Checking for Commonspeak2 Wordlist Updates"
etag=$( curl -I -s https://raw.githubusercontent.com/assetnote/commonspeak2-wordlists/master/subdomains/subdomains.txt | grep -i "Etag" | cut -f 2 -d " " | sed "s/\"//g" )
[[ $etag != $( cat etag.txt ) ]] && echo "[+] Updating Wordlist" && echo $etag > etag.txt && wget -q  https://raw.githubusercontent.com/assetnote/commonspeak2-wordlists/master/subdomains/subdomains.txt && echo "[+] Update Completed"

##Refreshing Resolvers list
[[ "${2}" == "refresh" ]] && dnsvalidator -tL https://public-dns.info/nameservers.txt -threads 100 -o resolvers.txt

echo "[+] Started subdomain bruteforcing"
##Bruteforcing Subdomains using shuffledns
shuffledns -d "${1}" -w subdomains.txt  -r resolvers.txt -o "${1}/final_subs.txt"

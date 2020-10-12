#! /bin/bash

##Create Recon_data directory if it doesn't exists.
[[ -d "${HOME}/Recon_data" ]] || mkdir "${HOME}/Recon_data"

##Prompt for overwriting existing domain directory.
ans="N"
[[ -d "${HOME}/Recon_data/${1}" ]] && printf "Directory ${HOME}/Recon_data/${1} already exists.Do you want to overwrite[y/N]?" && read ans && [[ "$ans" != "y" ]] && exit
[[ $ans == "y" ]] && rm -r "${HOME}/Recon_data/${1}"
mkdir "${HOME}/Recon_data/${1}"

#Color formating vars
RED='\033[0;31m'
NC='\033[0m'

##Passive Subdomain enumeration.
echo -e "${RED}[+] Started passive Enumeration using findomain${NC}"
findomain -c fd_config.ini -q -t "${1}"  -u "${HOME}/Recon_data/${1}/${1}.subs"
echo -e "${RED}[+] Started passive Enumeration using assetfinder${NC}"
assetfinder -subs-only "${1}" | anew "${HOME}/Recon_data/${1}/${1}.subs" 
echo -e "${RED}[+] Started passive Enumeration using subfinder${NC}"
subfinder -d "${1}" -silent | anew "${HOME}/Recon_data/${1}/${1}.subs" 

##Getting subdomains from Rapid7 FDNS Dataset.
echo -e "${RED}[+] Getting Subdomains from FDNS Dataset${NC}"
crobat -s "${1}" | grep "${1}" |  anew "${HOME}/Recon_data/${1}/${1}.subs" 

##Updating CommonSpeak2 Wordlist.
[[ -f etag.txt ]] || touch etag.txt
echo -e "${RED}[+] Checking for Commonspeak2 Wordlist Updates${NC}"
etag=$( curl -I -s https://raw.githubusercontent.com/assetnote/commonspeak2-wordlists/master/subdomains/subdomains.txt | grep -i "Etag" | cut -f 2 -d " " | sed "s/\"//g" )
[[ $etag != $( cat etag.txt ) ]] && echo -e "${RED}[+] Updating Wordlist${NC}" && echo $etag > etag.txt && wget -q  https://raw.githubusercontent.com/assetnote/commonspeak2-wordlists/master/subdomains/subdomains.txt && echo -e "${RED}[+] Update Completed${NC}"

##Refreshing Resolvers list.
[[ -f "resolvers.txt" ]] || dnsvalidator -tL https://public-dns.info/nameservers.txt -threads 100 -o resolvers.txt
[[ "${2}" == "refresh" ]] && dnsvalidator -tL https://public-dns.info/nameservers.txt -threads 100 -o resolvers.txt

##Bruteforcing Subdomains using shuffledns.
echo -e "${RED}[+] Started subdomain bruteforcing${NC}"
shuffledns -silent -d "${1}" -w subdomains.txt  -r resolvers.txt -o "${HOME}/Recon_data/${1}/final_subs.txt"

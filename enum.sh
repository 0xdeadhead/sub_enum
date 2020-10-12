#! /bin/bash

##Create Recon_data directory if it doesn't exists.
[[ -d "${HOME}/Recon_data" ]] || mkdir "${HOME}/Recon_data"

##Prompt for overwriting existing domain directory.
[[ -d "${HOME}/Recon_data/${1}" ]] && printf "Directory ${HOME}/Recon_data/${1} already exists.Do you want to overwrite[y/N]?" && read ans && [[ "$ans" != "y" ]] && exit || rm -r "${HOME}/Recon_data/${1}"
mkdir "${HOME}/Recon_data/${1}"

##Passive Subdomain enumeration.
echo "[+] Started passive Enumeration using findomain"
findomain -c fd_config.ini -q -t "${1}"  -u "${HOME}/Recon_data/${1}/${1}.subs"
echo "[+] Started passive Enumeration using assetfinder"
assetfinder -subs-only "${1}" | anew "${HOME}/Recon_data/${1}/${1}.subs" 
echo "[+] Started passive Enumeration using subfinder"
subfinder -d "${1}" -silent | anew "${HOME}/Recon_data/${1}/${1}.subs" 

##Getting subdomains from Rapid7 FDNS Dataset.
echo "[+] Getting Subdomains from FDNS Dataset"
crobat -s "${1}" | grep "${1}" |  anew "${HOME}/Recon_data/${1}/${1}.subs" 

##Updating CommonSpeak2 Wordlist.
[[ -f etag.txt ]] || touch etag.txt
echo "[+] Checking for Commonspeak2 Wordlist Updates"
etag=$( curl -I -s https://raw.githubusercontent.com/assetnote/commonspeak2-wordlists/master/subdomains/subdomains.txt | grep -i "Etag" | cut -f 2 -d " " | sed "s/\"//g" )
[[ $etag != $( cat etag.txt ) ]] && echo "[+] Updating Wordlist" && echo $etag > etag.txt && wget -q  https://raw.githubusercontent.com/assetnote/commonspeak2-wordlists/master/subdomains/subdomains.txt && echo "[+] Update Completed"

##Refreshing Resolvers list.
[[ "${2}" == "refresh" ]] && dnsvalidator -tL https://public-dns.info/nameservers.txt -threads 100 -o resolvers.txt

##Bruteforcing Subdomains using shuffledns.
echo "[+] Started subdomain bruteforcing"
shuffledns -silent -d "${1}" -w subdomains.txt  -r resolvers.txt -o "${HOME}/Recon_data/${1}/final_subs.txt"

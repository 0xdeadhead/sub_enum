#! /bin/bash

##Install dependencies
sudo apt update -y && sudo apt install -y build-essential make rustc perl git software-properties-common

##Install python
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update -y && sudo apt install python3.8

##Install findomain
git clone https://github.com/Edu4rdSHL/findomain.git
cd findomain
cargo build --release
sudo mv target/release/findomain /usr/bin/
cd $HOME

##Install Golang
wget https://dl.google.com/go/go1.15.2.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.15.2.linux-amd64.tar.gz
echo "export PATH=\"${PATH}:/usr/local/go/bin\"" >> $HOME/.profile
echo "export GOPATH=\"${HOME}/go/bin\"" >> $HOME/.profile
source $HOME/.profile

##Install assetfinder
go get -u github.com/tomnomnom/assetfinder

##Install anew
go get -u github.com/tomnomnom/anew

##Install subfinder
GO111MODULE=on go get -u -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder

##Install crobat
go get -u github.com/cgboal/sonarsearch/crobat

##Install dnsvalidator
https://github.com/vortexau/dnsvalidator.git
cd dnsvalidator/
sudo python3 setup.py install
cd $HOME

##Install massdns
https://github.com/blechschmidt/massdns.git
cd massdns/ && make && sudo mv bin/massdns /usr/bin/
cd $HOME

##Install shuffledns
GO111MODULE=on go get -u -v github.com/projectdiscovery/shuffledns/cmd/shuffledns
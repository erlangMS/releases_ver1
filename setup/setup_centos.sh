#!/bin/bash

echo "  ****** Install Erlang Runtime *****"

echo "Adding Erlang repository entry"
wget https://packages.erlang-solutions.com/erlang-solutions-1.0-1.noarch.rpm
rpm -Uvh erlang-solutions-1.0-1.noarch.rpm


echo "Refresh the repository cache and install either the erlang package"
sudo apt-get update
sudo yum -y install erlang-hipe-19.2-1.el7.centos.x86_64 \
erlang-erl_docgen-19.2-1.el7.centos.x86_64 \
erlang-erts-19.2-1.el7.centos.x86_64 \
erlang-asn1-19.2-1.el7.centos.x86_64 \
erlang-eunit-19.2-1.el7.centos.x86_64 \
erlang-syntax_tools-19.2-1.el7.centos.x86_64 \
erlang-runtime_tools-19.2-1.el7.centos.x86_64 \
erlang-erl_interface-19.2-1.el7.centos.x86_64 \
erlang-ic-19.2-1.el7.centos.x86_64 \
erlang-stdlib-19.2-1.el7.centos.x86_64 \
erlang-ssl-19.2-1.el7.centos.x86_64 \
erlang-eldap-19.2-1.el7.centos.x86_64 \
erlang-crypto-19.2-1.el7.centos.x86_64 \
erlang-public_key-19.2-1.el7.centos.x86_64 \
erlang-odbc-19.2-1.el7.centos.x86_64 \
erlang-compiler-19.2-1.el7.centos.x86_64 \
erlang-tools-19.2-1.el7.centos.x86_64 \
erlang-edoc-19.2-1.el7.centos.x86_64 \
erlang-kernel-19.2-1.el7.centos.x86_64 \
erlang-inets-19.2-1.el7.centos.x86_64 \
erlang-xmerl-19.2-1.el7.centos.x86_64 \
erlang-parsetools-19.2-1.el7.centos.x86_64 \
erlang-mnesia-19.2-1.el7.centos.x86_64 \
erlang-doc-19.2-1.el7.centos.x86_64 \
erlang-jinterface-19.2-1.el7.centos.x86_64 \
erlang-gs-19.2-1.el7.centos.x86_64 \
erlang-solutions-1.0-1.noarch \
erlang-sasl-19.2-1.el7.centos.x86_64




echo " ****** Install Python3 from EPEL Repository  ********"

echo "First, install yum-utils"
sudo yum -y install yum-utils 

echo "The latest EPEL 7 repository offers python3 (python 3.4 to be exact)"
sudo yum -y install epel-release 


echo "Then install python 3.4 and its libraries using yum"
sudo yum install python34 

echo "Install pip"
curl -O https://bootstrap.pypa.io/get-pip.py
sudo /usr/bin/python3.4 get-pip.py 


echo " ******** Install OpenLdap tools *********"
sudo yum -y install openldap openldap-clients


echo " ****** Install FreeTDS driver (driver for SQL Server) ****"
sudo yum -y install freetds.x86_64 freetds-devel.x86_64
 


echo " ***** Install Enterprise service bus ERLANGMS *****"
wget https://github.com/erlangMS/releases/raw/master/ems-bus_1.0.11/ems-bus-1.0.11-el7.centos.x86_64.rpm
sudo rpm -ihv ems-bus-1.0.11-el7.centos.x86_64.rpm 







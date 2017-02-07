#!/bin/bash
#
# Autor: Everton de Vargas Agilar
# Data: 07/02/2017
#
# Goal: Instalador para Linux CentOS x64
#
# Modo de usar: 
#
#    $ ./setup_centos.sh
#
#
#
#
#
## Histórico de modificações do software:
#
# Data       |  Quem           |  Mensagem  
# -----------------------------------------------------------------------------------------------------
# 28/11/2016  Everton Agilar     Release inicial do script de release
#
#
#
#
#
#
#
########################################################################################################

LINUX_DESCRIPTION=$(lsb_release -d | sed -rn 's/Description:\t(.*$)/\1/p')

echo "Starting the ERLANGMS installation on $LINUX_DESCRIPTION"
echo "============================================================================="


# ***** Erlang Runtime Library **********

if ! rpm -qi erlang-solutions >> /dev/null ; then
	echo "Adding Erlang repository entry"
	wget https://packages.erlang-solutions.com/erlang-solutions-1.0-1.noarch.rpm
	sudo rpm -Uvh erlang-solutions-1.0-1.noarch.rpm

	echo "yum update..."
	sudo apt-get update
fi


if ! erl -version 2> /dev/null;  then
	echo "Installing Erlang Runtime Library packages..."
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
else
	echo "Skipping Erlang Runtime Library installation because it is already installed."
fi



# ****** Install Python3 from EPEL Repository  ********
if ! rpm -qi python34 >> /dev/null ; then
	echo "Preparing to install python34..."
	
	echo "Installing yum-utils..."
	if ! rpm -qi yum-utils  >> /dev/null ; then
		sudo yum -y install yum-utils 
	else
		echo "Skipping yum-utils installation because it is already installed."
	fi

	echo "Installing the latest EPEL 7 repository..."
	if ! rpm -qi yum-utils  >> /dev/null ; then
		sudo yum -y install epel-release 
	else
		echo "Skipping EPEL 7 repository installation because it is already installed."
	fi


	echo "Installing python 3.4 and its libraries..."
	sudo yum install python34 

	echo "Installing pip..."
	curl -O https://bootstrap.pypa.io/get-pip.py
	sudo /usr/bin/python3.4 get-pip.py 
else
	echo "Skipping python34 installation because it is already installed."
fi



# ******** Install OpenLdap tools *********
if ! rpm -qi openldap >> /dev/null ; then
	echo "Installing openldap package..."
	sudo yum -y install openldap
else
	echo "Skipping openldap installation because it is already installed."
fi
if ! rpm -qi openldap-clients >> /dev/null ; then
	echo "Installing openldap-clients package..."
	sudo yum -y install openldap-clients
else
	echo "Skipping openldap-clients installation because it is already installed."
fi



# ****** Install FreeTDS driver (driver for SQL Server) ****
if ! rpm -qi freetds >> /dev/null ; then
	echo "Installing driver SQL-Server freetds..."
	sudo yum -y install freetds.x86_64 freetds-devel.x86_64
else
	echo "Skipping driver SQL-Server freetds installation because it is already installed."
fi
 


# ***** Install ems-bus *****
if ! rpm -qi ems-bus >> /dev/null ; then
	echo "Downloading ems-bus-1.0.11-el7.centos.x86_64.rpm..."
	wget https://github.com/erlangMS/releases/raw/master/ems-bus_1.0.11/ems-bus-1.0.11-el7.centos.x86_64.rpm
	echo "Installing ems-bus-1.0.11-el7.centos.x86_64.rpm..."
	sudo rpm -Uhv ems-bus-1.0.11-el7.centos.x86_64.rpm
else
	echo "Skipping ems-bus-1.0.11-el7.centos.x86_64.rpm installation because it is already installed."
fi





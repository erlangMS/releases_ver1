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


# ***** Parameters to script *****
#LINUX_DESCRIPTION=$(lsb_release -d 2> /dev/null | sed -rn 's/Description:\t(.*$)/\1/p')
VERSION_SETUP="ems-bus-1.0.11-el7.centos.x86_64"
LINUX_DESCRIPTION=$(cat /etc/redhat-release 2> /dev/null)
YUM_UPDATE_NECESSARY="false"
CURRENT_DIR=$(pwd)
TMP_DIR="/tmp/setup_$VERSION_SETUP_$$/"


# Enables installation logging
LOG_FILE="setup_""$VERSION_SETUP""_$(date '+%d%m%Y_%H%M%S').log"
exec > >(tee -a ${LOG_FILE} )
exec 2> >(tee -a ${LOG_FILE} >&2)


# Files downloaded go to /setup_emsbus_$$
mkdir -p $TMP_DIR && cd $TMP_DIR


echo "Starting the ERLANGMS installation on $LINUX_DESCRIPTION"
echo "Purpose: A service-oriented bus developed in Erlang/OTP by Everton de Vargas Agilar"
echo "Version: $VERSION_SETUP"
echo "Log file: $LOG_FILE" 
echo "Date: $(date '+%d/%m/%Y %H:%M:%S')"
echo "============================================================================="


# ***** EPEL 7 repository **********
echo "Installing the latest EPEL 7 repository..."
if ! rpm -qi epel-release  >> /dev/null ; then
	sudo yum -y install epel-release
	YUM_UPDATE_NECESSARY="true"
else
	echo "Skipping EPEL 7 repository installation because it is already installed."
fi



# ***** Erlang Runtime Library **********

# erlang-solutions is a rpm package for Erlang repository
if ! rpm -qi erlang-solutions >> /dev/null ; then
	echo "Adding Erlang repository entry"
	wget -nv https://packages.erlang-solutions.com/erlang-solutions-1.0-1.noarch.rpm

	# Check internet connectivity
	if [ "$?" -eq "4" ]; then
		echo "Make sure your DNS is well configured or if there is Internet on this host. Canceling installation..."
		exit 1
	fi

	sudo rpm -Uvh erlang-solutions-1.0-1.noarch.rpm
	YUM_UPDATE_NECESSARY="true"
fi


# update yum if necessary
if [ "$YUM_UPDATE_NECESSARY" == "true" ]; then
	echo "yum update..."
	sudo yum -y update
fi


# Check if Erlang runtime already exist
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
	
	if ! rpm -qi yum-utils  >> /dev/null ; then
		echo "Installing yum-utils..."
		sudo yum -y install yum-utils 
	else
		echo "Skipping yum-utils installation because it is already installed."
	fi

	echo "Installing python 3.4 and its libraries..."
	sudo yum -y install python34 

	if ! pip3 --version 2> /dev/null;  then
		echo "Installing pip..."
		curl -O https://bootstrap.pypa.io/get-pip.py
		sudo /usr/bin/python3.4 get-pip.py 
	fi
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
	wget -nv https://github.com/erlangMS/releases/raw/master/ems-bus_1.0.11/ems-bus-1.0.11-el7.centos.x86_64.rpm
	echo "Installing ems-bus-1.0.11-el7.centos.x86_64.rpm..."
	sudo rpm -Uhv ems-bus-1.0.11-el7.centos.x86_64.rpm
else
	echo "Skipping ems-bus-1.0.11-el7.centos.x86_64.rpm installation because it is already installed."
fi


cd $CURRENT_DIR
echo "Ok!!!"

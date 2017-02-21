#!/bin/bash
#
# Autor: Everton de Vargas Agilar
# Data: 07/02/2017
#
# Goal: Installer for Linux Ubuntu, Debian and CentOS
#
#
#
## Software modification history:
#
# Data       |  Quem           |  Mensagem  
# -----------------------------------------------------------------------------------------------------
# 28/11/2016  Everton Agilar     Initial release
#
#
#
#
#
########################################################################################################

# Identify the linux distribution: ubuntu, debian, centos
LINUX_DISTRO=$(awk -F"=" '{ if ($1 == "ID"){ 
								gsub("\"", "", $2);  print $2 
							} 
						  }' /etc/os-release)

# Get linux description
LINUX_DESCRIPTION=$(awk -F"=" '{ if ($1 == "PRETTY_NAME"){ 
									gsub("\"", "", $2);  print $2 
								 } 
							   }'  /etc/os-release)


LINUX_VERSION_ID=$(awk -F"=" '{ if ($1 == "VERSION_ID"){ 
									gsub("\"", "", $2);  print $2 
								 } 
							   }'  /etc/os-release)


# Indicates whether it will be necessary to update the repository
UPDATE_NECESSARY="false"


CURRENT_DIR=$(pwd)
TMP_DIR="/tmp/erlangms/setup_$SETUP_VERSION_$$/"
mkdir -p $TMP_DIR && cd $TMP_DIR


# Enables installation logging
LOG_FILE="setup_""$SETUP_VERSION""_$(date '+%d%m%Y_%H%M%S').log"
exec > >(tee -a ${LOG_FILE} )
exec 2> >(tee -a ${LOG_FILE} >&2)


echo "Starting the ERLANGMS installation on $LINUX_DESCRIPTION"
echo "Preparing for installation, please wait..."


# Github repository ERLANGMS release
REPO_RELEASE_URL="https://github.com/erlangms/releases/raw/master"
				  

# Get the last release version of the ems-bus
RELEASE_VERSION=$(curl https://raw.githubusercontent.com/erlangms/releases/master/setup/current_version 2> /dev/null)
if [ -z "$RELEASE_VERSION" ]; then
	echo "Could not download the latest version of the ems-bus. Check your connection!!!"
	exit 1
fi


# Define $SETUP_VERSION, SETUP_PACKAGE and $SETUP_FILE
if [[ "$LINUX_DISTRO" =~ (centos|debian|ubuntu) ]]; then
	SETUP_VERSION="ems-bus-$RELEASE_VERSION.$LINUX_DISTRO.$LINUX_VERSION_ID.x86_64"
	if [ "$LINUX_DISTRO" == "centos" ]; then
		SETUP_PACKAGE="$SETUP_VERSION.rpm"
	else
		SETUP_PACKAGE="$SETUP_VERSION.deb"
	fi
	SETUP_FILE="$REPO_RELEASE_URL/$RELEASE_VERSION/$SETUP_PACKAGE"
else
	echo "Setup $SETUP_VERSION is incompatible with this Linux distribution. It is possible to install in the Ubuntu, Debian and Centos distributions."
	exit 1
fi	


# Download the ems-bus package according to the distribution
echo "Downloading $SETUP_FILE..."
wget -nvc $SETUP_FILE  2> /dev/null
if [ ! $? -eq 0 ]; then
	echo "The ems-bus package $SETUP_PACKAGE could not be downloaded. Canceling the installation."
	exit 1
fi



echo "Purpose: A service-oriented bus developed in Erlang/OTP by Everton de Vargas Agilar"
echo "Version: $SETUP_VERSION"
echo "Log file: $LOG_FILE" 
echo "Date: $(date '+%d/%m/%Y %H:%M:%S')"
echo "============================================================================="


if [ "$LINUX_DISTRO" == "centos" ]; then

	# ***** EPEL 7 repository **********
	echo "Installing the latest EPEL 7 repository..."
	if ! rpm -qi epel-release  >> /dev/null ; then
		sudo yum -y install epel-release
		UPDATE_NECESSARY="true"
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
		UPDATE_NECESSARY="true"
	fi


	# update yum if necessary
	if [ "$UPDATE_NECESSARY" == "true" ]; then
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
	echo "Installing $SETUP_PACKAGE..."
	sudo rpm -Uhv $SETUP_FILE

elif [ "$LINUX_DISTRO" == "debian" ]; then
	echo "todo debian"

elif [ "$LINUX_DISTRO" == "ubuntu" ]; then
	echo "todo ubuntu"
fi	

cd $CURRENT_DIR
rm -rf $TMP_DIR
echo "Ok!!!"

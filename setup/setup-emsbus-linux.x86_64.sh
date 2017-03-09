#!/bin/bash
#
# Author: Everton de Vargas Agilar
# Date: 07/02/2017
#
# Goal: Installer for Linux Ubuntu, Debian and CentOS
#
#
#
## Software modification history:
#
# Data       |  Quem           |  Mensagem  
# -----------------------------------------------------------------------------------------------------
# 15/01/2017  Everton Agilar     Initial release
# 05/03/2017  Everton Agilar     Make sure only root can run our script
#
#
#
#
#
########################################################################################################

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This setup must be run as root" 1>&2
   exit 1
fi


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


# Primary IP of the server
LINUX_IP_SERVER=$(hostname -I | cut -d" " -f1)


CURRENT_DIR=$(pwd)
TMP_DIR="/tmp/erlangms/setup_$SETUP_VERSION_$$/"
mkdir -p $TMP_DIR && cd $TMP_DIR
LOG_FILE="setup_emsbus_""$SETUP_VERSION""_$(date '+%d%m%Y_%H%M%S').log"


# SMTP parameter
SMTP_SERVER="mail.unb.br"
SMTP_PORT=587
SMTP_DE=""
SMTP_PARA=""
SMTP_PASSWD=""
SMTP_RE_CHECK="^[a-z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-z0-9!#$%&'*+/=?^_\`{|}~-]+)*@([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?\$"

# Function to send email
# Parameters:
#   $1  - title
#   $2  - subject
send_email () {
    TITULO_MSG=$1
    SUBJECT=$2
    python <<EOF
# -*- coding: utf-8 -*-
import smtplib
from email.mime.text import MIMEText
from email.Utils import formatdate
try:
	smtp = smtplib.SMTP("$SMTP_SERVER", $SMTP_PORT)
	smtp.starttls()
	smtp.login("$SMTP_DE", "$SMTP_PASSWD")
	msg = MIMEText("""$SUBJECT""")
	msg['Subject'] = "$TITULO_MSG"
	msg['From'] = "$SMTP_DE"
	msg['To'] = "$SMTP_PARA"
	msg['Date'] = formatdate(localtime=True)
	msg['Content-Type'] = 'text/plain; charset=utf-8'
	smtp.sendmail("$SMTP_DE", ["$SMTP_PARA"], msg.as_string())
	smtp.quit()
	exit(0)
except Exception as e:
	print(e)
	exit(1)
EOF
}


# Performs the installation of the ems-bus
install(){
	# Enables installation logging
	exec > >(tee -a ${LOG_FILE} )
	exec 2> >(tee -a ${LOG_FILE} >&2)

	echo "Preparing for installation, please wait..."

	# Indicates whether it will be necessary to update the repository
	UPDATE_NECESSARY="false"

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
		SETUP_VERSION="ems-bus-$RELEASE_VERSION-$LINUX_DISTRO.$LINUX_VERSION_ID.x86_64"
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


	echo "Starting the ERLANGMS installation on $LINUX_DESCRIPTION"
	echo "Purpose: A service-oriented bus developed in Erlang/OTP by Everton de Vargas Agilar"
	echo "Version: $SETUP_VERSION"
	echo "Log file: $LOG_FILE" 
	echo "Host ip: $LINUX_IP_SERVER"
	echo "Date: $(date '+%d/%m/%Y %H:%M:%S')"
	echo "============================================================================="


	if [ "$LINUX_DISTRO" = "centos" ]; then

		# ***** EPEL 7 repository **********
		if ! rpm -qi epel-release  >> /dev/null ; then
			echo "Installing the latest EPEL 7 repository..."
			sudo yum -y install epel-release
			UPDATE_NECESSARY="true"
		else
			echo "Skipping EPEL 7 repository installation because it is already installed."
		fi



		# ***** Erlang Runtime Library **********

		# erlang-solutions is a rpm package for Erlang repository
		if ! rpm -qi erlang-solutions >> /dev/null ; then
			echo "Adding Erlang repository entry."
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


		# ***** Install or update ems-bus *****
		
		if ! rpm -qi ems-bus >> /dev/null ; then
			echo "Installing $SETUP_PACKAGE..."
			sudo rpm -ihv $SETUP_FILE
		else
			sudo systemctl stop ems-bus > /dev/null 2>&1
			VERSION_INSTALLED=$(rpm -qi ems-bus | grep Version | cut -d: -f2)
			echo "Removing previously installed$VERSION_INSTALLED version."
			if sudo rpm -e ems-bus > /dev/null ; then
				echo "Installing $SETUP_PACKAGE..."
				if sudo rpm -ihv $SETUP_PACKAGE; then
					echo "Installation done successfully!!!"
				else
					echo "Installation was unsuccessful."
				fi
			else
				echo "It was not possible remove previously installed$VERSION_INSTALLED version."
			fi
		fi


	elif [ "$LINUX_DISTRO" = "ubuntu" ]; then
		# ***** Erlang Runtime Library **********

		# erlang-solutions is a rpm package for Erlang repository
		if ! dpkg -s erlang-solutions > /dev/null ; then
			echo "Adding Erlang repository entry."
			wget -nv https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb

			# Check internet connectivity
			if [ "$?" -eq "4" ]; then
				echo "Make sure your DNS is well configured or if there is Internet on this host. Canceling installation..."
				exit 1
			fi

			sudo dpkg -i erlang-solutions_1.0_all.deb
			UPDATE_NECESSARY="true"
		fi


		# update yum if necessary
		if [ "$UPDATE_NECESSARY" = "true" ]; then
			echo "apt update..."
			sudo apt-get -y update
		fi


		# Check if Erlang runtime already exist
		if ! erl -version 2> /dev/null;  then
			echo "Installing Erlang Runtime Library packages..."
			sudo sudo apt-get install erlang
		else
			echo "Skipping Erlang Runtime Library installation because it is already installed."
		fi


		# **** Install required packages ****
		
		REQUIRED_PCK="libiodbc2 unixodbc tdsodbc:amd64 odbcinst1debian2:amd64 odbcinst libsqliteodbc:amd64 libsqliteodbc libodbc1 libsqlite0 freetds-common ldap-utils"
		INSTALL_REQUIRED_PCK="false"
		for PCK in $REQUIRED_PCK; do 
			if ! dpkg -s $PCK > /dev/null 2>&1 ; then
				INSTALL_REQUIRED_PCK="true"
				break
			fi
		done
		if [ "$INSTALL_REQUIRED_PCK" = "true" ]; then
			echo "Installing required packages $REQUIRED_PCK..."
			sudo apt-get -y install $REQUIRED_PCK
		else
			echo "Skipping required packages installation because it is already installed."
		fi


		# ***** Install or update ems-bus *****
		
		if ! dpkg -s ems-bus > /dev/null 2>&1 ; then
			echo "Installing $SETUP_PACKAGE..."
			sudo dpkg -i $SETUP_PACKAGE
		else
			sudo systemctl stop ems-bus > /dev/null 2>&1
			VERSION_INSTALLED=$(dpkg -s ems-bus | grep Version | cut -d: -f2)
			echo "Removing previously installed$VERSION_INSTALLED version."
			if sudo apt-get -y remove ems-bus > /dev/null; then
				echo "Installing $SETUP_PACKAGE..."
				if sudo dpkg -i $SETUP_PACKAGE; then
					echo "Installation done successfully!!!"
				else 
					echo "Installation was unsuccessful."
				fi
			else
				echo "It was not possible remove previously installed$VERSION_INSTALLED version."
			fi
		fi

	elif [ "$LINUX_DISTRO" = "debian" ]; then

		# ***** Erlang Runtime Library **********

		# erlang-solutions is a rpm package for Erlang repository
		if ! dpkg -s erlang-solutions > /dev/null ; then
			echo "Adding Erlang repository entry."
			wget -nv https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb

			# Check internet connectivity
			if [ "$?" -eq "4" ]; then
				echo "Make sure your DNS is well configured or if there is Internet on this host. Canceling installation..."
				exit 1
			fi

			sudo dpkg -i erlang-solutions_1.0_all.deb
			UPDATE_NECESSARY="true"
		fi


		# update yum if necessary
		if [ "$UPDATE_NECESSARY" = "true" ]; then
			echo "apt update..."
			sudo apt-get -y update
		fi

		# Check if Erlang runtime already exist
		if ! erl -version 2> /dev/null;  then
			echo "Installing Erlang Runtime Library packages..."
			sudo sudo apt-get install erlang
		else
			echo "Skipping Erlang Runtime Library installation because it is already installed."
		fi


		# **** Install required packages ****
		
		REQUIRED_PCK="unixodbc tdsodbc freetds-common odbcinst1debian2 odbcinst libcppdb-sqlite3-0 libodbc1 libiodbc2 libcppdb-odbc0 libltdl7 libcppdb0 ldap-utils"
		INSTALL_REQUIRED_PCK="false"
		for PCK in $REQUIRED_PCK; do 
			if ! dpkg -s $PCK > /dev/null 2>&1 ; then
				INSTALL_REQUIRED_PCK="true"
				break
			fi
		done
		if [ "$INSTALL_REQUIRED_PCK" == "true" ]; then
			echo "Installing required packages $REQUIRED_PCK..."
			sudo apt-get -y install $REQUIRED_PCK
		else
			echo "Skipping required packages installation because it is already installed."
		fi


		# ***** Install or update ems-bus *****
		
		if ! dpkg -s ems-bus >> /dev/null ; then
			echo "Installing $SETUP_PACKAGE..."
			sudo dpkg -i $SETUP_PACKAGE
		else
			sudo systemctl stop ems-bus > /dev/null 2>&1
			VERSION_INSTALLED=$(dpkg -s ems-bus | grep Version | cut -d: -f2)
			echo "Removing previously installed$VERSION_INSTALLED version."
			if sudo apt-get -y remove ems-bus > /dev/null; then
				echo "Installing $SETUP_PACKAGE..."
				if sudo dpkg -i $SETUP_PACKAGE; then
					echo "Installation done successfully!!!"
				else 
					echo "Installation was unsuccessful."
				fi
			else
				echo "It was not possible remove previously installed$VERSION_INSTALLED version."
			fi
		fi

	fi	
}


# check send email
check_send_email(){
	# Ask if you want to send log by email
	while [[ ! $ENVIA_LOG_EMAIL =~ [YyNn] ]]; do
		printf "You want to send the installation log via email? [Yn]"
		read ENVIA_LOG_EMAIL
	done

	echo ""

	# send log by e-mail
	if [[ $ENVIA_LOG_EMAIL =~ [Yy] ]]; then
		EMAIL_OK="false"
		until [ $EMAIL_OK = "true" ]; do
			printf "Enter your e-mail: "
			read SMTP_DE
			if [[ $SMTP_DE =~ $SMTP_RE_CHECK ]]; then
				EMAIL_OK="true"
			else
				echo "E-mail $SMTP_DE is invalid"
			fi
		done
		SMTP_PARA=$SMTP_DE
		printf "Enter your password: "
		read -s SMTP_PASSWD
		echo ""
		echo "Send email, please wait..."
		TextLog=$(cat $LOG_FILE)
		send_email "ERLANGMS installation log on server $LINUX_DESCRIPTION << IP $LINUX_IP_SERVER >>" "$TextLog" && echo "Log sent by email to $SMTP_PARA."
	fi
}


install
check_send_email
cd $CURRENT_DIR
rm -rf $TMP_DIR


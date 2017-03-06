Installation instructions
=====

To install the ems-bus in the Debian, Ubuntu or CentOS, follow the instructions below:


##1) Download installer setup-emsbus-linux.x86_64.sh

##2) Run the installer as root or with the sudo command

```console
$ sudo ./setup-emsbus-linux.x86_64.sh
Preparing for installation, please wait...
Downloading https://github.com/erlangms/releases/raw/master/1.0.12/ems-bus-1.0.12-centos.7.x86_64.rpm...
Starting the ERLANGMS installation on CentOS Linux 7 (Core)
Purpose: A service-oriented bus developed in Erlang/OTP by Everton de Vargas Agilar
Version: ems-bus-1.0.12-centos.7.x86_64
Log file: setup_emsbus__06032017_084841.log
Host ip: 164.41.103.35
Date: 06/03/2017 08:48:45
=============================================================================
Skipping EPEL 7 repository installation because it is already installed.
Skipping Erlang Runtime Library installation because it is already installed.
Skipping python34 installation because it is already installed.
Skipping openldap installation because it is already installed.
Skipping openldap-clients installation because it is already installed.
Skipping driver SQL-Server freetds installation because it is already installed.
Removing previously installed 1.0.12 version.
Installing ems-bus-1.0.12-centos.7.x86_64.rpm...
Preparing...                          ########################################
Updating / installing...
ems-bus-1.0.12-centos.7               ########################################
Installation was unsuccessful.
You want to send the installation log via email? [Yn]n
```

##3) If everything is ok, go to http://localhost:2301/ on your browser.
=====

*{"message": "It works!!!"}*



Installation instructions
=====

Erlangms is a platform developed in *Erlang/OTP* to facilitate the integration of systems through a service-oriented approach for the systems of the University of Brazilia. This work is the result of efforts made in the Master of Applied Computing at the University of Brasilia by graduate student *Everton Vargas Agilar*. 

To install the Erlangms ems-bus in the Debian or Ubuntu distros, follow the instructions below:



##1) Installing required packages for ODBC Debian Jessie

```console
sudo apt-get install unixodbc tdsodbc freetds-common odbcinst1debian2 odbcinst libcppdb-sqlite3-0 libodbc1 libiodbc2 libcppdb-odbc0 libltdl7 libcppdb0
```

##2) Installing necessary packages for ODBC Ubuntu Xenial or yakkety

```console
sudo apt-get install unixodbc tdsodbc:amd64 odbcinst1debian2:amd64 odbcinst libsqliteodbc:amd64 libsqliteodbc libodbc1 libsqlite0 freetds-common
```

##3) Installing Debian ou Ubuntu ems-bus deb package

```console
sudo dpkg -i ems-bus_1.0.7-Ubuntu-yakkety_amd64
```



Running ems-bus
=====

If everything is OK, go to http://localhost:2301/ on your browser.

*{"message": "It works!!!"}*



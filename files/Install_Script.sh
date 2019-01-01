#!/bin/bash
# Copyright (c) 2018 fithwum
# All rights reserved

# Teamspeak server version check.
TS_VERSION="3.5.1"
CHANGELOG=/ts3server/CHANGELOG_${TS_VERSION}
CHANGELOG_OLD=find ../ts3server -type f -iname "CHANGELOG*"
CHANGELOG_NEW=CHANGELOG_${TS_VERSION}
VERSION_CHECK="${CHANGELOG_OLD}"

# Main Install.
if [ "${VERSION_CHECK}" == "${CHANGELOG_NEW}" ]
	then
		echo "INFO ! ts3server ${TS_VERSION} files found ... running current docker."
		exec /ts3server/ts3server_minimal_runscript.sh inifile=ts3server.ini start
		exit
	else
		echo "WARNING ! ts3server ${TS_VERSION} files not found, checking and installing new files as needed."

# Download & unpack teamspeak3 files & move into /ts3server.
	if [ -e "${CHANGELOG}" ]
		then
			echo "INFO ! ts3server is ${TS_VERSION} ... checking ini/sh files before running current docker."
		else
			echo "WARNING ! ts3server is out of date ... will download new copy from teamspeak."
				rm -frv /ts3server/CHANGELOG*
				wget https://files.teamspeak-services.com/releases/server/${TS_VERSION}/teamspeak3-server_linux_alpine-${TS_VERSION}.tar.bz2 -O /ts3temp/ts3server_${TS_VERSION}.tar.bz2
				sleep 2
				tar -xf /ts3temp/ts3server_${TS_VERSION}.tar.bz2 -C /ts3temp/serverfiles --strip-components=1
				sleep 2
				rm -frv /ts3temp/serverfiles/ts3server_startscript.sh
				rm -frv /ts3temp/ts3server_${TS_VERSION}.tar.bz2
				cp -uR /ts3temp/serverfiles/. /ts3server/
				sleep 2
				mv /ts3server/redist/libmariadb.so.2 /ts3server/libmariadb.so.2
				mv /ts3server/CHANGELOG ${CHANGELOG}
				rm -fr /ts3temp/serverfiles/*
	fi

# Check if the ini/sh files exist in /ts3server and copy if needed.
	if [ -e /ts3server/ts3server_minimal_runscript.sh ]
		then
			echo "INFO ! ts3server_minimal_runscript.sh found ... will not download."
		else
			echo "WARNING ! ts3server_minimal_runscript.sh not found ... will download new copy."
				wget https://raw.githubusercontent.com/fithwum/files-for-dockers/master/scripts/ts3server_minimal_runscript.sh -O /ts3temp/inifiles/ts3server_minimal_runscript.sh
				cp /ts3temp/inifiles/ts3server_minimal_runscript.sh /ts3server/
				rm -frv /ts3temp/ts3server_minimal_runscript.sh
	fi
	if [ -e /ts3server/ts3db_mariadb.ini ]
		then
			echo "INFO ! ts3db_mariadb.ini found ... will not download."
		else
			echo "WARNING ! ts3db_mariadb.ini not found ... will download new copy."
				wget https://raw.githubusercontent.com/fithwum/files-for-dockers/master/files/ts3db_mariadb.ini -O /ts3temp/inifiles/ts3db_mariadb.ini
				cp /ts3temp/inifiles/ts3db_mariadb.ini /ts3server/
				rm -frv /ts3temp/inifiles/ts3db_mariadb.ini
	fi
	if [ -e /ts3server/ts3server.ini ]
		then
			echo "INFO ! ts3server.ini found ... will not download."
		else
			echo "WARNING ! ts3server.ini not found ... will download new copy."
				wget https://raw.githubusercontent.com/fithwum/files-for-dockers/master/files/ts3server.ini -O /ts3temp/inifiles/ts3server.ini
				cp /ts3temp/inifiles/ts3server.ini /ts3server/
				rm -frv /ts3temp/inifiles/ts3server.ini
	fi

	sleep 1

# set permissions.
	chown 99:100 -R /ts3server
	chmod 777 -R /ts3server
	chmod +x -v /ts3server/ts3server_startscript.sh
	chmod +x -v /ts3server/ts3server
	sleep 1

# run the server.
	echo "INFO ! Starting ts3server ${TS_VERSION} ..."
	exec /ts3server/ts3server_minimal_runscript.sh inifile=ts3server.ini start
fi
exit

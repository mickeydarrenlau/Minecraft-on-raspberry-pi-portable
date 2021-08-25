#! /bin/sh

MC_SERVER_LOCATION=/srv/minecraft-server
GIT_REPO_LOCATION=$(pwd)
BUILD_LOCATION=$GIT_REPO_LOCATION/../mc-build


echo "$(tput setaf 1)*****************************************$(tput setaf sgr0)"
echo "This will configure your minecraft server"
echo "It assumes you have followed the directions" 
echo "and put your server directory at: \n\n$MC_SERVER_LOCATION"
echo "$(tput setaf 1)*****************************************$(tput setaf sgr0)"

echo "\nYou need to be running as root. Testing..."

if [ `id -u` = 0 ] ; then

	echo "$(tput setaf 3)Starting configuration$(tput sgr0)"

	if [ ! -d "$MC_SERVER_LOCATION" ]; then
		mkdir $MC_SERVER_LOCATION
	fi
	cd $MC_SERVER_LOCATION

	echo "$(tput setaf 5)Setting up Mojang EULA licence agreement$(tput sgr0)"
	echo "#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://account.mojang.com/documents/minecraft_eula).\n#Tue Mar 10 19:22:11 AEST 2015\neula=true" > eula.txt

	sleep 5

	echo "$(tput setaf 5)Copying server Jar files$(tput sgr0)"
	cp $BUILD_LOCATION/server.jar .
	sleep 3

	echo "$(tput setaf 5)Copying server config files$(tput sgr0)"
	cp $GIT_REPO_LOCATION/server.properties .
	cp $GIT_REPO_LOCATION/bukkit.yml .
	cp $GIT_REPO_LOCATION/start.sh .
	chmod a+x start.sh
	
	sleep 5

	echo "$(tput setaf 3)Getting plugins for bukkit$(tput sgr0)"
	PLUGINS_DIR=plugins
	if [ ! -d "$PLUGINS_DIR" ]; then
		mkdir $PLUGINS_DIR
	fi
	
	cd $PLUGINS_DIR
	if [ ! -f raspberryjuice-1.6.jar ]; then
		echo "$(tput setaf 5)Getting Raspberry Juice$(tput sgr0)"
		wget http://dev.bukkit.org/media/files/853/920/raspberryjuice-1.6.jar
	fi
	if [ ! -f pTweaks.jar ]; then
		echo "$(tput setaf 5)Getting pTweaks$(tput sgr0)"
		wget http://dev.bukkit.org/media/files/836/516/pTweaks.jar
	fi

	cd ..

	sleep 5

	echo "$(tput setaf 3)Configuring minecraft user$(tput sgr0)"
	adduser --system --no-create-home --home $MC_SERVER_LOCATION minecraft
	addgroup --system minecraft
	adduser minecraft minecraft # this adds user "minecraft" the group "minecraft"

	echo "$(tput setaf 5)Setting file permissions$(tput sgr0)"
	chown -R minecraft:minecraft $MC_SERVER_LOCATION

	sleep 5
	echo "$(tput setaf 3)Configuring init$(tput sgr0)"
	cp $GIT_REPO_LOCATION/minecraft-server /etc/init.d/
	chmod +x /etc/init.d/minecraft-server

	sleep 5
	echo "$(tput setaf 3)Configuring runlevels$(tput sgr0)"
	update-rc.d minecraft-server defaults
	


	echo "$(tput setaf 3)***********************************************$(tput sgr0)"
	echo "$(tput setaf 3)Configuration is now complete. You can run minecraft using:\n$(tput sgr0)"
	echo "sudo service minecraft-server start\n\n"
	echo "$(tput setaf 3)***********************************************$(tput sgr0)"

else 
	echo "$(tput setaf 1)Run as the root user$(tput sgr0) aborting"
	exit 1
fi


exit 0

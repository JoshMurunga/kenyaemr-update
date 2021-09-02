#!/bin/bash
# Script to autoupdate kenyaemr to the latest version

modules_dir=/var/lib/OpenMRS/modules
warfile_dir=/opt/tomcat/webapps
DATE=$(date +"%F")
TIME=$(date +"%H-%M")

MYSQL_USER="root"
MYSQL_PASSWORD="Admin123"

echo "setting up KenyaEMR auto-update rollback mechanism"

echo "Creating new directory"

if [ -d "/opt/KenyaEMRAutoupdate/rollback/webapp" ] 
then 
sudo rm -R "/opt/KenyaEMRAutoupdate/rollback/webapp"
fi

if [ -d "/opt/KenyaEMRAutoupdate/rollback/modules" ] 
then 
sudo rm -R "/opt/KenyaEMRAutoupdate/rollback/modules"
fi

if [ -d "/opt/KenyaEMRAutoupdate/rollback/db" ] 
then 
sudo rm -R "/opt/KenyaEMRAutoupdate/rollback/db"
fi

if [ -d "/home/vagrant/latest" ] 
then 
sudo rm -R "/home/vagrant/latest"
fi

if [ -f "/home/vagrant/latest.zip" ] 
then 
sudo rm -rf "/home/vagrant/latest.zip"
fi

sudo mkdir -p "/opt/KenyaEMRAutoupdate/rollback/webapp"
sudo mkdir -p "/opt/KenyaEMRAutoupdate/rollback/modules"
sudo mkdir -p "/opt/KenyaEMRAutoupdate/rollback/db"

sudo chmod -R 755 /opt/KenyaEMRAutoupdate/rollback
sudo chown -R $USER:$USER /opt/KenyaEMRAutoupdate/rollback/

echo "Backup currently running system"
sudo cp ${modules_dir}/*.omod /opt/KenyaEMRAutoupdate/rollback/modules
sudo cp ${warfile_dir}/openmrs.war /opt/KenyaEMRAutoupdate/rollback/webapp

echo "Creating db backup"
mysqldump --user=$MYSQL_USER --password=$MYSQL_PASSWORD openmrs | gzip > /opt/KenyaEMRAutoupdate/rollback/db/openmrs.$DATE.$TIME.sql.gz

echo "completed setup of auto-update rollback mechanism"
echo
echo

wget -P /home/vagrant/ https://github.com/JoshMurunga/kenyaemr-update/releases/download/v1/latest.zip

echo "download complete"
echo
echo

unzip /home/vagrant/latest.zip -d /home/vagrant/latest

echo "extraction complete"
echo
echo

if [ -d "/home/vagrant/latest/17.3.3/" ] 
then 
echo "Upgrading to 17.3.3"
sudo bash /home/vagrant/latest/17.3.3/setup_script.sh

echo "Please wait for KenyaEMR 17.3.3 to start and enter the MFL code in order to continue"
echo
echo

read -p "Press enter if you have entered the MFL to run post installation"

sudo bash /home/vagrant/latest/17.3.3/post_upgrade_script.sh

fi

echo "Upgrading to The Latest KenyaEMR"
sudo bash /home/vagrant/latest/latest/setup_script.sh

if [ -f "/home/vagrant/latest/latest/post_upgrade_script.sh" ] 
then
echo

read -p "Press enter if you have entered the MFL to run post installation"

sudo bash /home/vagrant/latest/latest/post_upgrade_script.sh

fi

echo
echo "Upgrade complete"
echo
echo


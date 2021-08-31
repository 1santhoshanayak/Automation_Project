#!/bin/bash
timestamp=$(date '+%d%m%Y-%H%M%S')
s3_bucket=upgrad-santhosha
myname=santhosha

#update sources
apt-get update -qq > /dev/null

declare -a pkgname
pkgname=("apache2" "awscli")

#install required packages
package_install_check(){
  package_check=`apt-cache policy $package | grep "Installed:" | awk '{ print $2 }'`

  if [ $package_check == "(none)" ]
then
        apt-get install $package -y -qq > /dev/null
fi
}

for package in ${pkgname[*]}
do
        package_install_check $package
done

#chcek apache enabled or not
apache_check=`systemctl is-enabled apache2`

if [ $apache_check == "disabled" ]
then
        systemctl enable apache2.service
fi

#check apache running status
if ! pgrep -x "apache2" >/dev/null
then
    systemctl start apache2
fi

#create tar file on /tmp
cd /var/log/apache2 && tar -cf /tmp/$myname-httpd-logs-$timestamp.tar *.log

#upload tar file to s3 bucket on creation of tar
if [ $? == 0 ]
then
        aws s3 cp /tmp/$myname-httpd-logs-$timestamp.tar s3://$s3_bucket/$myname-httpd-logs-$timestamp.tar
fi

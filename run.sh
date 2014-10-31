#!/bin/bash

if [[ -n $INSTALL_MYSQL && -n $MYSQL_PASSWORD && -n $MYSQL_USERNAME ]]; then
  echo "Installing MySQL Server with given credentials"
  export DEBIAN_FRONTEND=noninteractive
  apt-get update && apt-get -yq install mysql-server
  service mysql restart
  mysql -uroot -e "CREATE USER '${MYSQL_USERNAME}'@'%' IDENTIFIED BY '$MYSQL_PASSWORD'"
  mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_USERNAME}'@'%' WITH GRANT OPTION"
  service mysql restart
fi

if [ -z $ZS_ADMIN_PASSWORD ]; then
    ZS_ADMIN_PASSWORD=`date +%s | sha256sum | base64 | head -c 8`
    echo $ZS_ADMIN_PASSWORD > /root/zend-password
fi
ZS_MANAGE=/usr/local/zend/bin/zs-manage
HOSTNAME=`hostname`
APP_UNIQUE_NAME=$HOSTNAME
APP_IP=`/sbin/ifconfig eth0| grep 'inet addr:' | awk {'print $2'}| cut -d ':' -f 2`

service zend-server start
WEB_API_KEY=`cut -s -f 1 /root/api_key 2> /dev/null`
WEB_API_KEY_HASH=`cut -s -f 2 /root/api_key 2> /dev/null`
if [ -z $WEB_API_KEY ]; then
  echo "Bootstrapping single server"
  if [[ -z $ZEND_LICENSE_ORDER || -z $ZEND_LICENSE_KEY ]]; then
    $ZS_MANAGE bootstrap-single-server -p $ZS_ADMIN_PASSWORD -a 'TRUE' -r FALSE -t 3 -w 5 | head -1 > /root/api_key
  else
    $ZS_MANAGE bootstrap-single-server -p $ZS_ADMIN_PASSWORD -a 'TRUE' -r FALSE -t 3 -w 5 -o $ZEND_LICENSE_ORDER -l $ZEND_LICENSE_KEY | head -1 > /root/api_key
  fi

  WEB_API_KEY=`cut -s -f 1 /root/api_key`
  WEB_API_KEY_HASH=`cut -s -f 2 /root/api_key`
fi

if [[ -n $MYSQL_HOSTNAME && -n $MYSQL_PORT && -n $MYSQL_USERNAME && -n $MYSQL_PASSWORD && -n $MYSQL_DBNAME ]]; then
  echo "Joining cluster"
  $ZS_MANAGE server-add-to-cluster -T 120 -n $APP_UNIQUE_NAME -i $APP_IP -o $MYSQL_HOSTNAME:$MYSQL_PORT -u $MYSQL_USERNAME -p $MYSQL_PASSWORD -d $MYSQL_DBNAME -N $WEB_API_KEY -K $WEB_API_KEY_HASH -s| sed -e 's/ //g' > /root/zend_cluster.sh
  echo "MYSQL_HOSTNAME=$MYSQL_HOSTNAME
  MYSQL_PORT=$MYSQL_PORT
  MYSQL_USERNAME=$MYSQL_USERNAME
  MYSQL_PASSWORD=$MYSQL_PASSWORD
  MYSQL_DBNAME=$MYSQL_DBNAME" >> /root/zend_cluster.sh

  eval `cat /root/zend_cluster.sh`
  $ZS_MANAGE store-directive -d 'session.save_handler' -v 'cluster' -N $WEB_API_KEY -K $WEB_API_KEY_HASH
fi

echo "
restarting Zend Server"
amount_servers=`$ZS_MANAGE restart-php -p -N $WEB_API_KEY -K $WEB_API_KEY_HASH | wc -l` 

echo "********************************************

Zend Server is ready for use
Your application is available at http://$APP_IP
To access Zend Server, navigate to http://$APP_IP:10081"

if [ "$amount_servers" -gt "1" ]; then
    echo "This is a clustered environment. Please use 
the admin password of the first node to 
login to the Zend Server GUI."

else
  echo "Your admin password is $ZS_ADMIN_PASSWORD" 
fi

echo "
********************************************"

exec supervisord -n > /dev/null 2>/dev/null

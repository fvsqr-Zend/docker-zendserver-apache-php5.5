Zend Server 8.0 Beta in Docker
================================

Build your own bootstrapped Docker container for Zend Server with Apache and PHP 5.5.

To build run:
```
docker build -t zend-server:8.0Beta-php5.5 .
```
from within the cloned directory (please note the trailing dot).

To run:
```
docker run -d -P zend-server:8.0Beta-php5.5
```
This starts the container in a daemonized mode, that means that the container is still available after closing the terminal window.

Docker esposes port 80 and 443 for http(s) and port 10081 and 10082 for Zend Server GUI (http/https). With the flag '-P' Docker maps these container ports to free ports between 49153 to 65535, so that you can access Zend Server and apps by using your host computers IP. 

You can also map manually, for example
```
docker run -d -p 88:80 -p 10088:10081 zend-server:8.0Beta-php5.5
```
This command redirects port 80 to port 88, and port 10081 (Zend Server UI port) to port 10088.

Internal / Development mode
---------------------------
If there's no need to expose ports at all, beacuse all you need is an internal dev system which is only available on your personal host, you can also start a container like this:
```
docker run -d zend-server:8.0Beta-php5.5
```
or
```
docker run zend-server:8.0Beta-php5.5
```
You can access the App and Zend Server UI via the default ports 80, 443, 10081, 10082, but now you have to use the IP address of the container. You can find it in the result of
```
docker inspect <container-id>
```

Open Zend Server GUI
-----
If you're using "-P" flag, you can check the App and Zend Server ports with
```
docker ps
```
Otherwise you should know which ports you have set yourself ;)

Then open your browser at
```
http://localhost:PORT_MAP_10081
```
or
```
https://localhost:PORT_MAP_10082
```
There is also some output from Zend Server after bootstrapping - for example the password for the UI. If you're not running in damonized mode, you'll get the output directly in the terminal. Otherwise you have to execute:
```
docker logs <container-id>
```
Please note that it can take some time to bootstrap and configure Zend Server - so please be patient and repeat the command if you don't get the Zend Server URL and password immediately.

MySQL
-----
If you'd like to have the docker container with a preinstalled MySQL database, you can run the container with some additional environment variables:
```
docker run -e INSTALL_MYSQL=true -e MYSQL_PASSWORD=<password> -e MYSQL_USERNAME=<username> zend-server:8.0Beta-php5.5
```
The DB is being installed on the fly - this is probably not the "Docker way" to go (because you should run a MySQL container and link it to the App Server container), but it can be very convenient...

Cluster
-------
To start a Zend Server cluster, execute the following command for each cluster node:
```
docker run -e MYSQL_HOSTNAME=<db-ip> -e MYSQL_PORT=3306 -e MYSQL_USERNAME=<username> -e MYSQL_PASSWORD=<password> -e MYSQL_DBNAME=zendserver zend-server:8.0Beta-php5.5
```
As you can see, a MySQL DB is mandatory for Zend Server cluster. An easy way to get one in Docker is to follow the instructions from https://github.com/tutumcloud/tutum-docker-mysql

By calling the command above with the flag "-d" multiple times in a row, you'll set up a cluster within seconds. As written above, the bootstrapping process can tike some time, so that the complete cluster is up and running within a few minutes.

Please note that you can access the GUI from all nodes, but the password is only created for node #1. So please consider checking the docker log for the first container to get the appropriate Zend Server URL and password. Probably the first node is also the node which is ready the first. So you can log in and see the other nodes joining.

Another note: One Zend Server instance a.k.a. Zend Server Container is consuming round about 500M of memory, so please chose the number of nodes to be started wisely...

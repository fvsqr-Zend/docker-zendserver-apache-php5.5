Zend Server 7.1 EA in Docker
================================

This is everything needed to build an un-bootstrapped Docker container for Zend Server.

To build run:
```
docker build -t <YOUR_DOCKER_USER>/zend-server:7.1EA .
```
from within the cloned directory.

To run:
```
docker run -d -P <YOUR_DOCKER_USER>/zend-server:7.1EA
```
or specify mappings manually.

Open Zend Server GUI
-----
Check with 
```
docker ps
```
the port mappings to port 10081 or 10082. Then open your browser at
```
http://localhost:PORT_MAP_10081
```
or
```
https://localhost:PORT_MAP_10082
```
Enjoy!

#
# Zend Server 8.0
#

FROM ubuntu:trusty
MAINTAINER Jan Burkl <jan@zend.com>

ADD run.sh /run.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD ZendServer-RepositoryInstaller-linux /ZendServer-RepositoryInstaller-linux

RUN chmod 775 /*.sh
RUN chmod 775 /ZendServer-RepositoryInstaller-linux/*.sh
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor wget && wget http://repos.zend.com/zend.key -O- |apt-key add -
RUN /ZendServer-RepositoryInstaller-linux/install_zs.sh 5.5 --automatic
RUN /usr/local/zend/bin/zendctl.sh stop

ADD zend.conf /etc/supervisor/conf.d/zend.conf

EXPOSE 80
EXPOSE 443
EXPOSE 10081
EXPOSE 10082

CMD ["/run.sh"]

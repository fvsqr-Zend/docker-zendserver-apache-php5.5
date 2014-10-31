#
# Zend Server 8.0 Beta
#

FROM ubuntu:trusty
MAINTAINER Jan Burkl <jan@zend.com>

ADD run.sh /run.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD repo_installer_early_access /repo_installer_early_access

RUN chmod 775 /*.sh
RUN chmod 775 /repo_installer_early_access/*.sh
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor wget && wget http://repos.zend.com/zend.key -O- |apt-key add -
RUN /repo_installer_early_access/install_zs.sh 5.5 --automatic
RUN /usr/local/zend/bin/zendctl.sh stop

ADD zend.conf /etc/supervisor/conf.d/zend.conf

EXPOSE 80
EXPOSE 443
EXPOSE 10081
EXPOSE 10082

CMD ["/run.sh"]

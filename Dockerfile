# Zend Server
#
# Version 0.1

# TODO:
# - version as a variable (both php and ZS)

FROM ubuntu:trusty

# ADD add-repo.sh /add-repo.sh
ADD start.sh /start.sh
ADD run.sh /run.sh
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
EXPOSE 10060
EXPOSE 10061
EXPOSE 10062

CMD ["/run.sh"]

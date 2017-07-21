# This Dockerfile uses the Centos image
# Version： 02
# Author： kbsonlong
# Soft_Version： nginx-1.12.1  php-7.1.7
FROM centos
RUN mkdir /server/ -p
ADD NP.tar.gz /server/
RUN yum install python-setuptools -y && easy_install  pip && pip install supervisor  -i http://mirrors.aliyun.com/pypi/simple  --trusted-host mirrors.aliyun.com
RUN cd /server/lnmp && bash install.sh lnmp
COPY supervisord.conf /etc/supervisord.conf
RUN yum install -y -q openssh-server net-tools
RUN ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N '' 
RUN ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' 
RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_ed25519_key  -N ''  
RUN sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config 
RUN sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config  
RUN echo 'root:along.party' |chpasswd 
RUN echo -e "\n[program:sshd]\ncommand=/usr/sbin/sshd -D" >>/etc/supervisord.conf
RUN /usr/local/nginx/sbin/nginx
CMD ["supervisord", "-c", "/etc/supervisord.conf", "-n"]
EXPOSE 80 22
ONBUILD ADD project.tar.gz  /home/
ONBUILD CMD ["supervisord", "-c", "/etc/supervisord.conf", "-n"]
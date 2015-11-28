FROM centos
MAINTAINER kur_neko
RUN yum install openssl openssl-devel httpd python python-devel -y

ADD push_apns.py ./
ADD run.sh ./
RUN chmod 777 ./run.sh
CMD ["./run.sh"]


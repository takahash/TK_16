FROM centos
MAINTAINER kurneko

RUN yum install python python-devel python-pip gcc gcc-devel libffi-devel openssl openssl-devel -y
ADD get-pip.py ./
RUN python get-pip.py
RUN pip install pyapns service_identity supervisor 
ADD start_twisted.sh ./
ADD supervisord.conf /etc/supervisord.conf

EXPORE 80
CMD ["supervisord"]

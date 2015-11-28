FROM centos
MAINTAINER kurneko

RUN yum install python python-devel python-pip gcc gcc-devel libffi-devel openssl openssl-devel -y
ADD get-pip.py ./
RUN python get-pip.py
ADD requirements.txt ./
RUN pip install -r requirements.txt 
ADD supervisord.conf /etc/supervisord.conf
RUN mkdir ippuq
WORKDIR ippuq
RUN mkdir templates
ADD ippuq_api.py ./
ADD templates/test.html ./templates/test.html

EXPOSE 80
CMD ["supervisord"]

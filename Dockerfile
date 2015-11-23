FROM keboola/base
MAINTAINER Ondrej Popelka <ondrej.popelka@keboola.com>

RUN yum -y update && \
	yum -y install \
		gcc \
		make \
		openssl-devel \
		&& \
	yum clean all

# the instructions below are taken from https://github.com/docker-library/python/blob/e4a0ed26c086a48a75e9ea2b163c8262dcdff2af/3.5/Dockerfile
# except that we use keboola/base as the base package

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

# gpg: key F73C700D: public key "Larry Hastings <larry@hastings.org>" imported
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 97FC712E4C024BBEA48A61ED3A5CA953F73C700D

ENV PYTHON_VERSION 3.5.0

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 7.1.2

RUN set -x \
	&& mkdir -p /usr/src/python \
	&& curl -SL "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" -o python.tar.xz \
	&& curl -SL "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" -o python.tar.xz.asc \
	&& gpg --verify python.tar.xz.asc \
	&& tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
	&& rm python.tar.xz* \
	&& cd /usr/src/python \
	&& ./configure --enable-shared --enable-unicode=ucs4 \
	&& make -j$(nproc) \
	&& make install \
	&& echo /usr/local/lib >> /etc/ld.so.conf \
	&& ldconfig \
	&& pip3 install --no-cache-dir --upgrade --ignore-installed pip==$PYTHON_PIP_VERSION \
	&& find /usr/local \
		\( -type d -a -name test -o -name tests \) \
		-o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
		-exec rm -rf '{}' + \
	&& rm -rf /usr/src/python

# make some useful symlinks that are expected to exist
RUN cd /usr/local/bin \
	&& ln -s easy_install-3.5 easy_install \
	&& ln -s idle3 idle \
	&& ln -s pydoc3 pydoc \
	&& ln -s python3 python \
	&& ln -s python-config3 python-config

# setup the environment
WORKDIR /tmp
#RUN yum -y install wget git tar
#RUN wget https://bootstrap.pypa.io/get-pip.py
#RUN python get-pip.py
#RUN pip install PyYaml
#RUN pip install -U pytest
#RUN pip install httplib2

# prepare the container

#WORKDIR /home
#RUN git clone https://github.com/keboola/tde-exporter.git ./
#RUN git checkout tags/2.1.5
#WORKDIR libs
#RUN tar xvzf TDE-API-Python-Linux-64Bit.gz
#WORKDIR DataExtract-8300.15.0308.1149
#RUN python setup.py build
#RUN python setup.py install

#prepare php stuff
#WORKDIR /home/php
#RUN composer install --no-interaction

#WORKDIR /home
#RUN PYTHONPATH=. py.test
#remove the tests results
#RUN rm -rf /tmp/pytest-of-root/
##ENTRYPOINT python -u ./src/main.py --data=/data
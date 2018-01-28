FROM nmrprocflow/nmrprocflow:v1.2.12

LABEL maintainer="PhenoMeNal"

ENV DEBIAN_FRONTEND=noninteractive \
    API_KEY=none \
    DEBUG=false \
    PROXY_PREFIX=none \
    GALAXY_URL=none \
    GALAXY_WEB_PORT=10000 \
    HISTORY_ID=none \
    REMOTE_HOST=none

RUN apt-get -qq update && \
    apt-get install --no-install-recommends -y \
    wget procps net-tools python-pip && \
    pip install --upgrade pip && pip install setuptools && \
    pip install bioblend==0.10 

# Our very important scripts. Make sure you've run `chmod +x startup.sh
# monitor_traffic.sh` outside of the container!
ADD ./startup.sh /startup.sh
ADD ./monitor_traffic.sh /monitor_traffic.sh
RUN chmod a+x /startup.sh && chmod a+x /monitor_traffic.sh

# /import will be the universal mount-point for IPython
# The Galaxy instance can copy in data that needs to be present to the
# container
RUN mkdir /import

# Apache conf
COPY ./apache.conf /apache.conf
VOLUME ["/import"]
WORKDIR /import/

COPY upload_file_to_history.py /usr/local/bin/upload_file_to_history.py
RUN chmod a+x /usr/local/bin/upload_file_to_history.py

# nv
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_SERVERADMIN admin@localhost
ENV APACHE_SERVERNAME localhost
ENV APACHE_SERVERALIAS docker.localhost
ENV APACHE_DOCUMENTROOT /var/www/html

RUN add-apt-repository ppa:ondrej/php && apt-get update
RUN apt-get install -y --no-install-recommends php5.6 libapache2-mod-php5.6 php5.6-mcrypt php5.6-iconv php5.6-gd
COPY dir.conf /etc/apache2/mods-enabled/dir.conf
RUN a2dismod php7.0 && a2enmod php5.6
RUN git clone --depth 1 --single-branch https://github.com/INRA/NMRProcFlow.git && \
    cp -r NMRProcFlow/nmrviewer/src/* /opt/ && \
    make -C /opt && \ 
    cp -r NMRProcFlow/nmrviewer/www /var/www/html/nv && rm -rf NMRProcFlow

RUN  mkdir -p /var/www/html/nv/tmp \
    && chown -R www-data.www-data /var/www/html/nv \
    && chmod 777 /var/www/html/nv/tmp \
    && mkdir -p /opt/data


# EXTREMELY IMPORTANT! You must expose a SINGLE port on your container.
EXPOSE 80
CMD /startup.sh

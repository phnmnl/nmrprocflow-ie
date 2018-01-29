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
    procps net-tools python-pip && \
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


# EXTREMELY IMPORTANT! You must expose a SINGLE port on your container.
EXPOSE 80
CMD /startup.sh

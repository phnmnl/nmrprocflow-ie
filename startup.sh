#!/bin/bash
# First, replace the PROXY_PREFIX value in /proxy.conf with the value from
# the environment variable.
sed -i "s|PROXY_PREFIX|${PROXY_PREFIX}|" /apache.conf;
# Then copy into the default location for ubuntu+nginx
cp /apache.conf /etc/apache2/apache2.conf;

sed -i "s|GALAXY_URL|${GALAXY_URL}|" /usr/local/bin/upload_file_to_history.py;
sed -i "s|API_KEY|${API_KEY}|" /usr/local/bin/upload_file_to_history.py;
sed -i "s|HISTORY_ID|${HISTORY_ID}|" /usr/local/bin/upload_file_to_history.py;

# Here you would normally start whatever service you want to start. In our
# example we start a simple directory listing service on port 8000

# Launch traffic monitor which will automatically kill the container if
# traffic stops
# /monitor_traffic.sh &
# And finally launch nginx in foreground mode. This will make debugging
# easier as logs will be available from `docker logs ...`
#nginx -g 'daemon off;'
/usr/bin/launch-server.sh

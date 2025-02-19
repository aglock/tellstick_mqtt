FROM golang:buster

# Add Telldus repository
RUN echo "deb-src http://download.telldus.com/debian/ unstable main" >> /etc/apt/sources.list.d/telldus.list
RUN curl -sSL http://download.telldus.com/debian/telldus-public.key | apt-key add -

# Install dependencies. Compile and install telldusd
RUN apt-get update
RUN apt-get install -y build-essential
RUN apt-get build-dep -y telldus-core
RUN apt-get install -y cmake libconfuse-dev libftdi-dev help2man
RUN apt-get --compile source telldus-core
RUN dpkg --install *.deb


# Install and configure Supervisor
RUN apt-get install -y supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy configuration
COPY telldusmq.json /etc/telldusmq/telldusmq.json
COPY tellstick.conf /etc/tellstick.conf

RUN go get github.com/aglock/tellstick_mqtt/telldusmq


ENTRYPOINT ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]

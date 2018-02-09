## -*- docker-image-name: "scaleway/torrents:latest" -*-
FROM scaleway/ubuntu:amd64-xenial
# following 'FROM' lines are used dynamically thanks do the image-builder
# which dynamically update the Dockerfile if needed.
#FROM scaleway/ubuntu:armhf-xenial       # arch=armv7l
#FROM scaleway/ubuntu:arm64-xenial       # arch=arm64
#FROM scaleway/ubuntu:i386-xenial        # arch=i386
#FROM scaleway/ubuntu:mips-xenial        # arch=mips


MAINTAINER Scaleway <opensource@scaleway.com> (@scaleway)


# Prepare rootfs for image-builder
RUN /usr/local/sbin/scw-builder-enter


# Enable multiverse packages
RUN sed -i 's/universe/universe multiverse/' /etc/apt/sources.list

# Install packages
RUN apt-get -q update                   \
 && apt-get --force-yes -y -qq upgrade  \
 && apt-get install -y -q               \
      deluged deluge-web                \
      nginx unzip                       \
      php7.0-cli php7.0-fpm             \
      geoip-database                    \
      vsftpd libpam-pwdfile             \
      apache2-utils                     \
 && apt-get clean


# Software versions
ENV H5AI_VERSION=0.29.0

# Install h5ai

RUN curl -L https://release.larsjung.de/h5ai/h5ai-$H5AI_VERSION.zip -o /tmp/h5ai.zip \
  && unzip /tmp/h5ai.zip -d /var/www/ \
  && rm -f /tmp/h5ai.zip \
  && ln -s /home/torrent/downloads /var/www/

# Configure nginx
RUN unlink /etc/nginx/sites-enabled/default

# Add symlink to downloads folder in /root
RUN ln -s /home/torrent/downloads /root/downloads

COPY ./overlay/ /

RUN adduser torrent --disabled-password --gecos ''  \
 && mkdir -p /home/torrent/downloads/public         \
 && mkdir -p /home/torrent/sessions                 \
 && mkdir -p /home/torrent/watch

# Clean rootfs from image-builder
RUN /usr/local/sbin/scw-builder-leave

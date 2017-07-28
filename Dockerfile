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
      rtorrent                          \
      nginx                             \
      php7.0-cli php7.0-fpm php-geoip   \
      mediainfo unzip unrar             \
      libav-tools                       \
      vsftpd libpam-pwdfile             \
      apache2-utils                     \
 && apt-get clean


# Software versions
ENV RUTORRENT_COMMIT=9191af0c0910143a1a0dd4968e64f1db63a2d746  \
    RUTORRENT_VERSION=3.8                                      \
    H5AI_VERSION=0.29.0


#
# Rtorrent configuration
#
RUN adduser rtorrent --disabled-password --gecos ''  \
 && mkdir -p /home/rtorrent/downloads/public         \
 && mkdir -p /home/rtorrent/sessions                 \
 && mkdir -p /home/rtorrent/watch                    \
 && chown -R rtorrent:rtorrent /home/rtorrent/

#
# ruTorrent configuration
#

# Extract ruTorrent, edit config and remove useless plugins
RUN mkdir -p /var/www/rutorrent/                                                      \
  && curl -sNL https://github.com/Novik/ruTorrent/archive/${RUTORRENT_COMMIT}.tar.gz  \
     | tar xzv --strip 1 -C /var/www/rutorrent/                                       \
  && mv /var/www/rutorrent/conf/config.php /var/www/rutorrent/conf/config_base.php    \
  && rm -fr /var/www/rutorrent/plugins/httprpc /var/www/rutorrent/plugins/rpc         \
  && mv /var/www/rutorrent/plugins/screenshots/conf.php                               \
        /var/www/rutorrent/plugins/screenshots/conf_base.php


# Install h5ai

RUN curl -L https://release.larsjung.de/h5ai/h5ai-$H5AI_VERSION.zip -o /tmp/h5ai.zip \
  && unzip /tmp/h5ai.zip -d /var/www/ \
  && rm -f /tmp/h5ai.zip \
  && ln -s /home/rtorrent/downloads /var/www/


# Configure nginx
RUN unlink /etc/nginx/sites-enabled/default

# Add symlink to downloads folder in /root
RUN ln -s /home/rtorrent/downloads /root/downloads

COPY ./overlay/ /

# Permissions
RUN chown -R www-data:www-data /var/www/

# Clean rootfs from image-builder
RUN /usr/local/sbin/scw-builder-leave

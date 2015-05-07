## -*- docker-image-name: "armbuild/scw-app-torrents:latest" -*-
FROM armbuild/scw-distrib-ubuntu:utopic
MAINTAINER Scaleway <opensource@scaleway.com> (@scaleway)


# Prepare rootfs for image-builder
RUN /usr/local/sbin/builder-enter


# Enable multiverse packages
RUN sed -i 's/universe/universe multiverse/' /etc/apt/sources.list


# Install packages
RUN apt-get -q update \
  && apt-get --force-yes -y -qq upgrade \
  && apt-get install -y \
    supervisor \
    rtorrent \
    nginx \
    php5-cli php5-fpm \
    mediainfo unzip unrar \
    libav-tools


#
# Rtorrent configuration
#
RUN adduser rtorrent --disabled-password --gecos '' \
  && mkdir -p /home/rtorrent/downloads \
  && mkdir -p /home/rtorrent/sessions \
  && mkdir -p /home/rtorrent/watch \
  && chown -R rtorrent:rtorrent /home/rtorrent/


COPY ./patches/home/rtorrent/dot.rtorrent.rc /home/rtorrent/.rtorrent.rc


# Supervisord configuration
COPY ./patches/etc/supervisor/conf.d/rtorrent.conf /etc/supervisor/conf.d/


#
# ruTorrent configuration
#


# Extract ruTorrent, edit config and remove useless plugins
RUN mkdir -p /var/www/rutorrent/ \
  && curl -sNL https://github.com/Novik/ruTorrent/archive/master.tar.gz | tar xzv --strip 1 -C /var/www/rutorrent/ \
  && mv /var/www/rutorrent/conf/config.php /var/www/rutorrent/conf/config_base.php \
  && rm -fr /var/www/rutorrent/plugins/httprpc /var/www/rutorrent/plugins/rpc \
  && mv /var/www/rutorrent/plugins/screenshots/conf.php /var/www/rutorrent/plugins/screenshots/conf_base.php


COPY ./patches/var/www/rutorrent/conf/config.php /var/www/rutorrent/conf/
COPY ./patches/var/www/rutorrent/plugins/screenshots/conf.php /var/www/rutorrent/plugins/screenshots/


# Configure nginx
RUN unlink /etc/nginx/sites-enabled/default
COPY ./patches/etc/nginx/sites-available/rutorrent /etc/nginx/sites-available/
RUN ln -s /etc/nginx/sites-available/rutorrent /etc/nginx/sites-enabled/


# Permissions
RUN chown -R www-data:www-data /var/www/


# Installer
COPY ./patches/var/www/installer.php /var/www/


# Update rtorrent configuration on boot
COPY ./patches/etc/init/update-rtorrent-ip.conf /etc/init/


# Add symlink to downloads folder in /root
RUN ln -s /home/rtorrent/downloads /root/downloads


# Clean rootfs from image-builder
RUN /usr/local/sbin/builder-leave

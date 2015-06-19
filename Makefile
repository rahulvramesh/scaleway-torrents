 DOCKER_NAMESPACE =	armbuild/
NAME =			scw-app-torrents
VERSION =		latest
VERSION_ALIASES =	1.2.0-dev
TITLE =			Seedbox
DESCRIPTION =		rtorrent and ruTorrent (web interface)
SOURCE_URL =		https://github.com/scaleway/image-app-torrents
IMAGE_VOLUME_SIZE =	150G

## Image tools  (https://github.com/scaleway/image-tools)
all:	docker-rules.mk
docker-rules.mk:
	wget -qO - http://j.mp/scw-builder | bash
-include docker-rules.mk


## Here you can add custom commands and overrides

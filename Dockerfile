FROM openjdk:jre-alpine as builder

RUN apk add curl
RUN curl -L https://github.com/multiarch/qemu-user-static/releases/download/v5.2.0-2/qemu-aarch64-static -o /usr/bin/qemu-aarch64-static
RUN curl -L https://github.com/multiarch/qemu-user-static/releases/download/v5.2.0-2/qemu-arm-static -o /usr/bin/qemu-arm-static

FROM builder

ARG ARCH=arm64
ARG VERSION="1.4.3"
LABEL maintainer="Jay MOULIN <https://jaymoulin.me/me/docker-jdownloader> <https://twitter.com/MoulinJay>"
LABEL version="${VERSION}-${ARCH}"
ENV LD_LIBRARY_PATH=/lib;/lib32;/usr/lib
ENV XDG_DOWNLOAD_DIR=/opt/JDownloader/Downloads
ENV LC_CTYPE="en_US.UTF-8"
ENV LANG="en_US.UTF-8"
ENV LC_COLLATE="C"
ENV LANGUAGE="C.UTF-8"
ENV LC_ALL="C.UTF-8"
ENV UMASK=''
COPY ./${ARCH}/*.jar /opt/JDownloader/libs/
# archive extraction uses sevenzipjbinding library
# which is compiled against libstdc++
RUN mkdir -p /opt/JDownloader/ && \
    apk add --update libstdc++ ffmpeg wget && \
    wget -O /opt/JDownloader/JDownloader.jar "http://installer.jdownloader.org/JDownloader.jar?$RANDOM" && \
    chmod +x /opt/JDownloader/JDownloader.jar && \
    chmod 777 /opt/JDownloader/ -R && \
    rm /usr/bin/qemu-*-static

COPY daemon.sh /opt/JDownloader/
COPY default-config.json.dist /opt/JDownloader/org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json.dist
COPY configure.sh /usr/bin/configure

EXPOSE 3129
WORKDIR /opt/JDownloader


CMD ["/opt/JDownloader/daemon.sh"]

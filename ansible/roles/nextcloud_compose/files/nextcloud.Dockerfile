# syntax = docker/dockerfile:1.6.0
FROM nextcloud:27.1.4-fpm
RUN apt-get update && apt-get install -y ffmpeg
RUN echo '#!/bin/bash \ntaskset -c 0,2 ffmpeg "$@" ' > /custom-ffmpeg.sh
RUN chmod a+rx /custom-ffmpeg.sh

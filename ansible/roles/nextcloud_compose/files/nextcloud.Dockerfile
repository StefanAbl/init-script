# syntax = docker/dockerfile:1.21.0
FROM nextcloud:30.0.17-fpm
RUN apt-get update && apt-get install -y ffmpeg
RUN echo '#!/bin/bash \ntaskset -c 0,2 ffmpeg "$@" ' > /custom-ffmpeg.sh
RUN chmod a+rx /custom-ffmpeg.sh

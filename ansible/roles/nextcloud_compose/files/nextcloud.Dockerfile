# syntax = docker/dockerfile:1.19.0
FROM nextcloud:32.0.1-fpm
RUN apt-get update && apt-get install -y ffmpeg
RUN echo '#!/bin/bash \ntaskset -c 0,2 ffmpeg "$@" ' > /custom-ffmpeg.sh
RUN chmod a+rx /custom-ffmpeg.sh

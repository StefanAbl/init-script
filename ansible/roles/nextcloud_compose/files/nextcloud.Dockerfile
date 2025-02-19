# syntax = docker/dockerfile:1.13.0
FROM nextcloud:28.0.11-fpm
RUN apt-get update && apt-get install -y ffmpeg
RUN echo '#!/bin/bash \ntaskset -c 0,2 ffmpeg "$@" ' > /custom-ffmpeg.sh
RUN chmod a+rx /custom-ffmpeg.sh

FROM nextcloud:26.0.5-fpm
RUN apt-get update && apt-get install -y ffmpeg

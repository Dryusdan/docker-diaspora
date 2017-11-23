FROM ruby:2.4.2-alpine3.6
FROM node:8.9-alpine
FROM xataz/nginx

ENV UID=991 GID=991 \
	 NPROC=2

RUN export BUILD_DEPS="build-base \
					    libxml2-dev \
					    libxslt-dev \
					    curl-dev \
					    git \
					    imagemagick-dev" \
&& apk add -U  ${BUILD_DEPS} \
		   libressl \
		   imagemagick \
		   curl \
		   ghostscript \
		   git \
		   postgresql-client \
		   su-exec \
		   s6 \
		   ca-certificates \
		   coreutils \
		   gcc \
&& gem install bundler \
&& git clone -b master https://github.com/diaspora/diaspora.git /diaspora \
&& cd /diaspora \
&& chmod +x script/server \
&& bin/bundle config --global silence_root_warning 1 \
&& bin/bundle install --retry 4 --without test development  --verbose \
&& apk del ${BUILD_DEPS} \
&& rm -rf /tmp/* /var/cache/apk/* /tmp/* /root/.gnupg /root/.cache/ /diaspora/.git

COPY rootfs/ /

RUN chmod +x /usr/local/bin/startup \
	&& chmod +x /etc/s6.d/diaspora/run
	
VOLUME  ["/config", "/diaspora/public"]
EXPOSE 8080
ENTRYPOINT [ "/usr/local/bin/startup" ]
CMD ["/bin/s6-svscan", "/etc/s6.d"]

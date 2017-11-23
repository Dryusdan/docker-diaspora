FROM alpine:3.6

ENV UID=991 GID=991

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
		   nodejs \
		   nodejs-npm \
		   ruby \
		   ruby-irb \
		   ruby-rdoc \
		   su-exec \
		   s6 \
&& gem install bundler \
&& git clone -b master https://github.com/diaspora/diaspora.git /diaspora \
&& cd /diaspora \
&& chmod +x script/server \
&& apk del ${BUILD_DEPS} \
&& rm -rf /tmp/* /var/cache/apk/* /tmp/* /root/.gnupg /root/.cache/ /diaspora/.git

COPY rootfs/ /

RUN chmod +x /usr/local/bin/startup \
	&& chmod +x /etc/s6.d/diaspora/run
	
VOLUME  ["/config", "/diaspora/public"]
EXPOSE 3000
ENTRYPOINT [ "/usr/local/bin/startup" ]
CMD ["/bin/s6-svscan", "/etc/s6.d"]

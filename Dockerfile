FROM xataz/nginx

ENV UID=991 GID=991 \
	 NPROC=2

RUN export BUILD_DEPS="build-base \
					    libxml2-dev \
					    libxslt-dev \
					    curl-dev \
					    git \
					    ruby-dev \
					    libffi-dev \
					    libtirpc-dev \
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
		   nodejs \
		   nodejs-npm \
		   libffi \
		   ruby \
		   ruby-irb \
		   ruby-rdoc \
&& gem install bundler \
&& git clone -b master https://github.com/diaspora/diaspora.git /diaspora \
&& cd /diaspora \
&& gem uninstall eye \
&& gem install eye -v 0.9.2.nosignar \
&& chmod +x script/server \
&& bin/bundle config --global silence_root_warning 1 \
&& bin/bundle config timeout 120 \
&& bin/bundle install --retry 4 --without test development  \
&& apk del ${BUILD_DEPS} \
&& rm -rf /tmp/* /var/cache/apk/* /tmp/* /root/.gnupg /root/.cache/ /diaspora/.git


COPY rootfs/ /

RUN chmod +x /usr/local/bin/startup \
	&& chmod +x /etc/s6.d/diaspora/run
	
VOLUME  ["/config", "/diaspora/public"]
EXPOSE 8080
ENTRYPOINT [ "/usr/local/bin/startup" ]
CMD ["/bin/s6-svscan", "/etc/s6.d"]

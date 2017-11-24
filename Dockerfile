FROM ruby:2.2-slim-jessie

ENV UID=991 GID=991 \
    NPROC=2

RUN echo "deb http://ftp.debian.org/debian jessie-backports main contrib non-free" >> /etc/apt/sources.list \
&& export BUILD_DEPS="  build-essential \
			libssl-dev  \
			libcurl4-openssl-dev \ 
			libxml2-dev libxslt-dev \
			libmagickwand-dev \
			libpq-dev" \
&& apt-get update \
&& apt-get install -y --no-install-recommends ${BUILD_DEPS} \
	      ruby \
	      imagemagick \
	      curl \
	      libcurl3 \
	      openssl \
	      ghostscript \
	      git \
	      nginx-light \
	      dnsutils \
	      ca-certificates \
&& curl -sL https://deb.nodesource.com/setup_6.x | bash - \
&& apt-get -y install -y nodejs --no-install-recommends \
&& gem install bundler \
&& git clone -b master https://github.com/diaspora/diaspora.git /diaspora \
&& cd /diaspora \
&& chmod +x script/server \
&& bin/bundle config --global silence_root_warning 1 \
&& bin/bundle config timeout 120 \
&& bin/bundle install --jobs $(nproc) --retry 4 --without test development --with postgresql \
&& apt-get remove --purge --yes ${BUILD_DEPS}  \
&& apt-get autoremove -y \
&& apt-get clean \
&& rm -rf /diaspora/.git /tmp/* /var/lib/apt/lists/* /var/cache/debconf/*-old /usr/share/man/?? /usr/share/man/??_* 

COPY rootfs/ /

RUN chmod +x /usr/local/bin/startup
	
VOLUME  ["/config", "/diaspora/public"]
EXPOSE 8080
ENTRYPOINT [ "/usr/local/bin/startup" ]
CMD ["/bin/s6-svscan", "/etc/s6.d"]

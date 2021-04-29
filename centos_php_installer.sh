#! /bin/sh

set -e

PHP_VERSION=8.0
# 初始化
rpmkeys --import file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial &&
  INSTALL_PKGS="bsdtar \
  findutils \
  gettext \
  groff-base \
  glibc-locale-source \
  glibc-langpack-en \
  rsync \
  scl-utils \
  tar \
  unzip \
  xz \
  yum \
  yum-utils \
  autoconf \
  automake \
  bzip2 \
  gcc \
  gcc-c++ \
  gd-devel \
  gdb \
  git \
  libcurl-devel \
  libpq-devel \
  libxml2-devel \
  libxslt-devel \
  lsof \
  make \
  openssl-devel \
  patch \
  procps-ng \
  redhat-rpm-config \
  unzip \
  wget \
  which \
  openssl \
  mysql-devel \
  zlib-devel" &&
  mkdir -p "${HOME}"/.pki/nssdb &&
  chown -R 1001:0 "${HOME}"/.pki &&
  yum install -y --setopt=tsflags=nodocs "$INSTALL_PKGS" &&
  rpm -V "$INSTALL_PKGS" &&
  rm -rf /var/cache/yum/* &&
  yum repolist &&
  yum -y clean all --enablerepo='*' &&
  dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-8.rpm -y && yum -y upgrade --setopt=tsflags=nodocs --nogpgcheck &&
  rm -rf /var/cache/yum/* &&
  yum repolist &&
  yum -y clean all --enablerepo='*'
# 安装 环境
dnf module reset php &&
  dnf module enable php:remi-${PHP_VERSION} -y &&
  dnf install pkgconfig -y && INSTALL_PKGS="php-gd php-xhprof php-ast php-cli php-dba php-dbg php-pdo \
  php-xml php-imap php-intl php-json php-ldap php-snmp php-soap \
  php-tidy php-devel php-bcmath php-brotli php-common php-recode \
  php-sodium php-xmlrpc php-enchant php-libvirt php-mysqlnd \
  php-pecl-ds php-pecl-ev php-process php-embedded php-mbstring \
  php-pecl-dio php-pecl-eio php-pecl-env php-pecl-lzf php-pecl-nsq \
  php-pecl-psr php-pecl-zip php-pecl-zmq php-componere php-pecl-grpc \
  php-pecl-http php-pecl-ssh2 php-pecl-sync php-pecl-uuid \
  php-pecl-vips php-pecl-yaml php-phpiredis php-wkhtmltox \
  php-pecl-event php-pecl-geoip php-pecl-gnupg php-pecl-mysql \
  php-pecl-oauth php-pecl-stats php-pecl-xattr php-pecl-xxtea \
  php-pecl-base58 php-pecl-hrtime php-pecl-mcrypt php-pecl-pdflib \
  php-pecl-propro php-pecl-redis php-pecl-decimal php-pecl-xmldiff \
  php-pecl-igbinary php-pecl-mogilefs php-pecl-json-post \
  php-pecl-ip2location php-pecl-http-message php-gmp php-pecl-apcu \
  php-zip php-swoole" &&
  yum install -y libstdc++ openssl pcre-devel pcre2-devel openssl-devel supervisor \
    "$INSTALL_PKGS" --skip-broken --setopt=tsflags=nodocs --nogpgcheck && rm -rf /var/cache/yum/* &&
  yum repolist &&
  yum -y clean all --enablerepo='*' &&
  wget -O /usr/local/bin/composer https://mirrors.aliyun.com/composer/composer.phar &&
  chmod a+x /usr/local/bin/composer &&
  composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/ && wget -O /usr/local/bin/php-cs-fixer https://github.com/FriendsOfPHP/PHP-CS-Fixer/releases/download/v2.18.6/php-cs-fixer.phar &&
  chmod a+x /usr/local/bin/php-cs-fixer &&
  sed -i "s@;date.timezone =@date.timezone = Asia/Shanghai@g" /etc/php.ini &&
  sed -i "s@max_execution_time = 30@max_execution_time = 300@g" /etc/php.ini &&
  sed -i "s@post_max_size = 8M@post_max_size = 32M@g" /etc/php.ini &&
  sed -i "s@max_input_time = 60@max_input_time = 600@g" /etc/php.ini &&
  sed -i "s@memory_limit = 128M@memory_limit = 2048M@g" /etc/php.ini &&
  sed -i "2i swoole.use_shortname=off\nswoole.unixsock_buffer_size=32M" /etc/php.d/40-swoole.ini

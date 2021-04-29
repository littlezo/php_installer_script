#! /bin/sh

set -e
VERSION=7.4.16
PREFIX=/usr/local/php
echo "Install dependency"
apt update -y && apt upgrade -y && apt update -y
apt install autoconf  gcc g++ git wget zip unzip curl openssl valgrind libkrb5-dev libssl-dev libzip-dev libjpeg-dev libpng-dev \
    libwebp-dev libpcre2-dev libcurl4-openssl-dev libxpm-dev libfreetype6-dev libsqlite3-dev argon2 libargon2-dev libmcrypt-dev \
    libonig-dev libxslt1-dev -y
apt autoremove
if [ -d "builder/" ];then
  cd builder
  else
  mkdir builder && cd builder
fi
if [ -f "php-$VERSION.tar.xz" ];then
    if [ -d "php-$VERSION/" ];then
      cd php-$VERSION
      else
      tar axvf php-$VERSION.tar.xz && cd php-$VERSION
    fi
  else
    wget https://www.php.net/distributions/php-$VERSION.tar.xz && tar axvf php-$VERSION.tar.xz && cd php-$VERSION
fi
echo "Start compiling"
make clear
make distclean
./buildconf --force
./configure --prefix=$PREFIX --enable-embed=static --with-valgrind --with-openssl --with-kerberos \
    --with-system-ciphers --with-external-pcre --with-pcre-jit  --with-zlib --enable-bcmath --with-bz2 \
    --enable-calendar --with-curl --enable-exif --enable-ftp --enable-gd --with-png --with-webp --with-jpeg \
    --with-xpm --with-freetype --without-sqlite3 --with-gettext --with-mhash --enable-intl --with-mysqli \
    --enable-pcntl --enable-soap --enable-sockets --with-pdo-mysql --enable-shmop --with-password-argon2 \
    --enable-sysvmsg --enable-sysvsem --enable-mbstring --enable-sysvshm --with-tidy --with-xsl --enable-mysqlnd \
    --disable-opcache --with-pear
make
make install
USER_PATH=$(echo $PREFIX/bin |sed -e 's/\//\\\//g')
sed -i '/PATH=$PATH:'"$USER_PATH"'/d' /etc/profile
sed -i '/export PATH/i\PATH=$PATH:'"$USER_PATH" /etc/profile
./etc/profile
cp php.ini-development $PREFIX/lib/php.ini
sed -i "s@;date.timezone =@date.timezone = Asia/Shanghai@g" $PREFIX/lib/php.ini
sed -i "s@max_execution_time = 30@max_execution_time = 300@g" $PREFIX/lib/php.ini
sed -i "s@post_max_size = 8M@post_max_size = 32M@g" $PREFIX/lib/php.ini
sed -i "s@max_input_time = 60@max_input_time = 600@g" $PREFIX/lib/php.ini
sed -i "s@memory_limit = 128M@memory_limit = 2048M@g" $PREFIX/lib/php.ini
pecl channel-update pecl.php.net
pecl install redis
pecl install swoole
sed -i '/; Module Settings ;/a\;;;;;;;;;;;;;;;;;;;\n[redis]\nextension=redis\n[swoole]\nextension=swoole\nswoole.use_shortname=off\nswoole.unixsock_buffer_size=32M' $PREFIX/lib/php.ini
echo "php install successful"
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod u+x /usr/local/bin/composer
composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/
echo "composer install successful"
curl -L https://cs.symfony.com/download/php-cs-fixer-v2.phar -o /usr/local/bin/php-cs-fixer
chmod u+x /usr/local/bin/php-cs-fixer
echo "php-cs-fixer install successful"
php -v
composer --version
php-cs-fixer --version

# Xhgui docker image
[![Build Status](https://travis-ci.com/edyan/docker-xhgui.svg?branch=master)](https://travis-ci.com/edyan/docker-xhgui)
[![Docker Pulls](https://img.shields.io/docker/pulls/edyan/xhgui.svg)](https://hub.docker.com/r/edyan/xhgui/)


Docker Hub: https://hub.docker.com/r/edyan/xhgui

Docker containers that runs [xhgui](https://github.com/perftools/xhgui) (which needs mongodb, nginx and PHP).

It's based on :
* [edyan/php:5.6](https://github.com/inetprocess/docker-php/tree/master/5.6) image (jessie stable).
* or [edyan/php:7.2](https://github.com/inetprocess/docker-php/tree/master/7.2) image (stretch stable).

It's made for development purposes.

To use it in an integrated environment, try [Stakkr](https://github.com/stakkr-org/stakkr)


## Run Docker image
To make it work, you need to link it to an existing PHP environment. Example via `docker-compose.yml` :

```yaml
version: '2'
services:
  xhgui:
    image: edyan/xhgui:php7.2
    # I need to access xhgui
    ports:
      - "9000:80"
    volumes:
      - ./xhgui-config.php:/usr/local/src/xhgui/config/config.php
  php:
    hostname: php
    image: edyan/php:7.2
    # To have the new mounted volumes as well as the default volumes of xhgui (its source code)
    volumes_from: [xhgui]
    volumes:
      - ./src:/var/www

  # the "visible" part (web server)
  web:
    hostname: web
    image: edyan/nginx:1.15-alpine
    ports:
      - "8000:80"
    volumes:
      # /var/www is my default document root in that image
      - ./src:/var/www

```


As seen above, you need to mount your own configuration file that connects to the **right** mongodb server. The `xhgui-config.php` file, in our case (see the [official xhgui repo](https://github.com/perftools/xhgui)), will contain (*note the db.host*):
```php
<?php
return array(
    'debug' => false,
    'mode' => 'development',
    'save.handler' => 'mongodb',
    'db.host' => 'mongodb://xhgui',
    'db.db' => 'xhprof',
    'db.options' => array(),
    'templates.path' => dirname(__DIR__) . '/src/templates',
    'date.format' => 'M jS H:i:s',
    'detail.count' => 6,
    'page.limit' => 25,
    'profiler.enable' => function () {
        return true;
    },
    'profiler.simple_url' => function ($url) {
        return preg_replace('/\=\d+/', '', $url);
    }
);
```

And the `src/index.php`:
```php
<?php

require_once('/usr/local/src/xhgui/external/header.php');

echo strtoupper('abc');
```

Finally, launch the environment with : `docker-compose up --force-recreate`.
Then call _http://localhost:8000/index.php_ in your browser and  get reports from _http://localhost:9000_.



## Call the profiler
### With require_once
You have two ways to call the profiler. The first one, the most easiest, is to require the file from your script.
For that **you must mount the volumes (with `volumes_from`) of the xhgui container to your php container**. The code is the following:
```php
<?php
require_once('/usr/local/src/xhgui/external/header.php');
// ... Code below
```

### Globally
If you want to profile *everything* then you must override the second one, by altering the php.ini configuration and use PHP's auto_prepend_file directive:
```ini
auto_prepend_file=/usr/local/src/xhgui/external/header.php
```

If you use [edyan/php](https://github.com/inetprocess/docker-php) you can override the configuration.
See the [documentation](https://github.com/inetprocess/docker-php#custom-phpini-directives)


## Environment variables
Two variables have been created (`FPM_UID` and `FPM_GID`) to override the www-data user and group ids. Giving the current user login / pass that runs the container, it will allow anybody to own the files read / written by the fpm daemon (started by www-data).

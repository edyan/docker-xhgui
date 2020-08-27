# Xhgui docker image
[![Build Status](https://travis-ci.com/edyan/docker-xhgui.svg?branch=master)](https://travis-ci.com/edyan/docker-xhgui)
[![Docker Pulls](https://img.shields.io/docker/pulls/edyan/xhgui.svg)](https://hub.docker.com/r/edyan/xhgui/)


Docker Hub: https://hub.docker.com/r/edyan/xhgui

Docker containers that runs [xhgui](https://github.com/perftools/xhgui) (which needs mongodb and PHP).

It's based on :
* [edyan/php:5.6](https://github.com/edyan/docker-php/tree/master/5.6) image (jessie stable).
* or [edyan/php:7.2](https://github.com/edyan/docker-php/tree/master/7.2) image (stretch stable).

It's made for development purposes. You need to find the right version for your project.
Use 5.6 for PHP 5.6 projects and 7.2 for PHP 7.x projects. Just make sure you have the
`mongodb` extension enabled (v1.5) on your main PHP container.

To use it in an integrated environment, try [Stakkr](https://github.com/stakkr-org/stakkr)


## Example

To make it work, you need to link it to an existing PHP environment. Example via `docker-compose.yml` :

The Docker Compose configuration is different for Compose versions 2 and 3:

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
    command: /usr/bin/php -S 0.0.0.0:80 -t /var/www
    image: edyan/php:7.2 # That image contains mongodb extension from PECL
    # To have the new mounted volumes as well as the default volumes of xhgui (its source code)
    volumes_from: [xhgui]
    ports:
      - "8000:80"
    volumes:
      - ./src:/var/www
```

The `volumes_from` is no longer supported in the Docker Compose version 3 syntax. We have to define a volume for *xhgui* in the global section of the config file and reference it in each of the services:

```yaml
version: '3'

volumes:
  xhgui:

services:
  xhgui:
    image: edyan/xhgui:php7.2
    # I need to access xhgui
    ports:
      - "9000:80"
    volumes:
      - ./xhgui-config.php:/usr/local/src/xhgui/config/config.php
      - xhgui:/usr/local/src
  php:
    hostname: php
    command: /usr/bin/php -S 0.0.0.0:80 -t /var/www
    image: edyan/php:7.2 # That image contains mongodb extension from PECL
    # To have the new mounted volumes as well as the default volumes of xhgui (its source code)
    ports:
      - "8000:80"
    volumes:
      - ./src:/var/www
      - xhgui:/usr/local/src
      - ./.config/xhgui/config.php:/usr/local/src/xhgui/config/config.php
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

function test_xhgui()
{
    $data = [];
    for ($i = 0; $i < 5000; $i++) {
        $data[] = $i * $i;
        sort($data);
    }
}

test_xhgui();

```

Finally, launch the environment with : `docker-compose up --force-recreate`.
Then call _http://localhost:8000/index.php_ in your browser and  get reports
from _http://localhost:9000_.



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

If you use [edyan/php](https://github.com/edyan/docker-php) you can override the configuration.
See the [documentation](https://github.com/edyan/docker-php#custom-phpini-directives)


## Environment variables
* `XHGUI_MONGO_HOST` default to `mongodb://127.0.0.1`, used in XHGui config file.
* `MONGO_PORT` default to 27017
* `PHP_WEBSERVER_PORT` default to 80


## Quick Test
A `docker-compose` file is available to do some tests:
```bash
$ docker-compose -f docker-compose.sample.yml up --force-recreate -d
# Enter the php container
$ docker-compose -f docker-compose.sample.yml exec php bash
# Create a file
$ mkdir -p /var/www
# As we didn't mount the configuration file, we force the env variable for the server
$ echo '<?php putenv("XHGUI_MONGO_HOST=mongodb://xhgui"); require_once("/usr/local/src/xhgui/external/header.php"); $a=[]; for($i=0; $i<10000; $i++){ $a[]=$i; } sort($a); echo "Done";' > /var/www/index.php
```

Now open http://localhost:8000/index.php to read the new file created.
Then http://localhost:9000 to see the report.

Clean :
```bash
$ docker-compose -f docker-compose.sample.yml down
```

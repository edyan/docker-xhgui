# Xhgui docker image
[![Build Status](https://travis-ci.com/edyan/docker-xhgui.svg?branch=master)](https://travis-ci.com/edyan/docker-xhgui)
[![Docker Pulls](https://img.shields.io/docker/pulls/edyan/xhgui.svg)](https://hub.docker.com/r/edyan/xhgui/)


Docker Hub: https://hub.docker.com/r/edyan/xhgui

Docker containers that runs [xhgui](https://github.com/perftools/xhgui) (which needs mongodb and PHP).

It's based on :
* [edyan/php:5.6](https://github.com/edyan/docker-php/tree/master/5.6) image (jessie stable).
* or [edyan/php:7.2](https://github.com/edyan/docker-php/tree/master/7.2) image (Ubuntu 18.04).
* or [edyan/php:7.4](https://github.com/edyan/docker-php/tree/master/7.4) image (Ubuntu 20.04).
Use that one as a preview version, xhgui is not officially compatible with PHP > 7.3

It's made for development purposes. You need to find the right version for your project.
Use 5.6 for PHP 5.6 projects and 7.2 / 7.4 for PHP 7.x projects. Just make sure you have the
`mongodb` extension enabled on your main PHP container.

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
  php:
    hostname: php
    command: /usr/bin/php -S 0.0.0.0:80 -t /var/www
    image: edyan/php:7.2 # That image contains mongodb extension from PECL
    # To have xhgui sources mount xhgui's volumes
    volumes_from: [xhgui]
    ports:
      - "8000:80"
    volumes:
      - "./src:/var/www"
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
```

You need to set an environment variable to define the right mongodb server
and then include the prepared profiler to your file, for example `src/index.php`:
```php
<?php

// Call the profiler
putenv('XHGUI_MONGO_HOST=mongodb://xhgui:27017');
require_once('/usr/local/src/xhgui/external/header.php');

// Run your code
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


## Environment variables
* `XHGUI_MONGO_HOST` default to `mongodb://127.0.0.1:27017`, used in XHGui config file.
* `MONGO_PORT` default to 27017
* `PHP_WEBSERVER_PORT` default to 80


## Quick Test
A `docker-compose` file is available to do some tests:
```bash
$ mkdir src
$ echo '<?php putenv("XHGUI_MONGO_HOST=mongodb://xhgui"); require_once("/usr/local/src/xhgui/external/header.php"); $a=[]; for($i=0; $i<10000; $i++){ $a[]=$i; } sort($a); echo "Done";' > src/index.php
$ docker-compose -f docker-compose.sample.yml up --force-recreate -d
```

Now open http://localhost:8000/index.php to read the new file created.
Then http://localhost:9000 to see the report.

Clean :
```bash
$ docker-compose -f docker-compose.sample.yml down
```

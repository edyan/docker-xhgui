# Xhgui docker image
Docker Hub: https://hub.docker.com/r/edyan/xhgui

Docker containers that runs [xhgui](https://github.com/perftools/xhgui) (which needs mongodb, nginx and PHP). It's based on [edyan/php:5.6](https://github.com/inetprocess/docker-php/tree/master/5.6) image (jessie stable).

It's made for development purposes and is not compatible yet with PHP 7.x (missing old mongo extension). 

To use it in an integrated environment, try our [Docker LAMP stack](https://github.com/inetprocess/marina)


## Run Docker image
Add the following to your docker-compose.yml file:
```yaml
xhgui:
    image: edyan/xhgui
```

Of course, you'll not mount your PHP sources to that image (**it's really not made for that**). So you need to link your `php` container to that one. Example:

```yaml
php:
    links:
        - xhgui
    # To have the sources of xhgui mounted to your php container
    volumes_from: [xhgui]
    volumes:
        # Local configuration to override the one which connects in local
        - ./config.php:/usr/local/src/xhgui/config/config.php

```

As seen above, you need to mount your own configuration file that connects to the **right** mongodb server. The file, in our case (see the [official xhgui repo](https://github.com/perftools/xhgui)), will contain (*note the db.host*):
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

<?php
return array(
    'debug' => false,
    'mode' => 'development',
    'save.handler' => 'mongodb',
    'db.host' => 'mongodb://127.0.0.1',
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

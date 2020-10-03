<?php

require_once __DIR__ . '/vendor/autoload.php';

use \Xhgui\Profiler\Profiler;
use \Xhgui\Profiler\ProfilingFlags;

$profiler = new Profiler([
    'profiler' => Profiler::PROFILER_TIDEWAYS,
    'profiler.flags' => array(
        ProfilingFlags::CPU,
        ProfilingFlags::MEMORY,
        ProfilingFlags::NO_BUILTINS,
        ProfilingFlags::NO_SPANS,
    ),
    'save.handler' => Profiler::SAVER_MONGODB,
    'save.handler.mongodb' => [
        'dsn' => getenv('XHGUI_MONGO_HOST') ?: 'mongodb://127.0.0.1:27017',
        'database' => 'xhprof',
        'options' => [],
        'driverOptions' => [],
    ],
    'profiler.options' => [],
    'profiler.enable' => function () {
        return true;
    },
]);

$profiler->start();

<?php
$__stime = microtime(true);
ob_start();
require_once(dirname(__FILE__) . '/../cfg/bootstrap_web.php');
$__etime = microtime(true);
header('X-Script-Running-Time: ' . number_format((($__etime - $__stime) * 1000), 2) . ' ms');

#!/bin/bash

/etc/init.d/zend-server start

exec supervisord -n

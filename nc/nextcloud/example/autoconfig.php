<?php

$AUTOCONFIG = [
    'dbtype'        => getenv('NC_DB_TYPE'),
    'dbname'        => getenv('DB_NAME'),
    'dbuser'        => getenv('DB_USER'),
    'dbpass'        => getenv('DB_PASSWORD'),
    'dbhost'        => getenv('NC_DB_HOST'),
    'dbtableprefix' => getenv('NC_DB_PREFIX'),
    'directory'     => getenv('NC_DATA_DIR'),
    'adminlogin'    => getenv('NC_ADMIN_USER'),
    'adminpass'     => getenv('NC_ADMIN_PASSWORD'),
];

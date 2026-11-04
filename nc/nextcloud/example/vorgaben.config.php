<?php

$CONFIG = array (

  'serverid' => getenv('NC_SERVER_ID'),

  'trusted_proxies' =>
  array (
    0 => getenv('DOCKER_IPV4_SUBNET'),
    1 => getenv('DOCKER_IPV6_SUBNET'),
    1 => '127.0.0.1',
    2 => '::1',
  ),

  'notify_push' =>
  array (
    'url' => 'https://' . getenv('NC_DOMAIN') . '/push',
  ),

  'overwriteprotocol' => 'https',
  'overwrite.cli.url' => 'https://' . getenv('NC_DOMAIN'),
  'overwritehost' => getenv('NC_DOMAIN'),
  'overwritewebroot' => '/',

  'datadirectory' => getenv('NC_DATA_DIR'),

  'logtimezone' => getenv('TZ'),
  'log_type' => 'file',
  'loglevel' => 3,
  'log_rotate_size' => '10485760',
  'logfile' => getenv('NC_DATA_DIR') . '/nextcloud.log',

  'filesystem_check_changes' => 1,
  'simpleSignUpLink.shown' => false,

  'default_language' => getenv('NC_DEFAULT_LANGUAGE'),
  'knowledgebaseenabled' => getenv('NC_KNOWLEDGEBASE_ENABLED') === 'true',
  'auth.webauthn.enabled' => getenv('NC_WEBAUTHN_ENABLED') === 'true',
  'lost_password_link' => getenv('NC_LOST_PASSWORD_LINK'),
  'default_phone_region' => getenv('NC_DEFAULT_PHONE_REGION'),

  'maintenance_window_start' => 1,

  'twofactor_enforced' => 'true',
  'twofactor_enforced_groups' =>
  array (
  ),
  'twofactor_enforced_excluded_groups' =>
  array (
    0 => 'admin',
  ),

  'activity_use_cached_mountpoints' => true,

  // SMTP
  'mail_smtpmode' => getenv('NC_MAIL_MODE'),
  'mail_sendmailmode' => 'smtp',
  'mail_from_address' => getenv('NC_MAIL_FROM'),
  'mail_domain' => getenv('NC_MAIL_DOMAIN'),
  'mail_smtphost' => getenv('NC_MAIL_HOST'),
  'mail_smtpport' => getenv('NC_MAIL_PORT'),
  'mail_smtpauth' => getenv('NC_MAIL_AUTH') === 'true',
  'mail_smtpname' => getenv('NC_MAIL_USER'),
  'mail_smtppassword' => getenv('NC_MAIL_PASSWORD'),
  'mail_smtpstreamoptions' =>
  array (
    'ssl' =>
    array (
      'allow_self_signed' => false,
      'verify_peer' => true,
      'verify_peer_name' => true,
    ),
  ),
  'mail_smtpsecure' => getenv('NC_MAIL_SECURE'),

  'preview_max_x' => NULL,
  'preview_max_y' => NULL,
  'preview_max_scale_factor' => 2,
  'preview_max_filesize_image' => -1,
  'preview_max_memory' => -1,
  'preview_use_imagick' => true,
  'preview_interpolate' => false,
  'enable_previews' => true,

  'enabledPreviewProviders' =>
  array (
    0 => 'OC\\Preview\\JPEG',
    1 => 'OC\\Preview\\PNG',
    2 => 'OC\\Preview\\GIF',
    3 => 'OC\\Preview\\BMP',
    4 => 'OC\\Preview\\Movie',
    5 => 'OC\\Preview\\Image',
    6 => 'OC\\Preview\\HEIC',
    7 => 'OC\\Preview\\TIFF',
  ),

  'memcache.local' => '\\OC\\Memcache\\APCu',
  'memcache.locking' => '\\OC\\Memcache\\Redis',
  'memcache.distributed' => '\\OC\\Memcache\\Redis',

  'redis' =>
  array (
    'host' => 'nc_redis',
    'port' => 6379,
    'timeout' => 0.0,
    'dbindex' => 0,
  ),

  'filelocking.enabled' => true,

  'memories.db.triggers.fcu' => true,
  'memories.gis_type' => 1,
  'memories.exiftool' => '/var/www/nextcloud/apps/memories/bin-ext/eperl-amd64-glibc',
  'memories.vod.path' => '/var/www/nextcloud/apps/memories/bin-ext/go-vod-amd64',
  'memories.vod.ffmpeg' => '/usr/bin/ffmpeg',
  'memories.vod.ffprobe' => '/usr/bin/ffprobe',

);

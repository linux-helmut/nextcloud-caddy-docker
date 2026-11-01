<?php
$CONFIG = array (

  'serverid' => '5',

  'trusted_proxies' =>
  array (
    0 => '172.30.0.0/16',
    1 => '127.0.0.1',
    2 => '::1',
  ),

  'notify_push' =>
  array (
    'url' => 'https://nextcloud.domain.de/push',
  ),

  'overwriteprotocol' => 'https',
  'overwrite.cli.url' => 'https://nextcloud.domain.de',
  'overwritehost' => 'nextcloud.domain.de',
  'overwritewebroot' => '/',

  'datadirectory' => '/var/www/data',

  'logtimezone' => 'Europe/Berlin',
  'log_type' => 'file',
  'loglevel' => 3,
  'log_rotate_size' => '10485760',
  'logfile' => '/var/www/data/nextcloud.log',

  'filesystem_check_changes' => 1,
  'simpleSignUpLink.shown' => false,

  'dbtype' => 'mysql',
  'dbname' => 'nextcloud',
  'dbhost' => 'mariadb:3306',
  'dbtableprefix' => 'oc_',
  'mysql.utf8mb4' => true,
  'dbuser' => 'nextcloud',
  'dbpassword' => 'nextcloud',

  'default_language' => 'de_DE',
  'knowledgebaseenabled' => false,
  'auth.webauthn.enabled' => false,
  'lost_password_link' => 'disabled',
  'default_phone_region' => 'DE',
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
  
  'mail_smtpmode' => 'smtp',
  'mail_sendmailmode' => 'smtp',
  'mail_from_address' => 'nextcloud',
  'mail_domain' => 'domain.de',
  'mail_smtphost' => 'mail.domain.de',
  'mail_smtpport' => '465',
  'mail_smtpauth' => true,
  'mail_smtpname' => 'nextcloud@domain.de',
  'mail_smtppassword' => 'EIN_STARKES_PASSWORT',
  'mail_smtpstreamoptions' =>
  array (
    'ssl' =>
    array (
      'allow_self_signed' => false,
      'verify_peer' => true,
      'verify_peer_name' => true,
    ),
  ),
  'mail_smtpsecure' => 'ssl',

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
    'host' => 'redis',
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

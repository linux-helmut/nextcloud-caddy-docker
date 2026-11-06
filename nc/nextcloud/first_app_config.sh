#!/bin/bash

source /docker/nc/config.env



docker exec -it nc_cloud php /var/www/nextcloud/occ app:install previewgenerator


docker exec -it nc_cloud php /var/www/nextcloud/occ app:install recognize
docker exec -it nc_cloud php /var/www/nextcloud/occ recognize:download-models
docker exec -u www-data nc_cloud php /var/www/nextcloud/occ config:app:set recognize faces.enabled --value="true"
docker exec -u www-data nc_cloud php /var/www/nextcloud/occ config:app:set recognize imagenet.enabled --value="true"
docker exec -u www-data nc_cloud php /var/www/nextcloud/occ config:app:set recognize landmarks.enabled --value="true"

# Node.js-Pfad für Recognize setzen, wenn Node 26 installiert wurde
if [ "$INSTALL_NODE26" = "true" ]; then
    docker exec -u www-data nc_cloud php /var/www/nextcloud/occ config:app:set recognize node_binary --value="/usr/local/bin/node"
fi



docker exec -it nc_cloud php /var/www/nextcloud/occ app:install memories
docker exec -it nc_cloud php /var/www/nextcloud/occ memories:places-setup

docker exec -it nc_cloud php /var/www/nextcloud/occ maintenance:repair --include-expensive
docker exec -it nc_cloud php /var/www/nextcloud/occ db:add-missing-indices

#docker exec -it nc_cloud php /var/www/nextcloud/occ app:install files_3dmodelviewer
docker exec -it nc_cloud php /var/www/nextcloud/occ app:install calendar
docker exec -it nc_cloud php /var/www/nextcloud/occ app:install contacts
docker exec -it nc_cloud php /var/www/nextcloud/occ app:install camerarawpreviews
docker exec -it nc_cloud php /var/www/nextcloud/occ app:install theming_customcss
docker exec -it nc_cloud php /var/www/nextcloud/occ app:install files_external
docker exec -it nc_cloud php /var/www/nextcloud/occ app:install files_linkeditor
#docker exec -it nc_cloud php /var/www/nextcloud/occ app:install maps
#docker exec -it nc_cloud php /var/www/nextcloud/occ app:install metadata
#docker exec -it nc_cloud php /var/www/nextcloud/occ app:install music
docker exec -it nc_cloud php /var/www/nextcloud/occ app:install files_photospheres
docker exec -it nc_cloud php /var/www/nextcloud/occ app:install notify_push
docker exec -it nc_cloud php /var/www/nextcloud/occ app:install extended_occweb

docker exec -it nc_cloud php /var/www/nextcloud/occ app:disable comments
docker exec -it nc_cloud php /var/www/nextcloud/occ app:disable dashboard
docker exec -it nc_cloud php /var/www/nextcloud/occ app:disable app_api
docker exec -it nc_cloud php /var/www/nextcloud/occ app:disable contactsinteraction
docker exec -it nc_cloud php /var/www/nextcloud/occ app:disable federation
docker exec -it nc_cloud php /var/www/nextcloud/occ app:disable files_reminders
docker exec -it nc_cloud php /var/www/nextcloud/occ app:disable files_downloadlimit
docker exec -it nc_cloud php /var/www/nextcloud/occ app:disable firstrunwizard
docker exec -it nc_cloud php /var/www/nextcloud/occ app:disable nextcloud_announcements
docker exec -it nc_cloud php /var/www/nextcloud/occ app:disable webhook_listeners
docker exec -it nc_cloud php /var/www/nextcloud/occ app:disable privacy
docker exec -it nc_cloud php /var/www/nextcloud/occ app:disable recommendations
docker exec -it nc_cloud php /var/www/nextcloud/occ app:disable support

docker exec -it nc_cloud php /var/www/nextcloud/occ app:disable weather_status
docker exec -it nc_cloud php /var/www/nextcloud/occ app:disable files_versions
docker exec -it nc_cloud php /var/www/nextcloud/occ app:disable user_status
docker exec -it nc_cloud php /var/www/nextcloud/occ app:disable survey_client
docker exec -it nc_cloud php /var/www/nextcloud/occ app:disable circles
docker exec -it nc_cloud php /var/www/nextcloud/occ app:disable office




exit

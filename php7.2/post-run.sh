#!/bin/bash

# Right Permissions
usermod -u $FPM_UID www-data
groupmod -g $FPM_GID www-data
chown -R www-data:www-data /usr/local/src/xhgui /var/log/php /var/log/nginx

# Define indexes for mongodb
for i in $(seq 1 90); do
    mongo --port $MONGO_PORT --eval "printjson(db.serverStatus())" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        break
    fi


    if [ $i -eq 90 ]; then
        exit 1
    fi

    sleep 1
done

mongo --port $MONGO_PORT > /dev/null 2>&1 <<EOF
use xhprof
db.results.ensureIndex( { 'meta.SERVER.REQUEST_TIME' : -1 } )
db.results.ensureIndex( { 'profile.main().wt' : -1 } )
db.results.ensureIndex( { 'profile.main().mu' : -1 } )

db.results.ensureIndex( { 'profile.main().cpu' : -1 } )
db.results.ensureIndex( { 'meta.url' : 1 } )
db.results.ensureIndex( { "meta.request_ts" : 1 }, { expireAfterSeconds : 432000 } )
EOF

exit 0

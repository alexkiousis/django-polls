#!/bin/sh

if [ ! -d "$OPTION_STORAGEDIR" ];
then
    mkdir -p $OPTION_STORAGEDIR
fi

for DIR in $DILOSI_STATIC_ROOT $DILOSI_SMS_FILE_PATH $DILOSI_DATA_DIR;
do
    if [ ! -d "$DIR" ];
    then
        mkdir -p ${DIR}
    fi
done

. ${OPTION_VENVDIR}/bin/activate

gunicorn mysite.wsgi \
    --bind=[::]:${OPTION_GUNICORN_PORT} \
    --workers=${OPTION_GUNICORN_WORKERS} \
    --worker-tmp-dir=/dev/shm \
    --log-file=- \
    --access-logfile=-

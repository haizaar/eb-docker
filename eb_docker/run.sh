#!/bin/sh

trap 'kill $CELERY_PID $WEB_PID' EXIT

start_celery() {
	while true; do
		celery -A eb_docker worker -l INFO
	done
}

start_celery &
CELERY_PID=$!

gunicorn --bind=0.0.0.0:8000 --threads=25 eb_docker.wsgi &
WEB_PID=$1

wait

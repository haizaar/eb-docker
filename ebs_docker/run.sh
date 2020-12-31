#!/bin/sh

# need to run celery here

exec gunicorn --bind=0.0.0.0:8000 --threads=25 ebs_docker.wsgi

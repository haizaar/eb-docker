#!/bin/sh

exec gunicorn --bind=0.0.0.0:8000 --threads=25 ebs_docker.wsgi

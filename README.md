# Elastic Beanstalk Docker with Django

This is a sample on how to run Django + Celery on AWS Elastic Beanstalk
in its simplest form.

## TL; DR;

* Clone the project
* **Make sure you have recent version of Python 3 (3.6 or later)**

Bootstrap:
```console
pip install --user --upgrade pip
pip install --user --upgrade pipenv
```

Now, in the project directory run:
```console
pipenv install --three
pipenv shell
```

Now deploy the project to AWS Elastic Beanstalk
```console
eb init -p docker eb-docker
eb create eb-docker-dev --database --min-instances=2
eb deploy
```

## Whys and Hows
Elastic Beanstalk service seems to be at crossroads as of Jan 2021 with
regards to it's docker support:

* The have migrated to Amazon Linux 2 which obsoleted Multi-Container support
* The only way to run multiple containers per host with Elastic Beanstalk on
  on Amazon Linux 2 is to use Docker Compose, but the latter is... it's not
  deprecated but is not a mainstream tool anymore

As a stop-gap each this project launches celery simply on the background inside
the main gunicorn/django process. This is of course deficient, but once you have
container you are better of with K8s anyway.

This project also demonstrates, via `.ebextensions/container-commands.config`, how
Django migrations can be executed on a leader-only during application deployment.

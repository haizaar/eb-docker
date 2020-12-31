# Can't use named layes "FROM ... AS builder" because
# https://stackoverflow.com/a/62031810/360390
FROM python:3.8.6-alpine3.12

# For the idea of why and how, please read:
# https://tech.zarmory.com/2018/09/docker-multi-stage-builds-for-python-app.html

# Create install user/group
ENV INSTUID=2000 INSTGID=2000 INSTNAME=appinst
RUN set -ex && \
    addgroup -S -g $INSTGID $INSTNAME && \
    adduser -G $INSTNAME -S -u $INSTUID $INSTNAME

# Prepare install dir
ENV PYROOT /pyroot
ENV PATH $PYROOT/bin:$PATH
RUN set -ex && \
    mkdir $PYROOT && \
    chown $INSTNAME:$INSTNAME $PYROOT
# This is crucial for pkg_resources to work
ENV PYTHONUSERBASE $PYROOT

# This is for secure install
# Who knows that packages do in their setup.py
RUN apk add --no-cache su-exec

WORKDIR /build

RUN apk add --no-cache build-base

RUN pip install --upgrade pip==20.3.3

COPY requirements.txt ./
# --ignore-install is vital to re-install packages that are already present
# (e.g. brought by pipenv dependencies) into $PYROOT
# Redefining HOME to someting writable for a non-root user
RUN set -ex && \
    export HOME=/tmp && \
    su-exec $INSTNAME:$INSTNAME sh -c "pip install --user --ignore-installed -r requirements.txt"

RUN ln -s $PYROOT/lib/python* $PYROOT/lib/python


##################
# The final image
##################
FROM haizaar/python-minimal:3.8.6-alpine3.12-1

# Our app does not run as root
# Do not use USER - hard to obtain root from kubectl exec
RUN apk add --no-cache su-exec

ENV PYROOT /pyroot
ENV PATH $PYROOT/bin:$PATH
# This is crucial for pkg_resources to work
ENV PYTHONUSERBASE $PYROOT

# Finally, copy artifacts
COPY --from=0 $PYROOT/lib/ $PYROOT/lib/
COPY --from=0 $PYROOT/bin/ $PYROOT/bin/

WORKDIR /app
COPY ebs_docker ./

EXPOSE 8000

# We install as $INSTNAME, but run as nobody
# Don't use USER - kubectl exec will never give you root if you do
# (It does not support --user flag)
CMD ["su-exec", "nobody:nobody", "/app/run.sh"]

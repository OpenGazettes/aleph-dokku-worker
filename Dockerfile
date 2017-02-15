FROM code4sa/aleph:simpler-docker

ENV ELASTICSEARCH_INDEX aleph
ENV ZA_GAZETTE_ARCHIVE_URI http://s3-eu-west-1.amazonaws.com/code4sa-gazettes/archive/
ENV C_FORCE_ROOT=true

COPY requirements.txt /tmp/requirements.txt
RUN pip install -U -r /tmp/requirements.txt

RUN mkdir /app
COPY CHECKS /app/CHECKS

WORKDIR /aleph

CMD newrelic-admin run-program celery -A aleph.queue worker -c $CELERY_CONCURRENCY -l $LOGLEVEL --logfile=/var/log/celery.log

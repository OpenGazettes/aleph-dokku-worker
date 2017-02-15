FROM code4sa/aleph:simpler-docker

ENV ELASTICSEARCH_INDEX aleph
ENV ZA_GAZETTE_ARCHIVE_URI http://s3-eu-west-1.amazonaws.com/code4sa-gazettes/archive/
ENV C_FORCE_ROOT=true

COPY requirements.txt /tmp/requirements.txt
RUN pip install -U -r /tmp/requirements.txt
# HACK to work around bug in boto https://github.com/boto/boto/pull/3633
RUN sed -i 's/eu-west-1.queue.amazonaws.com/sqs.eu-west-1.amazonaws.com/g' /usr/local/lib/python2.7/site-packages/boto/endpoints.json

RUN mkdir /app
WORKDIR /aleph

CMD newrelic-admin run-program celery -A aleph.queue worker -c $CELERY_CONCURRENCY -l $LOGLEVEL --logfile=/var/log/celery.log

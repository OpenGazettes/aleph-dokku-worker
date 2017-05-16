FROM opengazettes/aleph:latest

ENV ELASTICSEARCH_INDEX aleph
ENV C_FORCE_ROOT=true

COPY requirements.txt /tmp/requirements.txt
RUN pip install -U -r /tmp/requirements.txt
WORKDIR /aleph

CMD celery -A aleph.queues -B -c $CELERY_CONCURRENCY -l $LOGLEVEL worker --pidfile /var/lib/celery.pid

FROM opengazettes/aleph:latest

ENV ELASTICSEARCH_INDEX aleph
ENV C_FORCE_ROOT=true
ENV ALEPH_SETTINGS /aleph/code4africa_aleph_config.py

# RUN apt-get update && apt-get install -y libssl-dev libcurl4-openssl-dev python-dev telnet
COPY requirements.txt /tmp/requirements.txt
RUN pip install -U -r /tmp/requirements.txt
RUN pip uninstall -y celery kombu && pip install --no-cache-dir celery==3.1.23

WORKDIR /aleph

CMD celery -A aleph.queues -B -c $CELERY_CONCURRENCY -l $LOGLEVEL worker --pidfile /var/lib/celery.pid

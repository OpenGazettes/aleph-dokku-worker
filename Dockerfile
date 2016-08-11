FROM pudo/aleph

ENV ELASTICSEARCH_INDEX aleph
ENV ALEPH_SETTINGS /aleph/contrib/docker_settings.py
ENV ZA_GAZETTE_ARCHIVE_URI http://s3-eu-west-1.amazonaws.com/code4sa-gazettes/archive/

COPY requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

RUN mkdir /app
COPY CHECKS /app/CHECKS

COPY celery_config.py /aleph/celery_config.py
WORKDIR /aleph

CMD newrelic-admin run-program celery -A aleph.queue worker -c $CELERY_CONCURRENCY --config=celery_config -l INFO --logfile=/var/log/celery.log

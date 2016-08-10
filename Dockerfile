FROM pudo/aleph

ENV ELASTICSEARCH_INDEX aleph
ENV ALEPH_SETTINGS /aleph/contrib/docker_settings.py
ENV ZA_GAZETTE_ARCHIVE_URI http://s3-eu-west-1.amazonaws.com/code4sa-gazettes/archive/

COPY requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

WORKDIR /aleph

CMD newrelic-admin run-program celery -A aleph.queue worker -c 10 -l INFO --logfile=/var/log/celery.log

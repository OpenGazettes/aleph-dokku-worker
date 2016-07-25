FROM pudo/aleph:latest

ENV ELASTICSEARCH_INDEX aleph
ENV ALEPH_SETTINGS /aleph/contrib/docker_settings.py

RUN pip install newrelic==2.46.0.37

RUN mkdir /app

WORKDIR /aleph

CMD newrelic-admin run-program celery -A aleph.queue worker -c 10 -l INFO --logfile=/var/log/celery.log

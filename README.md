# aleph-worker

Dokku Dockerfile deploy repo for an aleph worker

Note that logs are persistent across container restarts and are in `/var/log/aleph/celery.log`.

## Config

### Basics

# Aleph in Dokku

## Deployment

```
dokku config:set aleph-worker ALEPH_APP_NAME=opengazettes_ke \
    ALEPH_APP_TITLE="Open Gazettes Kenya" \
    ALEPH_ARCHIVE_BUCKET=cfa-opengazettes-ke \
    ALEPH_ARCHIVE_TYPE=s3 \
    ALEPH_BROKER_URI=amqp://... \
    ALEPH_DATABASE_URI=postgres://... \
    ALEPH_ELASTICSEARCH_URI=http://... \
    ALEPH_OAUTH_KEY=... \
    ALEPH_OAUTH_SECRET=... \
    ALEPH_PDF_OCR_IMAGE_PAGES=false \
    ALEPH_TIKA_URI=http://tika:9998/ \
    ALEPH_URL_SCHEME=http \
    AWS_ACCESS_KEY_ID=... \
    AWS_SECRET_ACCESS_KEY=... \
    CELERY_CONCURRENCY=4 \
    CELERYD_MAX_TASKS_PER_CHILD=1 \
    CELERY_RDBSIG=1 \
    C_FORCE_ROOT=true \
    KE_GAZETTE_ARCHIVE_URI=https://s3-eu-west-1.amazonaws.com/cfa-opengazettes-ke/gazettes/ \
    LOGLEVEL=DEBUG \
    PDF_TEXT_MODULE=tika \
    POLYGLOT_DATA_PATH=/opt/aleph/data \
    TESSDATA_PREFIX=/usr/share/tesseract-ocr
```

```
docker run -d --name=tika codeforafrica/aleph-docker-tikaserver
```

```
dokku docker-options:add aleph-worker run,deploy  "-v /var/log/aleph:/var/log"
dokku docker-options:add aleph-worker run,deploy  "-v /var/lib/aleph:/opt/aleph/data"
dokku docker-options:add aleph-worker run,deploy  "--link tika"
```


To conserve resources, don't use zero-downtime deployment. Since this can
consume a lot of memory, we don't want two instances with all their workers
running concurrently and there aren't web users seeing downtime.

    dokku checks:disable aleph-worker

Tuning performance for the available resources is extremely important.
Since this is a CPU and RAM intensive task, you don't want to over-utilise
but compute is expensive to try to utilise well.

For a machine with _n_ cores you can spare for this work, it's probably
best to use _n_ workers

    CELERY_CONCURRENCY=4

Python processes apparently don't release memory very well, and this is
shelling out to other things like tesseract, so you have to cycle worker
processes. Start small, say at `CELERYD_MAX_TASKS_PER_CHILD=2` and raise
this carefully. Letting workers exhaust your memory will make your machine
unreachable indefinitely and you'll probably have to do a hard reset which
could make docker so upset you have to reinstall it.

On a machine with 8GB RAM and CELERY_CONCURRENCY=4 running nothing else,
I found `CELERYD_MAX_TASKS_PER_CHILD=5` to work well, utilising up to about
6GB while ingesting already-OCR'd gazette PDFs.

The NewRelic monitoring seems to have significant setup overhead so you
want to have this as high as you can manage without making the machine
unusable for hours.

## Debugging / troubleshooting

To figure out what a worker process is doing, use Celery's rdb. Send SIGUSR2 to the process and connect to a pdb session using telnet, as described at http://docs.celeryproject.org/en/v2.3.3/tutorials/debugging.html#enabling-the-breakpoint-signal. This will pause execution until you continue it in pdb or exit pdb.

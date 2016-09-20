# aleph-worker

Dokku Dockerfile deploy repo for an aleph worker

## Config

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

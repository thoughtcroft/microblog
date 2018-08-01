release: flask db upgrade; flask translate compile
web: gunicorn microblog:app
worker: rq worker -u $REDIS_URL microblog-tasks


FROM python:3

RUN adduser --quiet --disabled-password --shell /bin/bash --gecos "" microblog

WORKDIR /home/microblog

COPY requirements.txt ./
RUN python -m venv venv
RUN venv/bin/pip install --upgrade pip
RUN venv/bin/pip install --no-cache-dir -r requirements.txt
RUN venv/bin/pip install gunicorn
RUN venv/bin/pip install pymysql

COPY app app
COPY migrations migrations
COPY microblog.py ./
COPY config.py ./
COPY scripts/boot.sh ./
RUN chmod +x boot.sh

ENV FLASK_APP microblog.py

RUN chown -R microblog:microblog ./
USER microblog

EXPOSE 5000
ENTRYPOINT ["./boot.sh"]

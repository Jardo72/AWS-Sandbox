FROM python:3

COPY ./requirements.txt /app/requirements.txt
COPY ./*.py /app
COPY ./config.json /app

WORKDIR /app
RUN pip3 install --no-cache-dir -r requirements.txt

EXPOSE 80

CMD ["python3", "application.py", "config.json"]

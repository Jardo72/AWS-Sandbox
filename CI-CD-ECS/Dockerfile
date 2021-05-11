FROM python:3

WORKDIR /usr/src/app

COPY requirements.txt ./
COPY application.py ./

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 80

CMD [ "python", "application.py" ]

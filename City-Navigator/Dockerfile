FROM python:3

WORKDIR /app

COPY ./requirements.txt ./
COPY ./*.py ./
COPY ./config.json ./

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 80

CMD ["python", "application.py", "config.json"]

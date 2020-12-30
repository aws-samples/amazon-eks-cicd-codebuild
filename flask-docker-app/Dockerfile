FROM python:3.7.4-alpine3.10

RUN pip install flask

ENV FLASK_APP app.py

ENV PLATFORM 'Amazon EKS'

WORKDIR /app
COPY . /app/

CMD ["python", "app.py"]

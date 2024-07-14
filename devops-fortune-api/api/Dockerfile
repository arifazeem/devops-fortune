FROM python:3.7-alpine3.12

RUN mkdir -p /app

WORKDIR /app 

COPY main.py requirements.txt ./

RUN pip install -r requirements.txt

EXPOSE 8080

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]

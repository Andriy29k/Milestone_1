FROM python:3.11-alpine

WORKDIR /app

COPY requirements.txt .

RUN apk add --no-cache gcc musl-dev linux-headers \
    && pip install --no-cache-dir -r requirements.txt \
    && apk del gcc musl-dev linux-headers

COPY . .

EXPOSE 5000

CMD ["python", "app.py"]
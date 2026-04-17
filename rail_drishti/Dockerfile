FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY backend/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend source
COPY backend/ /app/backend/

# Copy frontend
COPY frontend/ /app/frontend/

# Copy ALL data files into the image
COPY data/stations.json              /app/data/stations.json
COPY data/train_delay_data.csv       /app/data/train_delay_data.csv
COPY data/Train_details_22122017.csv /app/data/Train_details_22122017.csv
COPY data/schedules.json             /app/data/schedules.json

# Create models cache directory
RUN mkdir -p /app/data/models

EXPOSE 8000

ENV RAILWAYS_DATA_DIR=/app/data
ENV PYTHONPATH=/app/backend

# PORT is set automatically by Render; falls back to 8000 locally
CMD ["sh", "-c", "python -m uvicorn backend.app:app --host 0.0.0.0 --port ${PORT:-8000}"]

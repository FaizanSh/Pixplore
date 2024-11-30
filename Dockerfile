# Use the official FastAPI image with Python 3.10
FROM tiangolo/uvicorn-gunicorn-fastapi:python3.10

# Set the working directory
WORKDIR /app

# Copy requirements and install them
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire project to the container
COPY . .

# Expose the FastAPI port (default 8000)
EXPOSE 8000

# Run the app with Uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

# docker build -t fastapi-app .
# docker run -d -p 8000:8000 fastapi-app
# docker logs -f 913f0669c01ad22657477188d3f95f9f70d344aab3ed80cc6272b0a5e937f51d
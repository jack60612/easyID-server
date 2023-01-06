FROM python:3.10
WORKDIR /code

COPY ./requirements.txt /code/requirements.txt
RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

COPY ./pyapi /code/pyapi
# default port
CMD ["uvicorn", "pyapi.main:app", "--proxy-headers", "--host", "0.0.0.0", "--port", "8080"]
EXPOSE 8080
LABEL org.opencontainers.image.source=https://github.com/jack60612/easyID-server
LABEL org.opencontainers.image.description="Image for the easyID API"

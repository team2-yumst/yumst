FROM python:3.9-slim
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
RUN python3 manage.py collectstatic --noinput
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:8000", "yumsRec.wsgi:application"] 
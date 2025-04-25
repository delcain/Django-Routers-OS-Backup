import os
from celery import Celery

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'django_routeros_backup.settings')

app = Celery('django_routeros_backup')
app.config_from_object('django.conf:settings', namespace='CELERY')
app.autodiscover_tasks()

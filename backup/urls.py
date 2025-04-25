from django.urls import path, include
from .views import device_list, run_backup, backup_history

urlpatterns = [
    path('', device_list, name='device_list'),
    path('backup_history/<int:device_id>/', backup_history, name='backup_history'),
    path('run_backup/<int:device_id>', run_backup, name='run_backup'),
]
from celery import shared_task
from django.conf import settings
import traceback

from .models import MikrotikDevice, Backup
from .utils import backup_device
from django.core.mail import send_mail


@shared_task
def async_backup_device(device_id):
    from .models import MikrotikDevice, Backup
    device = MikrotikDevice.objects.get(id=device_id)
    backup_device(device)

@shared_task
def schedule_all_backups(*args, **kwargs):
    try:
        from .models import MikrotikDevice
        for device in MikrotikDevice.objects.all():
            device_id = device.id
            async_backup_device.delay(device_id)

            send_mail(
            subject=f'[Backup Mikrotik] Tarefa iniciada com sucesso',
            message=f'backups iniciados com sucesso.',
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[admin_email for _, admin_email in settings.ADMINS],
        )
    except Exception as e:
        error_msg = traceback.format_exc()
        send_mail(
            subject=f'[Backup Mikrotik] Erro ao iniciar tarefa de backup',
            message=f'Erro: {error_msg}',
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[admin_email for _, admin_email in settings.ADMINS],
        )
        raise
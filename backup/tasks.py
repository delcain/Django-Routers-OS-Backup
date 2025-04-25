from celery import shared_task
from .models import MikrotikDevice, Backup
from .utils import backup_device

@shared_task
def async_backup_device(device_id):
    from .models import MikrotikDevice, Backup
    device = MikrotikDevice.objects.get(id=device_id)
    backup_device(device)

@shared_task
def schedule_all_backups(*args, **kwargs):
    from .models import MikrotikDevice
    for device in MikrotikDevice.objects.all():
        device_id = device.id
        async_backup_device.delay(device_id)

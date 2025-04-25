from django.shortcuts import render
from django.shortcuts import render, redirect, get_object_or_404
from django.contrib import messages
from django.contrib.auth.decorators import login_required
from .models import MikrotikDevice
from .tasks import async_backup_device
from .utils import backup_device

@login_required(login_url='/admin/')
def device_list(request):
    devices = MikrotikDevice.objects.all()
    return render(request, 'device_list.html', {'devices': devices})

@login_required
def run_backup(request, device_id):
    device = get_object_or_404(MikrotikDevice, id=device_id)
    
    if request:
        backup_device(device)

    async_backup_device.delay(device_id)  # Enqueue the backup task
    messages.info(request, 'Você receberá uma notificação quando o backup for concluído.')
    return redirect('device_list')

@login_required
def backup_history(request, device_id):
    device = get_object_or_404(MikrotikDevice, id=device_id)
    backups = device.backups.order_by('-created_at')
    return render(request, 'backup_history.html', {'device': device, 'backups': backups})
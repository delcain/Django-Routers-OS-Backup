from django.utils.html import format_html
from django.urls import path
from django.shortcuts import redirect
from django.urls import reverse
from django.contrib import admin
from .models import MikrotikDevice, Backup
from .tasks import backup_device  # ou a função de backup direto se não usar Celery
from django.contrib import messages
from upgrade.views import upgrade_by_id


@admin.action(description="Fazer backup agora")
def fazer_backup(modeladmin, request, queryset):
    for device in queryset:
        backup_device(device) 
        messages.info(request, f'Backup agendado para {device.name}')

@admin.action(description="Iniciar upgrade")
def upgrade(modeladmin, request, queryset):
    for device in queryset:
        return redirect('upgrade_by_id', device_id=device.id)
    messages.info(request, 'Upgrade iniciado para os dispositivos selecionados.')


@admin.register(MikrotikDevice)
class MikrotikDeviceAdmin(admin.ModelAdmin):
    list_display = ('name', 'ip_address', 'dns', 'created_at', 'fazer_backup_button', 'upgrade_button')
    search_fields = ('name', 'ip_address')
    list_filter = ('created_at',)
    ordering = ('-created_at',)
    actions = [fazer_backup]
    actions = [upgrade]

    def fazer_backup_button(self, obj):
        url = reverse('admin:fazer_backup_view', args=[obj.id])
        return format_html('<a class="button" href="{}">Fazer Backup</a>', url)
    
    fazer_backup_button.short_description = 'Backup'
    fazer_backup_button.allow_tags = True

    def upgrade_button(self, obj):
        url = reverse('admin:fazer_backup_view', args=[obj.id])
        return format_html('<a class="button" href="{}">Upgrade</a>', url)
    
    upgrade_button.short_description = 'Upgrade'
    upgrade_button.allow_tags = True
    
    
    
    
    
    def get_urls(self):
        urls = super().get_urls()
        custom_urls = [
            path(
                'fazer-backup/<int:device_id>/',
                self.admin_site.admin_view(self.fazer_backup_view),
                name='fazer_backup_view',
            ),
        ]
        return custom_urls + urls

    def fazer_backup_view(self, request, device_id):
        device = MikrotikDevice.objects.get(pk=device_id)
        backup_device(device) 
        self.message_user(request, f'Backup de {device.name} agendado com sucesso!', level=messages.INFO)
        return redirect('admin:backup_mikrotikdevice_changelist')
    
    def upgrade(self, request, queryset):
        for device in queryset:
            return redirect('upgrade_by_id', device_id=device.id)
        messages.info(request, 'Upgrade iniciado para os dispositivos selecionados.')
    


@admin.register(Backup)
class BackupAdmin(admin.ModelAdmin):
    list_display = ('device', 'file', 'created_at')
    search_fields = ('device__name', 'file')
    list_filter = ('created_at',)
    ordering = ('-created_at',)
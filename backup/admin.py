from django.contrib import admin
from .models import MikrotikDevice, Backup


@admin.register(MikrotikDevice)
class MikrotikDeviceAdmin(admin.ModelAdmin):
    list_display = ('name', 'ip_address', 'dns', 'created_at')
    search_fields = ('name', 'ip_address')
    list_filter = ('created_at',)
    ordering = ('-created_at',)

@admin.register(Backup)
class BackupAdmin(admin.ModelAdmin):
    list_display = ('device', 'file', 'created_at')
    search_fields = ('device__name', 'file')
    list_filter = ('created_at',)
    ordering = ('-created_at',)
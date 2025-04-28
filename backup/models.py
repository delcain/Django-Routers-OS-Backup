from django.db import models

class MikrotikDevice(models.Model):
    name = models.CharField(max_length=100)
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    dns = models.CharField(max_length=100, null=True, blank=True)
    api_port = models.IntegerField(default=8728)
    ssh_port = models.IntegerField(default=22)
    username = models.CharField(max_length=100)
    password = models.CharField(max_length=100)  # Encrypt in production
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name

class Backup(models.Model):
    STATUS_CHOICES = (
        ('success', 'Sucesso'),
        ('error', 'Erro'),
    )
    device = models.ForeignKey(MikrotikDevice, on_delete=models.CASCADE, related_name='backups')
    file = models.FileField(upload_to='backups/', null=True, blank=True)
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='success')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.device.name} - {self.created_at.strftime('%Y-%m-%d %H:%M:%S')}"
    
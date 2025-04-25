import paramiko
from django.core.files.base import ContentFile
from .models import Backup
from datetime import datetime
from routeros_api import RouterOsApiPool
import os
from django.core.mail import mail_admins


def backup_device(device):
    try:
        # Conectando via API para gerar o backup
        connection = RouterOsApiPool(
            host=device.dns if device.dns else device.ip_address,
            username=device.username,
            password=device.password,
            port=device.port,
            use_ssl=False,
            plaintext_login=True
        )
        api = connection.get_api()

        filename = f"{device.name}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.rsc"
        api.get_resource('/').call('export', {'file': filename})
        # api.get_resource('/system/backup').call('save', {'name': filename})
        connection.disconnect()

        # Agora faz o download via SFTP
        if device.dns is None:
            device.dns = device.ip_address
        transport = paramiko.Transport((device.dns, 22))  # Mikrotik precisa de SFTP habilitado
        transport.connect(username=device.username, password=device.password)
        sftp = paramiko.SFTPClient.from_transport(transport)

        local_path = f"{filename}"
        remote_path = f"/{filename}"
        sftp.get(remote_path, local_path)
        sftp.remove(remote_path)
        sftp.close()
        transport.close()

        # Salva o arquivo no banco de dados
        with open(local_path, 'rb') as f:
            django_file = ContentFile(f.read(), name=filename)
            Backup.objects.create(device=device, file=django_file)

        os.remove(local_path)

        return True
    except Exception as e:
        Backup.objects.create(device=device, status='error')
        
        mail_admins(
            subject=f'❌ Falha no backup do dispositivo {device.name}',
            message=f'O backup do dispositivo --> {device.name} <-- ({device.ip_address}) falhou.\n\nErro: {str(e)}'
                    )
        
        print(f"Falha no backup do dispositivo {device.name}. \nO backup do dispositivo {device.name} ({device.ip_address}) falhou.")
        return False

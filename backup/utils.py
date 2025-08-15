import os
import paramiko
from django.core.files.base import ContentFile
from .models import Backup
from datetime import datetime
from django.utils.timezone import now

from django.core.mail import mail_admins

from routeros_api import RouterOsApiPool

def backup_device(device):
    try:
        # Conectando via API para gerar o backup
        connection = RouterOsApiPool(
            host=device.dns if device.dns else device.ip_address,
            username=device.username,
            password=device.password,
            port=device.api_port,
            use_ssl=False,
            plaintext_login=True
        )
        api = connection.get_api()

        system_resource = api.get_resource('/system/resource')
        resource_info = system_resource.get()
        
        if resource_info and 'version' in resource_info[0]:

            device.version = resource_info[0]['version']
            print(device.version)
            device.save(update_fields=['version'])



        filename = f"{device.name}_{datetime.now().strftime('%Y%m%d_%H%M')}.rsc"
        api.get_resource('/').call('export', {'file': filename})
        connection.disconnect()

        # Agora faz o download via SFTP
        if device.dns is None:
            device.dns = device.ip_address
            device.ssh_port = device.ssh_port
        transport = paramiko.Transport((device.dns, device.ssh_port))  # Mikrotik precisa de SFTP habilitado
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
        
        print(f"Falha no backup do dispositivo {device.name}. \nErro: {str(e)}")
        return False

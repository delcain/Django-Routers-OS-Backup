import librouteros
from django.shortcuts import render, get_object_or_404, HttpResponse
from django.contrib.auth.decorators import login_required
from django.http import HttpResponse
from .utils import checa_versao, download_update, upgrade_firmware
from backup.models import MikrotikDevice, Backup


@login_required
def upgrade_home(request):
    mk = MikrotikDevice.objects.all().order_by('version')
    return render(request, 'upgrade/home.html', {'mk': mk})

@login_required
def upgrade_by_id(request, device_id):
    
    u = get_object_or_404(MikrotikDevice, id=device_id)
    
    try: #Inicia a conexão com o roteador
        api = librouteros.connect(host=u.dns, username=u.username, password=u.password, port=u.api_port, timeout=10)
    except Exception as e:
        print(f"Erro ao conectar ao roteador: {e}")
        return HttpResponse(f"Erro ao conectar ao roteador. {e}")

    if checa_versao(api): # Verifica se há uma atualização disponível
        print("Atualização disponível. Iniciando download...")
        
        if download_update(api): # Inicia o download da atualização
            print("Reiniciando o roteador...")
            return HttpResponse("Download concluído e roteador reiniciado.")
        
    if upgrade_firmware(api): # Realiza o upgrade do firmware
        print("Upgrade a de firmware concluído. Roteador reiniciado.")
        return HttpResponse("Upgrade a de firmware concluído. Roteador reiniciado.")
    else: # Encerra o processo se não houver atualização
        print("Sistema já está atualizado.")
        return HttpResponse("Sistema já está atualizado.")
import time
import librouteros

def checa_versao(api):
    try:
        package = api.path('/system/package/update')
        updates = list(package(cmd='check-for-updates'))
        update_info = updates[1]
        
        latest_version = update_info.get('latest-version', 'N/A')
        installed_version = update_info.get('installed-version', 'N/A')

        print(f"Versão instalada: {installed_version}")
        print(f"Versão mais recente: {latest_version}")
        return True if latest_version != 'N/A' and latest_version != installed_version else False
    except Exception as e:
        print(f"Erro ao verificar versão: {e}")
        return False

def download_update(api):
    try:
        print("Iniciando download da atualização...")
        package = api.path('/system/package/update')
        list(package(cmd='download'))
        while True:
            time.sleep(1)
            status_list = list(package.select())
            for s in status_list:
                if 'downloaded' in s.get('status', '').lower():
                    print("Download concluído")
                    list(api(cmd='/system/reboot'))
                    return True
    except Exception as e:
        print(f"Erro ao baixar atualização: {e}")
        return False
    
def upgrade_firmware(api):
    try:
        routerboard = api.path('/system/routerboard')
        info = list(routerboard.select())[0]

        current_fw = info.get('current-firmware')
        upgrade_fw = info.get('upgrade-firmware')

        print(f"Firmware atual: {current_fw}")
        print(f"Firmware disponível: {upgrade_fw}")

        if upgrade_fw and upgrade_fw != current_fw:
            print("Atualização disponível. Iniciando upgrade de firmware...")
            list(routerboard(cmd='upgrade'))
            time.sleep(3)
            list(api(cmd='/system/reboot'))
            api.close()
            print("Roteador reiniciado após upgrade de firmware.")
            return True
    except Exception as e:
        print(f"Erro ao fazer upgrade de firmware: {e}")
        return False
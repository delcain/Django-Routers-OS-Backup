import librouteros
import time
import sys

api = librouteros.connect(
    host="wtc.cuidadodigital.net.br",
    username="admin",
    password="Wtc@Keycode#123",
    port=8728,
    timeout=10
)

list(api(cmd='/system/reboot'))



    # try:
    #     package = api.path('/system/package/update')
    #     package('download')

    #     status_list = list(package.select())
    #     if not status_list:
    #         print("Nenhum pacote encontrado para download.")
    #         return False
        
    #     while True:
    #         time.sleep(1)
    #         status_list = list(package.select())
                                
    #         if status_list:
    #             status = status_list[0]
    #             print(status) 
                    
    #             if 'status' in status:
    #                 current_status = status['status']
    #                 print(f"Status do download: {current_status}")
                        
    #                 if current_status == 'Downloaded':
    #                     print("Download concluído com sucesso!")
    #                     return True
    #                 elif 'failed' in current_status.lower() or 'error' in current_status.lower():
    #                     print(f"Falha no download: {current_status}")
    #                     return False
    #             else:
    #                 # Verifica se há pacotes baixados
    #                 if 'downloaded' in str(status).lower():
    #                     print("Download aparentemente concluído")
    #                     return True
    #         else:
    #             break
    #         return True
            
    # except Exception as e:
    #     return False
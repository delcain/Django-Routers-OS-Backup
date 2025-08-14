import librouteros
import time
import logging
import sys

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('mikrotik_update.log'),
        logging.StreamHandler(sys.stdout)
    ]
)

class MikroTikUpdater:
    def __init__(self, host, username, password, port):
        self.host = host
        self.username = username
        self.password = password
        self.port = int(port)
        self.api = None
        self.logger = logging.getLogger(__name__)

    def connect(self):
          """Conecta ao roteador MikroTik"""
          try:
               self.api = librouteros.connect(
                    host=self.host,
                    username=self.username,
                    password=self.password,
                    port=self.port,
                    timeout=10
               )
               self.logger.info(f"Conectado ao MikroTik {self.host}")
               return True
          except Exception as e:
               self.logger.error(f"Erro ao conectar: {e}")
               return False
    
    def disconnect(self):
          """Desconecta do roteador"""
          if self.api:
               self.api.close()
               self.logger.info("Desconectado do MikroTik")

    def check_for_updates(self):
          """Verifica se há atualizações disponíveis"""
          try:
               # Atualiza a lista de pacotes disponíveis
               package = self.api.path('/system/package/update')
               package('check-for-updates')

               # Aguarda a verificação completar
               time.sleep(3)
               
               # Obtém informações sobre atualizações
               updates = list(package.select())
               if updates:
                    update_info = updates[0]
                    latest_version = update_info.get('latest-version', 'N/A')
                    installed_version = update_info.get('installed-version', 'N/A')
                    
                    self.logger.info(f"Versão instalada: {installed_version}")
                    self.logger.info(f"Versão mais recente: {latest_version}")
                    
                    # Verifica se há atualização disponível
                    if latest_version != 'N/A' and latest_version != installed_version:
                         self.logger.info("Atualização disponível!")
                         return True, latest_version, installed_version
                    else:
                         self.logger.info("Sistema já está atualizado")
                         return False, latest_version, installed_version
               else:
                    self.logger.warning("Não foi possível verificar atualizações")
                    return False, None, None
                    
          except Exception as e:
               self.logger.error(f"Erro ao verificar atualizações: {e}")
               return False, None, None

    def download_update(self):
        """Faz download da atualização"""
        try:
            self.logger.info("Iniciando download da atualização...")
            package = self.api.path('/system/package/update')
            package('download')

            # Monitora o progresso do download
            while True:
                time.sleep(3)
                status_list = list(package.select())
                
                if status_list:
                    status = status_list[0]
                    
                    if 'status' in status:
                        current_status = status['status']
                        self.logger.info(f"Status do download: {current_status}")
                        
                        if current_status == 'Downloaded, please reboot router to upgrade it':
                            self.logger.info("Download concluído com sucesso!")
                            return True
                        
                        elif 'failed' in current_status.lower() or 'error' in current_status.lower():
                            self.logger.error(f"Falha no download: {current_status}")
                            return False
                    else:
                        # Verifica se há pacotes baixados
                        if 'Downloaded, please reboot router to upgrade it' in str(status).lower():
                            self.logger.info("Download aparentemente concluído")
                            return True
                else:
                    self.logger.warning("Não foi possível obter status do download")
                    break
            return True
            
        except Exception as e:
            self.logger.error(f"Erro durante o download: {e}")
            return False
        return True

    def install_update(self):
        """Instala a atualização baixada"""
        try:
            self.logger.info("Iniciando instalação da atualização...")
            self.logger.warning("ATENÇÃO: O roteador será reinicializado!")
            
            package = self.api.path('/system/package/update')
            package('install')
            
            self.logger.info("Comando de instalação enviado. Roteador reiniciando...")
            
            list(package(cmd='/system/reboot'))

            return True
            
        except Exception as e:
            self.logger.error(f"Erro durante a instalação: {e}")
            return False
        
    def install_upgrade(self):
     """Realiza o Upgrade do MikroTik"""
     try:
          self.logger.info("Iniciando o upgrade")
          self.logger.warning("ATENÇÃO: O roteador será reinicializado!")
                   
          package = self.api.path('/system/routerboard')
          package('upgrade')
          
          package = self.api.path('/system')
          package('reboot')
            
          self.logger.info("Comando de upgrade enviado. Roteador reiniciando...")
          return True

     except Exception as e:
          self.logger.error(f"Erro durante a instalação: {e}")
          return False
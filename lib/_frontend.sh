#!/bin/bash

# Functions for setting up app frontend

#######################################
# Install node packages for frontend
# Arguments: None
#######################################
frontend_node_dependencies() {
  print_banner
  printf "${WHITE} 💻 Instalando dependências do frontend...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deployautomatizaai <<EOF
  cd /home/deployautomatizaai/whaticket/frontend
  npm install --force
EOF
 
  sleep 2
}

#######################################
# Set frontend environment variables
# Arguments: None
#######################################
frontend_set_env() {
  print_banner
  printf "${WHITE} 💻 Configurando variáveis de ambiente (frontend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  backend_url=$(echo "${backend_url/https:\/\/}")
  backend_url=${backend_url%%/*}
  backend_url=https://$backend_url

  sudo su - deployautomatizaai << EOF
  cat <<[-]EOF > /home/deployautomatizaai/whaticket/frontend/.env
REACT_APP_BACKEND_URL=${backend_url}
REACT_APP_ENV_TOKEN=210897ugn217204u98u8jfo2983u5
REACT_APP_HOURS_CLOSE_TICKETS_AUTO=9999999
REACT_APP_FACEBOOK_APP_ID=1005318707427295
REACT_APP_NAME_SYSTEM=automatizaai
REACT_APP_VERSION="1.0.0"
REACT_APP_PRIMARY_COLOR=#ffffff
REACT_APP_PRIMARY_DARK=2c3145
REACT_APP_NUMBER_SUPPORT=51997059551
SERVER_PORT=3333
WDS_SOCKET_PORT=0
[-]EOF
EOF

  sudo su - deployautomatizaai <<EOF
  cd /home/deployautomatizaai/whaticket/frontend

  BACKEND_URL=${backend_url}

  sed -i "s|https://autoriza.dominio|\$BACKEND_URL|g" \$(grep -rl 'https://autoriza.dominio' .)
EOF

  sleep 2
}

#######################################
# Start pm2 for frontend
# Arguments: None
#######################################
frontend_start_pm2() {
  print_banner
  printf "${WHITE} 💻 Iniciando pm2 (frontend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deployautomatizaai <<EOF
  cd /home/deployautomatizaai/whaticket/frontend
  pm2 start server.js --name whaticket-frontend
  pm2 save
EOF

  sleep 2
}

#######################################
# Set up nginx for frontend
# Arguments: None
#######################################
frontend_nginx_setup() {
  print_banner
  printf "${WHITE} 💻 Configurando nginx (frontend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  frontend_hostname=$(echo "${frontend_url/https:\/\/}")

  sudo su - root << EOF

  cat > /etc/nginx/sites-available/whaticket-frontend << 'END'
server {
  server_name $frontend_hostname;

  location / {
    proxy_pass http://127.0.0.1:3333;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_cache_bypass \$http_upgrade;
  }
}
END

  ln -s /etc/nginx/sites-available/whaticket-frontend /etc/nginx/sites-enabled
EOF

  sleep 2
}

#######################################
# Move whaticket files
# Arguments: None
#######################################
move_whaticket_files() {
  print_banner
  printf "${WHITE} 💻 Movendo arquivos do WhaTicket...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  sudo mkdir -p /home/deployautomatizaai/whaticket/backup/backend
  sudo mkdir -p /home/deployautomatizaai/whaticket/backup/frontend

  sudo rm -r /home/deployautomatizaai/whaticket/backup/frontend/automatizaai
  sudo rm -r /home/deployautomatizaai/whaticket/backup/backend/automatizaai

  sudo mv /home/deployautomatizaai/whaticket/frontend/automatizaai /home/deployautomatizaai/whaticket/backup/frontend/
  sudo mv /home/deployautomatizaai/whaticket/backend/automatizaai /home/deployautomatizaai/whaticket/backup/backend/
  
  sudo rm -r /home/deployautomatizaai/whaticket/frontend/package.json
  sudo rm -r /home/deployautomatizaai/whaticket/frontend/package-lock.json
  sudo rm -r /home/deployautomatizaai/whaticket/backend/package.json
  sudo rm -r /home/deployautomatizaai/whaticket/backend/package-lock.json

  sudo rm -rf /home/deployautomatizaai/whaticket/frontend/node_modules
  sudo rm -rf /home/deployautomatizaai/whaticket/backend/node_modules

  sudo mv /root/whaticket/frontend/automatizaai /home/deployautomatizaai/whaticket/frontend
  sudo mv /root/whaticket/frontend/package.json /home/deployautomatizaai/whaticket/frontend
  sudo mv /root/whaticket/backend/ecosystem.config.js /home/deployautomatizaai/whaticket/backend
  sudo mv /root/whaticket/backend/automatizaai /home/deployautomatizaai/whaticket/backend
  sudo mv /root/whaticket/backend/package.json /home/deployautomatizaai/whaticket/backend
  sudo rm -rf /root/whaticket
  npm cache clean --force
  sudo apt update
  sudo apt install ffmpeg
EOF
  sleep 2
}

#######################################
# Restart pm2 for frontend
# Arguments: None
#######################################
frontend_restart_pm2() {
  print_banner
  printf "${WHITE} 💻 Reiniciando pm2 (frontend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deployautomatizaai <<EOF
  cd /home/deployautomatizaai/whaticket/frontend
  pm2 delete whaticket-frontend
  pm2 start server.js --name whaticket-frontend -i max
  pm2 save
EOF

  sleep 2
}

# Outras funções podem ser incluídas aqui conforme necessário

echo "${GREEN}Sistema Atualizado Com Sucesso!${NORMAL}"

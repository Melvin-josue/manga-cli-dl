#!/bin/bash

# ----- Script para instalar manga desde la terminal. -------

set -e

# ------ Colores para la salida ---------
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # Sin color

# ----- Creación de directorios necesarios -----
echo "${BLUE}}[+] Creando directorios necesarios...${NC}"

mkdir -p $HOME/.local/share/manga-cli-dl
mkdir -p $HOME/.local/share/manga-cli-dl/output
mkdir -p $HOME/.local/share/manga-cli-dl/output/results
mkdir -p $HOME/.local/share/manga-cli-dl/downloads
mkdir -p $HOME/.local/python-lib

echo "${GREEN}[+] Copiando archivos necesarios...${NC}"
cp -r ./src/* $HOME/.local/share/manga-cli-dl/src/
cp -r ./tools/* $HOME/.local/share/manga-cli-dl/tools/
cp ./main /usr/local/bin/

echo "${GREEN}[+] Creacion completa...${NC}"

# ----- Dependencies installation -------

echo "${GREEN}[+] Instalando dependencias...${NC}"

pip install --upgrade pip
pip install --target=$HOME/.local/python-lib -r ./requirements.txt

echo "${GREEN}[+] Instalación completada con éxito.${NC}"

# ------- Configuración del Python Path -------
SHELL_RC="$HOME/.bashrc"
if [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
fi

if ! grep -q "PYTHONPATH" "$SHELL_RC"; then 
    echo "${GREEN}[+] Configurando PYTHONPATH...${NC}"
    echo 'export PYTHONPATH="$HOME/.local/python-lib:$PYTHONPATH"' >> "$SHELL_RC"
    echo "${GREEN}[+]python añadido al PATH...${NC}"
else
    echo "${YELLOW}[!] PYTHONPATH ya está configurado.${NC}"
fi

# ------ Dependencias de sistema ------
echo "${GREEN}[+] Instalando dependencias del sistema...${NC}"


deps=("python3" "python3-pip" "curl" "fzf" "grep" "aria2c" "wget" "zip")

# --- Detectar la distribución del sistema ----
detected_distro(){
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID" # retorna el ID de la distribución
    else
        uname -s
    fi
}

# --- Instalación de dependencias según la distribución ---
install_deps() {
local distro="$1"
local pakage_manager=""
local install_command=""

case "${distro}" in 
    arch|manjaro|endeavouros|artix|garuda)
        pakage_manager="pacman"
        install_command="sudo pacman -Sy --noconfirm"
        ;;
    debian|ubuntu|linuxmint|pop|kali|raspbian|elementary)
        pakage_manager="apt"
        install_command="sudo apt-get install -y"
        ;;
    fedora|centos|rhel)
        pakage_manager="dnf"
        install_command="sudo dnf install -y"
        ;;
    opensuse|suse)
        pakage_manager="zypper"
        install_command="sudo zypper install -y"
        ;;
    void|alpine)
        pakage_manager="apk"
        install_command="sudo apk add"
        ;;
    gentoo)
        pakage_manager="emerge"
        install_command="sudo emerge --ask"
        ;;
    *)
        echo "${YELLOW}[!] Distribución no reconocida. Instalación manual de dependencias requerida.${NC}"
        exit 1
        ;;
esac

echo "${GREEN}[+] Instalando dependencias del sistema con ${pakage_manager}...${NC}"

for dep in "${deps[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        echo "${YELLOW}[!] Instalando $dep...${NC}"
        $install_command "$dep"
    else
        echo "${GREEN}[+] $dep ya está instalado.${NC}"
    fi
done
}

# ----- Llamada a la función de instalación de dependencias -----
distro=$(detected_distro)
install_deps "$distro"

# ----- Finalización -----
echo "${GREEN}[+] Instalación completada. Puedes ejecutar 'manga-cli-dl' para comenzar.${NC}"
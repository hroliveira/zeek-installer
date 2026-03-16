#!/usr/bin/env bash

set -Eeuo pipefail

########################################
# CONFIGURAÇÕES
########################################

REPO_URL="https://github.com/hroliveira/zeek.git"
INSTALL_DIR="/opt/zeek"
BUILD_DIR="/tmp/zeek-build"
LOG_FILE="/tmp/zeek-install.log"

TOTAL_STEPS=6
CURRENT_STEP=0

########################################
# LOGGING
########################################

log() {
    echo -e "[INFO] $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "[ERROR] $1" | tee -a "$LOG_FILE"
}

########################################
# PROGRESS BAR
########################################

progress() {
    CURRENT_STEP=$((CURRENT_STEP+1))
    PERCENT=$((CURRENT_STEP*100/TOTAL_STEPS))

    echo ""
    echo "======================================"
    echo "Step $CURRENT_STEP/$TOTAL_STEPS ($PERCENT%)"
    echo "$1"
    echo "======================================"
}

########################################
# ROLLBACK
########################################

rollback() {
    error "Erro detectado. Iniciando rollback..."

    if [ -d "$INSTALL_DIR" ]; then
        log "Removendo instalação parcial..."
        sudo rm -rf "$INSTALL_DIR"
    fi

    if [ -d "$BUILD_DIR" ]; then
        log "Removendo diretório de build..."
        rm -rf "$BUILD_DIR"
    fi

    error "Rollback concluído."
    error "Verifique o log em: $LOG_FILE"
}

trap rollback ERR

########################################
# DETECTAR DISTRO
########################################

detect_distro() {

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    else
        error "Não foi possível detectar a distro"
        exit 1
    fi

    log "Distribuição detectada: $DISTRO"
}

########################################
# INSTALAR DEPENDÊNCIAS
########################################

install_dependencies() {

    case "$DISTRO" in

        ubuntu|debian)

            sudo apt update

            sudo apt install -y \
                git cmake make gcc g++ \
                flex bison libpcap-dev \
                libssl-dev python3 python3-dev \
                swig zlib1g-dev
            ;;

        rocky|rhel|centos|almalinux)

            sudo dnf install -y \
                git cmake make gcc gcc-c++ \
                flex bison libpcap-devel \
                openssl-devel python3-devel \
                swig zlib-devel
            ;;

        arch)

            sudo pacman -Sy --noconfirm \
                git cmake make gcc \
                flex bison libpcap \
                openssl python \
                swig zlib
            ;;

        *)

            error "Distribuição não suportada: $DISTRO"
            exit 1
            ;;
    esac
}

########################################
# CLONAR REPOSITÓRIO
########################################

clone_repo() {

    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"

    cd "$BUILD_DIR"

    git clone --recursive "$REPO_URL"

}

########################################
# CONFIGURAR BUILD
########################################

configure_build() {

    cd "$BUILD_DIR/zeek"

    ./configure --prefix="$INSTALL_DIR"

}

########################################
# COMPILAR
########################################

compile() {

    cd "$BUILD_DIR/zeek"

    make -j"$(nproc)"

}

########################################
# INSTALAR
########################################

install_zeek() {

    cd "$BUILD_DIR/zeek"

    sudo make install

}

########################################
# LIMPEZA FINAL
########################################

cleanup() {

    rm -rf "$BUILD_DIR"

}

########################################
# EXECUÇÃO
########################################

echo "======================================"
echo " Zeek Automatic Installer"
echo "======================================"

progress "Detectando distribuição"
detect_distro | tee -a "$LOG_FILE"

progress "Instalando dependências"
install_dependencies | tee -a "$LOG_FILE"

progress "Clonando repositório"
clone_repo | tee -a "$LOG_FILE"

progress "Configurando compilação"
configure_build | tee -a "$LOG_FILE"

progress "Compilando Zeek"
compile | tee -a "$LOG_FILE"

progress "Instalando Zeek"
install_zeek | tee -a "$LOG_FILE"

cleanup

echo ""
echo "======================================"
echo " Instalação concluída com sucesso"
echo "======================================"
echo ""
echo "Instalado em: $INSTALL_DIR"
echo "Log completo: $LOG_FILE"
echo ""

echo "Adicione ao PATH:"
echo "export PATH=\$PATH:$INSTALL_DIR/bin"

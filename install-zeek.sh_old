#!/usr/bin/env bash

set -e

REPO_URL="https://github.com/hroliveira/zeek.git"
INSTALL_DIR="/opt/zeek"
BUILD_DIR="/tmp/zeek-build"

echo "================================="
echo " Zeek Installer Script"
echo "================================="

# Atualizar sistema
echo "[1/6] Atualizando sistema..."
sudo apt update

# Instalar dependências
echo "[2/6] Instalando dependências..."
sudo apt install -y \
    git cmake make gcc g++ flex bison \
    libpcap-dev libssl-dev python3 python3-dev \
    swig zlib1g-dev

# Criar diretório de build
echo "[3/6] Preparando diretório..."
rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR
cd $BUILD_DIR

# Clonar repositório
echo "[4/6] Clonando repositório..."
git clone --recursive $REPO_URL
cd zeek

# Configurar build
echo "[5/6] Configurando compilação..."
./configure --prefix=$INSTALL_DIR

# Compilar
echo "[6/6] Compilando..."
make -j$(nproc)

# Instalar
echo "Instalando..."
sudo make install

echo ""
echo "================================="
echo " Zeek instalado em:"
echo " $INSTALL_DIR"
echo "================================="

echo "Adicione ao PATH:"
echo "export PATH=\$PATH:$INSTALL_DIR/bin"

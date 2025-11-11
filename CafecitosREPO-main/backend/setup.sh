#!/bin/bash

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Cafecitos API Setup Script      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════╝${NC}"
echo ""

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 1. Verificar Homebrew
echo -e "${YELLOW}[1/6]${NC} Verificando Homebrew..."
if ! command_exists brew; then
    echo -e "${RED}✗ Homebrew no está instalado${NC}"
    echo "Instalando Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo -e "${GREEN}✓ Homebrew instalado${NC}"
fi

# 2. Verificar Vapor
echo -e "${YELLOW}[2/6]${NC} Verificando Vapor..."
if ! command_exists vapor; then
    echo -e "${RED}✗ Vapor no está instalado${NC}"
    echo "Instalando Vapor..."
    brew tap vapor/tap
    brew install vapor/tap/vapor
else
    echo -e "${GREEN}✓ Vapor instalado${NC}"
fi

# 3. Verificar Swift
echo -e "${YELLOW}[3/6]${NC} Verificando Swift..."
if ! command_exists swift; then
    echo -e "${RED}✗ Swift no está instalado${NC}"
    echo "Por favor instala Xcode desde el App Store"
    exit 1
else
    SWIFT_VERSION=$(swift --version | head -n 1)
    echo -e "${GREEN}✓ Swift instalado: ${SWIFT_VERSION}${NC}"
fi

# 4. Crear estructura de directorios
echo -e "${YELLOW}[4/6]${NC} Creando estructura de directorios..."
mkdir -p Sources/App
mkdir -p Tests/AppTests
echo -e "${GREEN}✓ Directorios creados${NC}"

# 5. Verificar archivo .env
echo -e "${YELLOW}[5/6]${NC} Verificando configuración..."
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚠ Archivo .env no encontrado${NC}"
    echo "Creando .env desde .env.example..."
    
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo -e "${GREEN}✓ Archivo .env creado${NC}"
        echo -e "${RED}⚠ IMPORTANTE: Edita el archivo .env con tu contraseña de Supabase${NC}"
    else
        echo -e "${RED}✗ .env.example no encontrado${NC}"
    fi
else
    echo -e "${GREEN}✓ Archivo .env existe${NC}"
fi

# 6. Resolver dependencias
echo -e "${YELLOW}[6/6]${NC} Resolviendo dependencias..."
echo "Esto puede tardar varios minutos la primera vez..."
swift package resolve

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Dependencias resueltas${NC}"
else
    echo -e "${RED}✗ Error al resolver dependencias${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     Setup completado! 🎉           ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Próximos pasos:${NC}"
echo "1. Edita el archivo .env con tu contraseña de Supabase"
echo "2. Ejecuta: ${GREEN}swift build${NC}"
echo "3. Ejecuta: ${GREEN}swift run${NC}"
echo "4. La API estará disponible en: ${GREEN}http://localhost:8080${NC}"
echo ""
echo -e "${YELLOW}Para obtener tu contraseña de Supabase:${NC}"
echo "1. Ve a https://app.supabase.com"
echo "2. Abre tu proyecto"
echo "3. Settings → Database"
echo "4. Copia la 'Database Password'"
echo ""
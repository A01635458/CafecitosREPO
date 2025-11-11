#!/bin/bash

# Script para ejecutar Cafecitos API con variables de entorno

# Cargar variables del archivo .env
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
    echo "✓ Variables de entorno cargadas desde .env"
else
    echo "⚠️  Archivo .env no encontrado"
fi

# Ejecutar la aplicación
echo "🚀 Iniciando Cafecitos API..."
swift run

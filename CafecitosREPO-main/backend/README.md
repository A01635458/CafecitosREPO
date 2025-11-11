# Cafecitos API - Backend

API REST construida con Vapor (Swift) y Supabase REST API para la plataforma de aprendizaje Cafecitos.

## 📋 Requisitos

- macOS 13.0 o superior
- Xcode 14.0+ (para Swift 5.9)
- Swift 5.9+
- Cuenta de Supabase con base de datos PostgreSQL

## 🚀 Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/A01635458/CafecitosREPO.git
cd CafecitosREPO/backend
```

### 2. Configurar variables de entorno

Crea o edita el archivo `.env` en la raíz del proyecto con tus credenciales de Supabase:

```bash
# Supabase API Configuration
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu_anon_key_aqui

# Server Configuration
LOG_LEVEL=debug
PORT=8080
```

> ⚠️ **Importante**: Obtén estas credenciales desde tu dashboard de Supabase:
> - Ve a **Settings** → **API**
> - Copia **Project URL** para `SUPABASE_URL`
> - Copia **anon/public** key para `SUPABASE_ANON_KEY`

### 3. Compilar el proyecto

```bash
swift build
```

## 🏃 Ejecutar la API

### Opción 1: Usando el script (Recomendado)

Este script carga automáticamente las variables de entorno desde `.env`:

```bash
./run.sh
```

### Opción 2: Usando Swift directamente

Primero carga las variables de entorno manualmente:

```bash
export $(cat .env | grep -v '^#' | xargs)
swift run
```

El servidor se iniciará en: **http://127.0.0.1:8080**

## 📡 Endpoints Disponibles

### Health Check
```bash
GET /health
```

**Respuesta:**
```json
{
  "status": "ok",
  "message": "Cafecitos API running with Supabase REST"
}
```

### Información de la API
```bash
GET /
```

### Módulos
```bash
GET    /api/modules           # Listar todos los módulos
GET    /api/modules/:id       # Obtener módulo por ID
GET    /api/modules/:id/lessons # Lecciones de un módulo
```

**Ejemplo:**
```bash
curl http://localhost:8080/api/modules
```

**Respuesta:**
```json
[
  {
    "id": "55555555-5555-5555-5555-555555555555",
    "title": "Fundamentos del Café",
    "description": "Aprende sobre tipos de café, tostado y molienda.",
    "sort_order": 1,
    "is_active": true,
    "created_at": "2025-11-10T01:56:51Z"
  }
]
```

### Lecciones
```bash
GET    /api/lessons           # Listar todas las lecciones
GET    /api/lessons/:id       # Obtener lección por ID
```

### Usuarios
```bash
GET    /api/users             # Listar todos los usuarios
GET    /api/users/:id         # Obtener usuario por ID
```

## 🧪 Probar la API

### Usando curl

```bash
# Health check
curl http://localhost:8080/health

# Información de la API
curl http://localhost:8080/

# Listar módulos
curl http://localhost:8080/api/modules

# Obtener un módulo específico
curl http://localhost:8080/api/modules/55555555-5555-5555-5555-555555555555

# Listar lecciones de un módulo
curl http://localhost:8080/api/modules/55555555-5555-5555-5555-555555555555/lessons

# Listar todas las lecciones
curl http://localhost:8080/api/lessons
```

### Usando el script de pruebas

```bash
./test-api.sh
```

## 🛠️ Desarrollo

### Estructura del proyecto

```
backend/
├── Sources/
│   └── App/
│       ├── main.swift           # Punto de entrada
│       ├── configure.swift      # Configuración de la app
│       ├── routes.swift         # Registro de rutas
│       ├── SupabaseClient.swift # Cliente HTTP para Supabase
│       ├── DTOs.swift           # Data Transfer Objects
│       └── RestControllers.swift # Controladores REST
├── Tests/
│   └── AppTests/
├── Package.swift                # Dependencias
├── .env                        # Variables de entorno (no commitear)
└── run.sh                      # Script para ejecutar con .env
```

### Arquitectura

La API utiliza **Supabase REST API** en lugar de conexiones directas a PostgreSQL:

1. **SupabaseClient**: Cliente HTTP personalizado que interactúa con la REST API de Supabase
2. **DTOs**: Estructuras simples para serialización JSON sin dependencias de ORM
3. **RestControllers**: Controladores que usan el cliente HTTP para obtener/enviar datos

### Modelos de datos

- **Module**: Módulos de aprendizaje sobre café
- **Lesson**: Lecciones dentro de módulos
- **User**: Usuarios del sistema
- **Photo**: Fotos de café para reconocimiento (futuro)
- **Note**: Notas creadas por usuarios
- **UserLessonProgress**: Progreso de usuarios en lecciones

## � Seguridad (Supabase RLS)

La API usa Row Level Security (RLS) de Supabase:

- ✅ **Lectura pública**: Todos pueden leer módulos, lecciones, usuarios
- 🔒 **Escritura autenticada**: Solo usuarios autenticados pueden crear/modificar datos

Para configurar RLS en Supabase:

```sql
-- Habilitar RLS
ALTER TABLE modules ENABLE ROW LEVEL SECURITY;

-- Permitir lectura pública
CREATE POLICY "Public read access" ON modules 
FOR SELECT USING (true);

-- Requiere autenticación para escritura
CREATE POLICY "Authenticated insert" ON modules 
FOR INSERT WITH CHECK (auth.role() = 'authenticated');
```

## 🔧 Troubleshooting

### Error: "Invalid API key"

Verifica que:
1. La `SUPABASE_ANON_KEY` en `.env` sea correcta
2. La clave sea del proyecto correcto en Supabase
3. El proyecto de Supabase esté activo (no pausado)

### Error: "401 Unauthorized"

Verifica que:
1. Las políticas de RLS estén configuradas correctamente
2. La tabla tenga una política `FOR SELECT USING (true)` para lectura pública

### El servidor no inicia

Asegúrate de:
1. Haber ejecutado `swift build` primero
2. El archivo `.env` existe y tiene las variables correctas
3. El puerto 8080 no esté en uso: `lsof -ti:8080`

## 📱 Integración con iOS

Para consumir esta API desde tu app de Swift/SwiftUI:

```swift
struct Module: Codable {
    let id: UUID
    let title: String
    let description: String?
    let sort_order: Int
    let is_active: Bool
    let created_at: Date?
}

// Obtener módulos
func fetchModules() async throws -> [Module] {
    let url = URL(string: "http://localhost:8080/api/modules")!
    let (data, _) = try await URLSession.shared.data(from: url)
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode([Module].self, from: data)
}
```

O usa directamente el **SDK de Supabase** en tu app iOS:

```swift
import Supabase

let supabase = SupabaseClient(
    supabaseURL: URL(string: "https://tu-proyecto.supabase.co")!,
    supabaseKey: "tu_anon_key"
)

// Obtener módulos directamente desde Supabase
let modules: [Module] = try await supabase
    .from("modules")
    .select()
    .order("sort_order")
    .execute()
    .value
```

## 📝 Notas

- **REST API**: Usa Supabase REST API en lugar de conexión directa PostgreSQL
- **Sin Fluent**: No usa ORM, solo DTOs simples con Codable
- **CORS**: Configurado para aceptar todas las origins (ajustar para producción)
- **Log Level**: Configurado en `debug`. Cambiar a `info` o `warning` en producción

## 🤝 Contribuir

1. Crear una rama feature: `git checkout -b feature/nueva-funcionalidad`
2. Hacer commit de cambios: `git commit -m 'Agregar nueva funcionalidad'`
3. Push a la rama: `git push origin feature/nueva-funcionalidad`
4. Crear un Pull Request

## � Equipo

Proyecto desarrollado para Cafecitos Learning Platform - App educativa para cafeteros con reconocimiento de imágenes.

## 🎯 Sobre el Proyecto

Cafecitos es una app educativa que enseña el proceso del café mediante:
- 📚 Módulos de aprendizaje interactivos
- 📸 Reconocimiento de imágenes de café
- ✅ Actividades para reforzar el aprendizaje
- 📝 Sistema de notas y progreso

Ideal para novatos y personas sin experiencia que quieran aprender sobre café.

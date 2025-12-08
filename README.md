# Kaldi

**Kaldi** es una aplicación educativa diseñada para capacitar a productores y personas interesadas en el café a producir **café de especialidad**, de forma **didáctica, interactiva y gamificada**.

A través de simulaciones, lecciones visuales y una experiencia tipo *tamagotchi*, Kaapeh guía al usuario por el proceso completo del café, desde la semilla hasta la taza, con énfasis en prácticas agroforestales y de calidad.

---

##  Objetivo del proyecto

Brindar conocimiento accesible y práctico sobre el cultivo, cuidado y procesamiento del café de especialidad, fomentando mejores prácticas productivas mediante una experiencia intuitiva. dinámica y gamificada.

---

## Funcionalidades principales

- **Registro y cuidado de plantas de café**
  - Simulación del crecimiento por etapas (semilla, plántula, vegetativa, cosecha, etc.)
  - Manejo de riego, luz y nutrientes

- **Lecciones interactivas**
  - Contenido educativo sobre café de especialidad
  - Enfoque en sistemas agroforestales y procesos post-cosecha
 
- **Cámara IA**
  -Cámara capaz de analizar imágenes de granos de café
  -Permite identificar defectos en la producción

- **Minijuegos educativos**
  - Procesos como lavado, honey y natural
  - Feedback visual para aprender haciendo

- **Perfil de usuario y autenticación**
  - Gestión de progreso y plantas registradas

---

## Tecnologías utilizadas

- **SwiftUI** – Interfaz y experiencia de usuario  
- **SwiftData** – Persistencia local de datos  
- **Supabase** – Autenticación y backend
- -**Apple Intelligence** - Clasificación de imágenes
- **iOS** – Plataforma objetivo  


---



flowchart LR
    subgraph UserDevice["📱 iOS Device"]
        subgraph KaapehApp["Kaapeh iOS App (SwiftUI)"]
            direction TB
            UI[SwiftUI Views\n(Home, Learn, Plantas, Perfil, Minijuegos)]
            Logic[Domain & App Logic\n(ViewModels / Managers)]
            SwiftData[(SwiftData\nLocal Models\nCoffeePlant, Progress, Settings)]
            SupabaseClient[Networking Layer\nSupabase Client Wrapper]
        end
    end

    subgraph SupabaseCloud["☁️ Supabase Backend"]
        direction TB
        Auth[Auth Service\n(email/password, roles)]
        DB[(Postgres DB\nusers, coffee_plants,\nlessons, tips, progress)]
        Storage[(Storage\nImágenes, banners,\nassets educativos)]
        EdgeFns[Edge Functions (futuro)\nrecomendaciones, scoring, analítica]
    end

    User[👤 Usuario] -->|Interacción táctil| UI

    UI --> Logic
    Logic --> SwiftData
    Logic --> SupabaseClient

    SupabaseClient --> Auth
    SupabaseClient --> DB
    SupabaseClient --> Storage
    SupabaseClient --> EdgeFns

    SwiftData -->|Modo offline / cache| UI
    DB -->|Sincroniza progreso,\nplantas, lecciones| SwiftData


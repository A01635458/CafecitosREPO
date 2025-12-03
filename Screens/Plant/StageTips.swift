import Foundation

struct StageTips {
    // MARK: - Tip genérico por etapa (fallback)
    static func baseTip(for stage: CoffeeStage) -> String {
        switch stage {
        case .seed:
            return "Mantén la semilla en sombra total y el sustrato húmedo, sin encharcar."
        case .germination:
            return "Evita cambios bruscos: estabilidad en agua y luz ayuda a germinar bien."
        case .seedling:
            return "Introduce luz poco a poco; si se ve débil, vuelve a más sombra."
        case .juvenile:
            return "Riego regular y luz filtrada; corrige excesos de agua o sequedad."
        case .transplanted:
            return "Después del trasplante, dale sombra extra y evita exceso de agua."
        case .vegetative:
            return "Busca equilibrio de luz y agua para hojas verdes y sanas."
        case .flowering:
            return "Evita encharcar: el exceso de agua puede tirar las flores."
        case .greenCherry:
            return "Más luz ayuda a madurar los frutos, pero cuida el estrés hídrico."
        case .ripeCherry:
            return "Cosecha solo las cerezas bien maduras para mejor calidad en taza."
        case .harvest:
            return "Selecciona cuidadosamente las cerezas; descarta las verdes o dañadas."
        case .processing:
            return "El método de procesado define mucho el perfil de sabor de tu café."
        case .drying:
            return "Seca de forma pareja; demasiado rápido puede generar defectos."
        case .roasting:
            return "Un tueste muy oscuro puede tapar la dulzura y complejidad del café."
        case .cup:
            return "Prueba tu taza y piensa qué mejorarías en el próximo ciclo."
        }
    }
    
    static func tip(for stage: CoffeeStage,
                    varietal: CoffeeVarietal) -> String {
        switch varietal {
        case .typica:
            return typicaTip(for: stage)
      
        // case .geisha: return geishaTip(for: stage)
        default:
        
            return baseTip(for: stage)
        }
    }
    
    // MARK: - Overrides para Typica
    private static func typicaTip(for stage: CoffeeStage) -> String {
        switch stage {
        case .seed:
            return "Las semillas de Typica necesitan humedad constante y muy poca luz. Mantén el sustrato apenas húmedo, nunca encharcado."
        case .germination:
            return "Durante la germinación, Typica prefiere sombra suave y estabilidad en riego. Evita completamente la luz directa."
        case .seedling:
            return "Como plántula, Typica es muy frágil. Aumenta la luz gradualmente; si ves hojas amarillas o quemadas, vuelve a más sombra."
        case .juvenile:
            return "En etapa juvenil, busca un balance entre sombra y luz filtrada. Cambios bruscos de ambiente la estresan con facilidad."
        case .transplanted:
            return "Después del trasplante, dale un poco más de sombra mientras se adapta. Mantén la humedad estable para evitar que se marchite."
        case .vegetative:
            return "En la fase vegetativa, una canopia bien formada es clave. Luz filtrada y riego moderado ayudan a tener hojas sanas."
        case .flowering:
            return "La floración de Typica es sensible. Evita encharcar el sustrato y no muevas demasiado la planta en esta etapa."
        case .greenCherry:
            return "Con cerezas verdes, más luz ayuda al desarrollo del fruto. Vigila que las hojas se mantengan firmes y de color uniforme."
        case .ripeCherry:
            return "Cosecha solo las cerezas bien rojas y maduras. Typica recompensa la cosecha selectiva con mejor dulzura y complejidad."
        case .harvest:
            return "En la cosecha, prioriza cerezas maduras y descarta las verdes o dañadas. Esto mejora mucho la calidad de la taza final."
        case .processing:
            return "Elige el beneficio según el perfil que buscas: lavado para limpieza, honey para dulzor o natural para notas afrutadas intensas."
        case .drying:
            return "Seca el café en capas delgadas y muévelo seguido. Typica puede perder calidad si se seca demasiado rápido o de forma desigual."
        case .roasting:
            return "Typica suele brillar en tostados ligeros a medios, donde aparecen notas florales y una acidez brillante."
        case .cup:
            return "En taza, busca una acidez fina y un cuerpo delicado. Compara tu resultado con cómo cuidaste agua, luz y procesos."
        }
    }
    
}


import Foundation

struct StageTips {
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

    static func varietalOverride(for stage: CoffeeStage,
                                 varietal: CoffeeVarietal) -> String? {
        switch (varietal, stage) {
        case (.typica, .seed):
            return "este es typica."

        case (.bourbon, .ripeCherry):
            return "El Bourbon desarrolla máxima dulzura si cosechas cerezas bien rojas y uniformes."
        default:
            return nil
        }
    }

    static func tip(for stage: CoffeeStage,
                    varietal: CoffeeVarietal) -> String {
        varietalOverride(for: stage, varietal: varietal)
        ?? baseTip(for: stage)
    }
}


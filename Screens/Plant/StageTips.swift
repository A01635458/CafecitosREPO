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
      
        case .geisha:
            return geishaTip(for: stage)
            
        case .hidalgo:
            return plumaHidalgoTip(for: stage)
      
        default:
        
            return baseTip(for: stage)
        }
    }
    
    private static func plumaHidalgoTip(for stage: CoffeeStage) -> String {
        switch stage {
        case .seed:
            return "Las semillas de Pluma requieren humedad alta y sombra profunda. Mantén el sustrato húmedo sin exceso y evita toda luz directa."
        case .germination:
            return "En la germinación, Pluma necesita mucha estabilidad. Mantén sombra suave y riego constante para evitar que se deshidrate."
        case .seedling:
            return "Como plántula, Pluma es delicada. Introduce luz poco a poco; si notas puntas secas o palidez, reduce la exposición inmediatamente."
        case .juvenile:
            return "En etapa juvenil, prefiere microclimas frescos. Mantén sombra filtrada y evita corrientes de aire que resequen el sustrato."
        case .transplanted:
            return "Después del trasplante, Pluma agradece una recuperación en sombra y humedad estable. Evita moverla mientras se adapta."
        case .vegetative:
            return "Durante el crecimiento vegetativo, busca equilibrio: riego regular y luz filtrada para hojas sanas y un desarrollo consistente."
        case .flowering:
            return "La floración en Pluma es sensible a la sequedad. Mantén riegos moderados y evita golpes de sol que puedan tirar flores."
        case .greenCherry:
            return "Con cerezas verdes, aumenta ligeramente la luz filtrada. Un ambiente fresco ayuda a que el fruto engorde de forma uniforme."
        case .ripeCherry:
            return "Cosecha las cerezas rojo intenso. Pluma tiende a madurar de forma pareja, ideal para recolección selectiva."
        case .harvest:
            return "En la cosecha, selecciona únicamente cerezas maduras y descarta las pasadas. Esto preserva su dulzor y perfil achocolatado."
        case .processing:
            return "Pluma destaca en procesos lavados o honey ligeros. Elige el método según si buscas claridad o un dulzor suave."
        case .roasting:
            return "Pluma funciona muy bien en tostados medios, donde aparecen notas achocolatadas, nueces y acidez suave."
        case .cup:
            return "En taza busca balance, dulzor suave y cuerpo cremoso. Observa cómo la estabilidad de humedad influyó en tus resultados."
        }
    }

    private static func geishaTip(for stage: CoffeeStage) -> String {
        switch stage {
        case .seed:
            return "Las semillas de Geisha requieren humedad constante y sombra profunda. Evita cualquier variación fuerte de luz o agua."
        case .germination:
            return "Durante la germinación, Geisha es extremadamente sensible. Mantén sombra suave y riego preciso para evitar estrés temprano."
        case .seedling:
            return "Como plántula, Geisha necesita luz muy gradual. Si notas hojas rizadas o bordes quemados, reduce la exposición de inmediato."
        case .juvenile:
            return "En etapa juvenil, cuida que la luz sea filtrada y estable. Los cambios bruscos pueden afectar su estructura y vigor."
        case .transplanted:
            return "Tras el trasplante, mantenla en sombra controlada y riego uniforme. Geisha se estresa fácilmente con cualquier variación."
        case .vegetative:
            return "En fase vegetativa, prioriza un ambiente fresco y estable. La luz filtrada y el riego moderado ayudan a desarrollar su icónica estructura."
        case .flowering:
            return "La floración en Geisha es frágil. Evita encharcar y no la muevas; las flores pueden caerse con mínimos cambios."
        case .greenCherry:
            return "Con cerezas verdes, aumenta la luz suavemente. Un clima estable ayuda a concentrar los azúcares del fruto."
        case .ripeCherry:
            return "Cosecha solo las cerezas rojo intenso. La madurez perfecta es clave para preservar su perfil floral y brillante."
        case .harvest:
            return "Selecciona únicamente las cerezas óptimas y descarta las submaduras. La calidad de Geisha depende totalmente de la precisión."
        case .processing:
            return "El proceso influye mucho en Geisha: lavado para claridad floral, honey para dulzor, o natural para un perfil más complejo."
        case .roasting:
            return "Geisha brilla en tostados ligeros, donde emergen notas florales, té blanco y acidez limpia. Evita tostados profundos."
        case .cup:
            return "En taza, busca claridad, elegancia y aroma floral. La estabilidad del ambiente durante el cultivo es clave para su resultado final."
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
        case .roasting:
            return "Typica suele brillar en tostados ligeros a medios, donde aparecen notas florales y una acidez brillante."
        case .cup:
            return "En taza, busca una acidez fina y un cuerpo delicado. Compara tu resultado con cómo cuidaste agua, luz y procesos."
        }
    }
    
}


import Foundation

extension EnvironmentRules {
    static let typicaOverrides: [CoffeeStage: EnvironmentRequirement] = [
        .seed: EnvironmentRequirement(
            waterRange: 90...100,
            lightRange: 90...100
        ),
        .germination: EnvironmentRequirement(
            waterRange: 70...85,
            lightRange: 10...25
        ),
        .seedling: EnvironmentRequirement(
            waterRange: 65...80,
            lightRange: 20...40
        ),
        .juvenile: EnvironmentRequirement(
            waterRange: 60...75,
            lightRange: 30...55
        ),
        .transplanted: EnvironmentRequirement(
            waterRange: 65...80,
            lightRange: 15...35
        ),
        .vegetative: EnvironmentRequirement(
            waterRange: 55...70,
            lightRange: 40...65
        ),
        .flowering: EnvironmentRequirement(
            waterRange: 55...65,
            lightRange: 45...70
        ),
        .greenCherry: EnvironmentRequirement(
            waterRange: 50...65,
            lightRange: 60...85
        ),
        .ripeCherry: EnvironmentRequirement(
            waterRange: 50...65,
            lightRange: 70...90
        ),
        .drying: EnvironmentRequirement(
            waterRange: nil,
            lightRange: 60...100
        )
    ]
}

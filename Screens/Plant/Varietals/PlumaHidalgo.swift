import Foundation

extension EnvironmentRules {
    static let plumaHidalgoOverrides: [CoffeeStage: EnvironmentRequirement] = [
        .seed: EnvironmentRequirement(
            waterRange: 85...100,
            lightRange: 98...100
        ),
        .germination: EnvironmentRequirement(
            waterRange: 70...90,
            lightRange: 32...34
        ),
        .seedling: EnvironmentRequirement(
            waterRange: 70...85,
            lightRange: 32...34
        ),
        .juvenile: EnvironmentRequirement(
            waterRange: 65...80,
            lightRange: 32...34
        ),
        .transplanted: EnvironmentRequirement(
            waterRange: 70...85,
            lightRange: 32...34
        ),
        .vegetative: EnvironmentRequirement(
            waterRange: 60...75,
            lightRange: 65...67
        ),
        .flowering: EnvironmentRequirement(
            waterRange: 55...70,
            lightRange: 65...67
        ),
        .greenCherry: EnvironmentRequirement(
            waterRange: 55...70,
            lightRange: 65...67
        ),
        .ripeCherry: EnvironmentRequirement(
            waterRange: 55...70,
            lightRange: 98...100
        )
    ]
}

import Foundation

extension EnvironmentRules {
    static let geishaOverrides: [CoffeeStage: EnvironmentRequirement] = [
        .seed: EnvironmentRequirement(
            waterRange: 90...100,
            lightRange: 95...100
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
            lightRange: 32...34
        ),
        .flowering: EnvironmentRequirement(
            waterRange: 55...70,
            lightRange: 65...67
        ),
        .greenCherry: EnvironmentRequirement(
            waterRange: 50...65,
            lightRange: 65...67
        ),
        .ripeCherry: EnvironmentRequirement(
            waterRange: 50...65,
            lightRange: 98...100
        ),

    ]
}

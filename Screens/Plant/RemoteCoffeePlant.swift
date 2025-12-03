import Foundation

struct RemoteCoffeePlant: Codable {
    let id: UUID
    let userId: UUID
    let name: String
    let varietal: String
    let stage: String
    let stageStartedAt: Date
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case varietal
        case stage
        case stageStartedAt = "stage_started_at"
        case createdAt = "created_at"
    }
}

extension CoffeePlant {
    func toRemote(userId: UUID) -> RemoteCoffeePlant {
        RemoteCoffeePlant(
            id: id,
            userId: userId,
            name: name,
            varietal: varietal,
            stage: stage.rawValue,
            stageStartedAt: stageStartedAt,
            createdAt: createdAt
        )
    }
}

extension RemoteCoffeePlant {
    func toLocal() -> CoffeePlant {
        CoffeePlant(
            id: id,
            name: name,
            varietal: varietal,
            createdAt: createdAt ?? Date(),
            stage: CoffeeStage(rawValue: stage) ?? .seed,
            stageStartedAt: stageStartedAt
        )
    }
}


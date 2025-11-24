import Testing
@testable import KaapehApp

@Test("Contraseña demasiado corta falla")
func testShortPasswordFails() {
    #expect(isValidPassword("abc1def") == false)
}

@Test("Contraseña sin número falla")
func testPasswordWithoutNumberFails() {
    #expect(isValidPassword("abcdefgh") == false)
}

@Test("Contraseña válida pasa")
func testValidPasswordPasses() {
    #expect(isValidPassword("cafe1234") == true)
}

@MainActor
@Test
func testNormalizedLabel() async throws {
    let cameraModel = CameraModel()
    let rawLabel = "  CafeNegro  "
    let expected = "cafenegro"
    let processed = cameraModel.normalizedLabel(from: rawLabel)

    #expect(processed == expected)
}

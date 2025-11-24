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


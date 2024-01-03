extends Object

enum TestEnum {
    TEST_ONE,
    TEST_TWO_TWO,
    Three }

class TestSettings:
    var test_bool: bool = true
    var tes_int: int = 0
    var test_enum: TestEnum = TestEnum.TEST_ONE


static func get_settings() -> TestSettings:
    return TestSettings.new()

extends Container

class_name SettingsLoader

enum ControlType { BOOL, INT, ENUM }

const SCRIPT_PATH: String = "res://Scenes/SceneLoader/TestSettingsProvider.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
    var test_scene = load(SCRIPT_PATH)

    var settings: Object = test_scene.get_settings()

    for prop in settings.get_property_list():
        if prop["name"] in ["RefCounted", "script", "Built-in script"]:
            continue

        var a_name = SettingsLoader.__parse_name(prop["name"])
        var type = SettingsLoader.__parse_type(prop["type"], prop["class_name"])

        var enum_variants = []
        if type == ControlType.ENUM:
            enum_variants = SettingsLoader.__parse_enum_variants(prop["class_name"])
        self.__add_entry(a_name, type, enum_variants)

func __add_entry(a_name: String, type: ControlType, enum_variants: Array):
    print("Name: ", a_name, " type: ", type, " enums: ", enum_variants)

static func __parse_name(a_name: String) -> String:
    var words = a_name.split("_")
    words[0] = words[0].capitalize()
    return " ".join(words)

static func __parse_type(type: int, a_class_name: String) -> ControlType:
    if type == Variant.Type.TYPE_BOOL:
        return ControlType.BOOL
    elif type == Variant.Type.TYPE_INT:
        if a_class_name:
            return ControlType.ENUM
        else:
            return ControlType.INT
    else:
        assert(false, "Invalid settings type. Not a bool, int or enum")

    return ControlType.BOOL


static func __parse_enum_variants(a_class_name: String) -> Array:
    # splits `res://Scenes/SceneLoader/TestSettingsProvider.gd.TestEnum` into scpript and enum name
    var enum_components = a_class_name.rsplit(".", false, 1)

    var enum_obj = load(enum_components[0])

    var result = []
    for variant in enum_obj[enum_components[1]]:
        var words = variant.split("_")
        for i in len(words):
            if i == 0:
                words[i] = words[i].capitalize()
            else:
                words[i] = words[i].to_lower()
        result.append(" ".join(words))
    return result

# Fretboard class to store fret positions
class Fret:
    var top_point: Vector2
    var bottom_point: Vector2

    func _init(a_top_point: Vector2, a_bottom_point: Vector2):
        self.top_point = a_top_point
        self.bottom_point = a_bottom_point

# Fretboard class to store fret positions
class AString:
    var left_point: Vector2
    var right_point: Vector2

    func _init(a_left_point: Vector2, a_right_point: Vector2):
        self.left_point = a_left_point
        self.right_point = a_right_point

class FretboardPosition:
    var string: int
    var fret: int
    var position: Vector2

    func _init(a_string: int, a_fret: int, a_position: Vector2):
        self.string = a_string
        self.fret = a_fret
        self.position = a_position

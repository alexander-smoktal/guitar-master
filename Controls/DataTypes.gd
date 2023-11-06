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

class HoveredNote:
    var string: int
    var fret: int
    var highlight: NoteHighlight

    func _init(fretboard: Node, highlight_size: int = 11):
        self.highlight = NoteHighlight.new(Color.WHITE_SMOKE, NoteHighlight.HighLightType.PERSISTENT)
        self.highlight.resize(highlight_size)
        fretboard.add_child(self.highlight)
        self.highlight.set_z_index(0)

    func move(a_string: int, a_fret: int, a_position: Vector2):
        self.string = a_string
        self.fret = a_fret
        self.highlight.set_position(a_position)
        #set_transform(Transform2D(0, current_note.position))

    func position() -> Vector2:
        return self.highlight.position

    func clear():
        self.highlight.queue_free()

class FretboardPosition:
    var string: int
    var fret: int
    var position: Vector2

    func _init(a_string: int, a_fret: int, a_position: Vector2):
        self.string = a_string
        self.fret = a_fret
        self.position = a_position

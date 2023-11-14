var string: int
var fret: int
var highlight: NoteHighlight

func _init(fretboard: Node, pos: Vector2, highlight_size: int = 11):
    self.highlight = NoteHighlight.new(Color.WHITE_SMOKE, NoteHighlight.HighLightType.PERSISTENT)
    fretboard.add_child(self.highlight)

    self.highlight.resize(highlight_size)
    self.highlight.set_z_index(0)
    self.highlight.fade_in(pos)


func move(a_string: int, a_fret: int, a_position: Vector2):
    self.string = a_string
    self.fret = a_fret
    self.highlight.move(a_position)

func position() -> Vector2:
    return self.highlight.position

func clear():
    self.highlight.fade_out()

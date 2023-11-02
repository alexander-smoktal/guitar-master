class_name Note

const NOTES_STRINGS: Array[String] = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']

enum {
    C,
    C_SHARP,
    D,
    D_SHARP,
    E,
    F,
    F_SHARP,
    G,
    G_SHARP,
    A,
    A_SHARP,
    B
}

var note: int
var octave: int


func _init(a_note: int, an_octave):
    self.note = a_note
    self.octave = an_octave

func _to_string():
    return "%so%d" % [NOTES_STRINGS[self.note], self.octave]

func shift(steps: int) -> Note:
    @warning_ignore("integer_division")
    return Note.new((self.note + steps) % 12, self.octave + (self.note + steps) / 12)

class_name TunedFretboard

extends Node2D

var visual_fretboard: Fretboard

var string_notes: Array[Note] = [null,
    Note.new(Note.E, 0),
    Note.new(Note.A, 0),
    Note.new(Note.D, 1),
    Note.new(Note.G, 1),
    Note.new(Note.B, 1),
    Note.new(Note.E, 2)]

var test_scale = Scale.minor_pentatonic(Note.new(Note.A, 0))

# Called when the node enters the scene tree for the first time.
func _ready():
    self.visual_fretboard = Fretboard.new()
    self.visual_fretboard.note_clicked.connect(self.__on_note_clicked)
    self.add_child(self.visual_fretboard)

func __on_note_clicked(string: int, fret: int):
    var clicked_note = string_notes[string].shift(fret)

    if test_scale.contains_note(clicked_note):
        self.visual_fretboard.highlight_note(string, fret, GlobalColors.COLOR_OK)
    else:
        self.visual_fretboard.highlight_note(string, fret, GlobalColors.COLOR_ERROR)

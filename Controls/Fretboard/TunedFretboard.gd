class_name TunedFretboard

extends Control

var visual_fretboard: Fretboard
var player: AudioStreamPlayer

var string_notes: Array[Note] = [null,
    Note.new(Note.E, 2),
    Note.new(Note.A, 2),
    Note.new(Note.D, 3),
    Note.new(Note.G, 3),
    Note.new(Note.B, 3),
    Note.new(Note.E, 4)]

var test_scale = Scale.minor_pentatonic(Note.new(Note.A, 0))

# Called when the node enters the scene tree for the first time.
func _ready():
    self.visual_fretboard = Fretboard.new()
    self.visual_fretboard.note_clicked.connect(self.__on_note_clicked)
    self.add_child(self.visual_fretboard)

    self.player = AudioStreamPlayer.new()
    self.add_child(player)

func __on_note_clicked(string: int, fret: int):
    var clicked_note = string_notes[string].shift(fret)

    clicked_note.play_sound(self.player)

    if test_scale.contains(clicked_note):
        if test_scale.root().is_same_note(clicked_note):
            self.visual_fretboard.highlight_note(string, fret, GlobalColors.COLOR_ROOT)
        else:
            self.visual_fretboard.highlight_note(string, fret, GlobalColors.COLOR_OK)
    else:
        self.visual_fretboard.blink_note(string, fret, GlobalColors.COLOR_ERROR)

func _notification(what):
    match what:
        NOTIFICATION_RESIZED:
            self.visual_fretboard.set_size(self.size)
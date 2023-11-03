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

var self_scale = Scale.empty()
# Notes user still need to click to complete a task
var notes_to_click: Dictionary

# A single note clicked
signal note_clicked(note: Note)
# All notes of the scale where clicked on the fretboard
signal completed(note: Note)

# Called when the node enters the scene tree for the first time.
func _ready():
    self.visual_fretboard = Fretboard.new()
    self.visual_fretboard.note_clicked.connect(self.__on_note_clicked)
    self.add_child(self.visual_fretboard)

    self.player = AudioStreamPlayer.new()
    self.add_child(player)

func __on_note_clicked(string: int, fret: int):
    var clicked_note = string_notes[string].shift(fret)
    self.note_clicked.emit(clicked_note)

    clicked_note.play_sound(self.player)

    self.notes_to_click.erase([string, fret])
    print(self.notes_to_click.size())
    if self.notes_to_click.is_empty():
        self.completed.emit()

    if self_scale.contains(clicked_note):
        if self_scale.root().is_same_note(clicked_note):
            self.visual_fretboard.highlight_note(string, fret, GlobalColors.COLOR_ROOT)
        else:
            self.visual_fretboard.highlight_note(string, fret, GlobalColors.COLOR_OK)
    else:
        self.visual_fretboard.blink_note(string, fret, GlobalColors.COLOR_ERROR)

func reset(a_scale: Scale):
    # Clean previous highlights
    self.visual_fretboard.reset()
    self.self_scale = a_scale
    self.reset_notes_to_click()

func _notification(what):
    match what:
        NOTIFICATION_RESIZED:
            self.visual_fretboard.set_size(self.size)

# Reset all notes user still need to click to complete the quest
func reset_notes_to_click():
    self.notes_to_click = {}

    for string in range(1, self.string_notes.size()):
        for fret in Fretboard.NUM_FRETS:
            var a_note = self.string_notes[string].shift(fret)
            if self.self_scale.contains(a_note):
                self.notes_to_click[[string, fret]] = null

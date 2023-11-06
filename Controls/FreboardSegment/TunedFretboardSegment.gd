class_name TunedFretboardSegment

extends Control

var visual_fretboard: FretboardSegment
var player: AudioStreamPlayer

var string_notes: Array[Note] = [null,
    Note.new(Note.E, 2),
    Note.new(Note.A, 2),
    Note.new(Note.D, 3),
    Note.new(Note.G, 3),
    Note.new(Note.B, 3),
    Note.new(Note.E, 4)]

var chord = Chord.E_minor()
# Notes user still need to click to complete a task
var notes_to_click: Dictionary
var first_fret = 0
var num_frets = 3

# A single note clicked
signal note_clicked(note: Note)
# All notes of the scale where clicked on the fretboard
signal completed(note: Note)

# Called when the node enters the scene tree for the first time.
func _ready():
    self.visual_fretboard = FretboardSegment.new()
    self.visual_fretboard.note_clicked.connect(self.__on_note_clicked)
    self.add_child(self.visual_fretboard)

    self.player = AudioStreamPlayer.new()
    self.add_child(player)
    self.reset(Chord.E_minor())

    %PlayChordButton.pressed.connect(self.__on_play_clicked)

func __on_note_clicked(string: int, fret: int):
    var clicked_note = string_notes[string].shift(fret + self.first_fret)
    self.note_clicked.emit(clicked_note)

    clicked_note.play_sound(self.player)

    self.notes_to_click.erase([string, fret])
    if self.notes_to_click.is_empty():
        self.completed.emit()

    if chord.contains_note(clicked_note):
            self.visual_fretboard.highlight_note(string, fret, GlobalColors.COLOR_OK)
    else:
        self.visual_fretboard.blink_note(string, fret, GlobalColors.COLOR_ERROR)

func __on_play_clicked():
    self.chord.play_sound(self.player)

func reset(a_chord: Chord):
    # Clean previous highlights
    self.visual_fretboard.reset(self.num_frets, self.first_fret)
    self.chord = a_chord
    self.reset_notes_to_click()

    %TaskLabel.set_text(tr('PICK_A_CHORD') % self.chord._to_string())

func _notification(what):
    match what:
        NOTIFICATION_RESIZED:
            self.visual_fretboard.set_size(self.size)

# Reset all notes user still need to click to complete the quest
func reset_notes_to_click():
    self.notes_to_click = {}

    for string in range(1, self.string_notes.size()):
        for fret in range(self.first_fret, self.first_fret + self.num_frets):
            var a_note = self.string_notes[string].shift(fret)
            if chord.contains_note(a_note):
                self.notes_to_click[[string, fret]] = null

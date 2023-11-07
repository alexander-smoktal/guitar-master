class_name TunedNotePicker

extends Control

var notes_to_click: Dictionary
var note_picker: NotePicker
var player: AudioStreamPlayer

var chord = Chord.E_major()

# A single note clicked
signal note_clicked(note: Note)
# All notes of the scale where clicked on the fretboard
signal completed(note: Note)

# Called when the node enters the scene tree for the first time.
func _ready():
    self.note_picker = NotePicker.new()
    self.note_picker.note_clicked.connect(self.__on_note_clicked)
    self.add_child(self.note_picker)

    self.player = AudioStreamPlayer.new()
    self.add_child(player)
    self.reset(self.chord)

    %NextButton.pressed.connect(self.reset.bind(self.chord))

func __on_note_clicked(a_note: int):
    var clicked_note = Note.new(a_note, 4)
    clicked_note.play_sound(self.player)

    self.notes_to_click.erase(a_note)
    if self.notes_to_click.is_empty():
        %NextButton.set_disabled(false)
        self.completed.emit()

    if chord.contains(a_note):
        self.note_picker.highlight_note(a_note, GlobalColors.COLOR_OK)
    else:
        self.note_picker.blink_note(a_note, GlobalColors.COLOR_ERROR)

func reset(a_chord: Chord):
    # Clean previous highlights
    self.note_picker.reset()
    self.chord = a_chord
    self.reset_notes_to_click()

    %NextButton.set_disabled(true)
    %TaskLabel.set_text(tr('PICK_A_CHORD') % self.chord._to_string())

func _notification(what):
    match what:
        NOTIFICATION_RESIZED:
            self.note_picker.set_size(self.size)

# Reset all notes user still need to click to complete the quest
func reset_notes_to_click():
    self.notes_to_click = {}

    for a_note in self.chord.notes:
        self.notes_to_click[a_note.note] = null

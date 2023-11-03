extends Node2D

@onready
var fretboard = $CanvasLayer/MarginContainer/MainContainer/Fretboard as TunedFretboard
@onready
var task_label = $CanvasLayer/MarginContainer/MainContainer/Label as Label
@onready
var status_label = $CanvasLayer/MarginContainer/MainContainer/HBoxContainer/StatusLabel as Label
@onready
var next_button = $CanvasLayer/MarginContainer/MainContainer/HBoxContainer/NextButton as Button

func reset(a_scale: Scale, task: String):
    self.fretboard.new_scale(a_scale)
    self.task_label.set_text(task)

# Called when the node enters the scene tree for the first time.
func _ready():
    fretboard.note_clicked.connect(self.__on_note_clicked)
    fretboard.completed.connect(self.__on_task_completed)
    next_button.pressed.connect(self.__on_next_button_pressed)

    self.reset(Scale.note(Note.new(Note.E, 0)),
        tr('PICK_A_NOTE') % Note.new(Note.E, 0).note_string())

func __on_note_clicked(note: Note):
    status_label.set_text(note.note_string())

func __on_task_completed():
    next_button.set_disabled(false)

func __on_next_button_pressed():
    self.reset(Scale.note(Note.new(Note.E, 0)),
        tr('PICK_A_NOTE') % Note.new(Note.E, 0).note_string())
    next_button.set_disabled(true)

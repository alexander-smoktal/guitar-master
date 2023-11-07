class_name NotePicker

extends Control

const DataTypes = preload("res://Controls/DataTypes.gd")
const PickerRect = preload('res://Controls/NotesPicker/NotesPickerRect.gd')

# Total height of both rows
const TOTAL_HEIGHT = 0.8
# Fret width as a fraction of the fretboard width
const ELEMENTS_MARGIN = 10

var pickers: Array[PickerRect]

var top_left_point: Vector2
var top_right_point: Vector2
var bottom_left_point: Vector2
var bottom_right_point: Vector2

signal note_clicked(note: int, index: int)

# Highlight note with a dot
func highlight_note(index: int, color: Color):
    self.pickers[index].highlight(color)

# Highlight note with a dot
func blink_note(index: int, color: Color):
    self.pickers[index].blink(color)

func reset():
    for picker in self.pickers:
        picker.reset()

# Called when the node enters the scene tree for the first time.
func _ready():
    var view_size = get_viewport().get_visible_rect().size

    var add_picker = func(a_note: int):
        var picker = PickerRect.new(a_note)
        self.add_child(picker)
        self.pickers.append(picker)

    add_picker.call(Note.C_SHARP)
    add_picker.call(Note.D_SHARP)
    add_picker.call(Note.F_SHARP)
    add_picker.call(Note.G_SHARP)
    add_picker.call(Note.A_SHARP)
    add_picker.call(Note.C)
    add_picker.call(Note.D)
    add_picker.call(Note.E)
    add_picker.call(Note.F)
    add_picker.call(Note.G)
    add_picker.call(Note.A)
    add_picker.call(Note.B)

    self.__resize(view_size)

func _notification(what):
    match what:
        NOTIFICATION_RESIZED:
            self.__resize(self.size)

func _draw():
    pass

func __resize(new_size: Vector2):
    # Fretboard width
    var total_height = new_size.y * TOTAL_HEIGHT

    var element_height = (total_height - ELEMENTS_MARGIN) / 2
    var element_width = element_height * 2/3

    var total_width = (element_width + ELEMENTS_MARGIN) * 7

    var start_x = (new_size.x - total_width) / 2
    var start_y = (new_size.y - total_height) / 2

    print('%d %d %d %d' % [start_x, start_y, element_height, element_width])

    var adjust_picker = func(index: int, ix: int, iy: int):
        var picker =  self.pickers[index]
        picker.set_position(Vector2(start_x + (element_width + ELEMENTS_MARGIN) * ix,
            start_y + (element_height + ELEMENTS_MARGIN) * iy))
        picker.set_size(Vector2(element_width, element_height))

    adjust_picker.call(0, 0, 0)
    adjust_picker.call(1, 1, 0)
    adjust_picker.call(2, 3, 0)
    adjust_picker.call(3, 4, 0)
    adjust_picker.call(4, 5, 0)
    adjust_picker.call(5, 0, 1)
    adjust_picker.call(6, 1, 1)
    adjust_picker.call(7, 2, 1)
    adjust_picker.call(8, 3, 1)
    adjust_picker.call(9, 4, 1)
    adjust_picker.call(10, 5, 1)
    adjust_picker.call(11, 6, 1)

extends Control

var active: bool
var note: int
var color = GlobalColors.COLOR_NOTE_PICKER

func highlight(a_color: Color):
    self.active = false
    var tween = self.create_tween()
    tween.tween_method(self.__change_color, self.color, self.a_color, 0.5)

func blink(a_color: Color):
    var tween = self.create_tween()
    tween.tween_method(self.__change_color, self.color, self.a_color, 0.25)
    tween.tween_method(self.__change_color, self.a_color, self.color, 0.25)

func reset():
    self.color = GlobalColors.COLOR_NOTE_PICKER
    self.active = true
    queue_redraw()

func _init(a_note: int):
    self.note = a_note
    self.active = true

    self.mouse_entered.connect(self.__on_mouse_entered)
    self.mouse_exited.connect(self.__on_mouse_exited)

# Called when the node enters the scene tree for the first time.
func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, self.get_size()), self.color)
    draw_string(get_theme_default_font(), Vector2(self.get_size() * Vector2(0, .6)),
        Note.note_to_string(self.note), HORIZONTAL_ALIGNMENT_CENTER, self.get_size().x,
        self.get_size().x / 2, Color.BLACK)

func __on_mouse_entered():
    if not self.active:
        return

    self.color = GlobalColors.COLOR_NOTE_PICKER_ACTIVE
    queue_redraw()

func __on_mouse_exited():
    if not self.active:
        return

    self.color = GlobalColors.COLOR_NOTE_PICKER
    queue_redraw()

func __change_color(a_color: Color):
    self.color = a_color
    queue_redraw()

func _notification(what):
    match what:
        NOTIFICATION_RESIZED:
            queue_redraw()

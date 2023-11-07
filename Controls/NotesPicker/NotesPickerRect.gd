extends Control

var active = true
var note: int
var color = GlobalColors.COLOR_NOTE_PICKER
var hovered = false
var tween: Tween

signal on_clicked()

func highlight(a_color: Color):
    if not self.active:
        return

    self.active = false
    var a_tween = self.create_tween()
    a_tween.tween_method(self.__change_color, self.color, a_color, 0.2)

func blink(a_color: Color):
    if not self.active:
        return

    self.tween = self.create_tween()
    self.tween.tween_method(self.__change_color, self.color, a_color, 0.1)
    self.tween.tween_method(self.__change_color, a_color, self.color, 0.1)

func reset():
    self.hovered = false
    self.active = true
    self.color = GlobalColors.COLOR_NOTE_PICKER
    queue_redraw()

func _init(a_note: int):
    self.note = a_note
    self.active = true

    self.mouse_entered.connect(self.__on_mouse_entered)
    self.mouse_exited.connect(self.__on_mouse_exited)

func _input(event):
    if event is InputEventMouseButton and (event as InputEventMouseButton).pressed and self.hovered:
        self.hovered = false
        self.on_clicked.emit()

# Called when the node enters the scene tree for the first time.
func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, self.get_size()), self.color)
    draw_string(get_theme_default_font(), Vector2(self.get_size() * Vector2(.0, .6)),
        Note.note_to_string(self.note), HORIZONTAL_ALIGNMENT_CENTER, self.get_size().x,
        int(self.get_size().x / 2), Color.BLACK)

func __on_mouse_entered():
    if not self.active:
        return

    self.hovered = true
    self.color = GlobalColors.COLOR_NOTE_PICKER_ACTIVE
    queue_redraw()

func __on_mouse_exited():
    if not self.active:
        return

    self.hovered = false
    if self.tween and self.tween.is_running():
        self.tween.stop()
        self.tween = null

    self.color = GlobalColors.COLOR_NOTE_PICKER
    queue_redraw()

func __change_color(a_color: Color):
    self.color = a_color
    queue_redraw()

func _notification(what):
    match what:
        NOTIFICATION_RESIZED:
            queue_redraw()

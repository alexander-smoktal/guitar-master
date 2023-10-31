class_name NoteHighlight

extends Node2D

var color: Color

func _init(a_color: Color) -> void:
    a_color.a = 0
    self.color = a_color

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var tween = self.create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.tween_method(self.redraw, 0.0, 1.0, 0.2)
    tween.tween_method(self.redraw, 1.0, 0.0, 0.2)
    tween.tween_callback(self.queue_free)

func redraw(alpha: float):
    self.color.a = alpha
    queue_redraw()

func _draw():
    draw_circle(Vector2(0, 0), 10, self.color)

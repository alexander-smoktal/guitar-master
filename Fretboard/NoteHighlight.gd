class_name NoteHighlight

extends Node2D

enum HighLightType { FADE_IN, BLINK, PERSISTENT }

var color: Color
var outline_color = Color.BLACK
# If FADE_IN - a resulting color
var result_color: Color

var highlight_type: HighLightType

func _init(a_color: Color, a_highlight_type: HighLightType, a_result_color = Color.WHITE) -> void:
    match self.highlight_type:
        # Start invisible when blinking
        HighLightType.BLINK:
            color.a = 0
            outline_color.a = 0
        HighLightType.FADE_IN:
            self.result_color = a_result_color

    self.color = a_color
    self.highlight_type = a_highlight_type

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    match self.highlight_type:
        HighLightType.BLINK:
            var tween = self.create_tween()
            tween.set_ease(Tween.EASE_OUT)
            tween.tween_method(self.__change_alpha, 0.0, 1.0, 0.2)
            tween.tween_method(self.__change_alpha, 1.0, 0.0, 0.2)
            tween.tween_callback(self.queue_free)
        HighLightType.FADE_IN:
            var tween = self.create_tween()
            tween.tween_method(self.__change_color, self.color, self.result_color, 0.5)

func __change_alpha(alpha: float):
    self.color.a = alpha
    queue_redraw()

func __change_color(a_color: Color):
    self.color = a_color
    queue_redraw()

func _draw():
    var radius = 12

    draw_circle(Vector2(0, 0), radius, self.color)
    draw_arc(Vector2(0, 0), radius, 0, TAU, 30, self.outline_color, 1, true)

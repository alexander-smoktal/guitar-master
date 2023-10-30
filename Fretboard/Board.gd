class_name Fretboard

extends Node2D

# Fretboard class to store fret positions
class Fret:
    var top_point: Vector2
    var bottom_point: Vector2

    func _init(a_top_point: Vector2, a_bottom_point: Vector2):
        self.top_point = a_top_point
        self.bottom_point = a_bottom_point

# Fretboard class to store fret positions
class AString:
    var left_point: Vector2
    var right_point: Vector2

    func _init(a_left_point: Vector2, a_right_point: Vector2):
        self.left_point = a_left_point
        self.right_point = a_right_point

class Note:
    var string: int
    var fret: int

    func _init(a_string: int, a_fret: int):
        self.string = a_string
        self.fret = a_fret

# Board width in fraction of viewport height
const BOARD_WIDTH = 0.15
# Board margin in pixels
const BOARD_MARGIN = 30
const NUM_FRETS = 24
const FRET_POSITION_DIVIDER = 17.817

var frets: Array[Fret]
var strings: Array[AString]

var top_left_point: Vector2
var top_right_point: Vector2
var bottom_left_point: Vector2
var bottom_right_point: Vector2
# Polygon which we use to highlight mouse position event if mouse is out of the fretboard boundaries
var out_of_bounds_polygon: PackedVector2Array

# Current
var current_note: Note

# Called when the node enters the scene tree for the first time.
func _ready():
    var view_size = get_viewport().get_visible_rect().size

    var thin_fretboard_width = view_size.y * BOARD_WIDTH
    var thick_fretboard_width = thin_fretboard_width * 1.2

    self.top_left_point = Vector2(BOARD_MARGIN, (view_size.y  - thin_fretboard_width) / 2)
    self.top_right_point = Vector2(view_size.x - BOARD_MARGIN, (view_size.y  - thick_fretboard_width) / 2)
    self.bottom_left_point = Vector2(BOARD_MARGIN, (view_size.y  + thin_fretboard_width) / 2)
    self.bottom_right_point = Vector2(view_size.x - BOARD_MARGIN, (view_size.y  + thick_fretboard_width) / 2)

    # Mouse radiuse out of fretboard, which we still use to calculate closest fretboard position
    var out_of_bounds_mouse_radius = thin_fretboard_width / 5
    self.out_of_bounds_polygon = [
        self.top_left_point + Vector2(-out_of_bounds_mouse_radius, -out_of_bounds_mouse_radius),
        self.top_right_point + Vector2(out_of_bounds_mouse_radius, -out_of_bounds_mouse_radius),
        self.bottom_right_point + Vector2(out_of_bounds_mouse_radius, out_of_bounds_mouse_radius),
        self.bottom_left_point + Vector2(-out_of_bounds_mouse_radius, out_of_bounds_mouse_radius),
    ]

    calculate_frets()
    calculate_strings()

func _input(event):
    # Mouse in viewport coordinates.
    if event is InputEventMouseButton and current_note:
        print("Mouse Click/Unclick at: ", event.position, current_note)
    elif event is InputEventMouseMotion:
        current_note = detect_current_highlited_note(event.position)

func _draw():
    draw_fretboard()
    draw_dots()
    draw_frets()
    draw_strings()
    draw_hovered_note()

func calculate_frets():
    var fretboard_width = (self.top_right_point.x - self.top_left_point.x)
    var scale_len = fretboard_width * 1.31

    # Current fret x from which we calculate next fret position
    var last_fret_x = self.top_left_point.x
    for i in range(NUM_FRETS):
        # Calculate fret X. It's based on a formulae from the Internet 😅
        # See here https://www.liutaiomottola.com/formulae/fret.htm
        var distance_from_last_fret = scale_len / FRET_POSITION_DIVIDER
        var current_fret_x  = last_fret_x + distance_from_last_fret

        # Calculate fret edges
        var top_intersection = Geometry2D.line_intersects_line(Vector2(current_fret_x, 0),
            Vector2(0, 1),
            self.top_left_point,
            self.top_right_point - self.top_left_point)

        var bottom_intersection = Geometry2D.line_intersects_line(Vector2(current_fret_x, 0),
            Vector2(0, 1),
            self.bottom_left_point,
            self.bottom_right_point - self.bottom_left_point)

        self.frets.append(Fret.new(top_intersection, bottom_intersection))

        # New fretboard scale len to use in the formula
        scale_len -= distance_from_last_fret
        last_fret_x = current_fret_x

func calculate_strings():
    var fretboad_left_width = self.bottom_left_point.y - self.top_left_point.y
    var fretboad_right_width = self.bottom_right_point.y - self.top_right_point.y

    # Strings margin from the edge of the fretboard
    var string_margin = fretboad_left_width / 10

    # Distanses between the strings
    var left_distance = (fretboad_left_width - (string_margin * 2)) / 5
    var right_distance = (fretboad_right_width - (string_margin * 2)) / 5

    # Current string left and right positions. Update during iteration
    var current_left_pos = self.top_left_point + Vector2(0, string_margin)
    var current_right_pos = self.top_right_point + Vector2(0, string_margin)
    for i in range(6):
        self.strings.append(AString.new(current_left_pos, current_right_pos))

        current_left_pos += Vector2(0, left_distance)
        current_right_pos += Vector2(0, right_distance)

func detect_current_highlited_note(mouse_position: Vector2) -> Note:
    if not Geometry2D.is_point_in_polygon(mouse_position, self.out_of_bounds_polygon):
        return null

    var fret_search = func(fret: Fret, mpos_x: Fret): return fret.top_point.x < mpos_x.top_point.x
    var string_search = func(string: AString, mpos_y: AString): return string.left_point.y < mpos_y.left_point.y

    # Search for hovered fret and string
    # We have to create new inner class values, because type system fails to typecheck the Callable
    var fret = self.frets.bsearch_custom(Fret.new(mouse_position, mouse_position), fret_search)
    var string = self.strings.bsearch_custom(AString.new(mouse_position, mouse_position), string_search)

    fret = fret if fret < self.frets.size() else self.frets.size() - 1
    string = string if string < self.strings.size() else self.strings.size() - 1

    queue_redraw()

    return Note.new(string, fret)

func draw_fretboard():
    draw_polyline([self.top_left_point, self.top_right_point,
                   self.bottom_right_point, self.bottom_left_point,
                   self.top_left_point],
        Color(1, 1, 1),
        3,
        true)

# Draw frets. vectors are used to detect intersections with frets
func draw_frets():
    for fret in self.frets:
        draw_line(fret.top_point, fret.bottom_point, Color(.8, .8, .8), 2, true)

func draw_dots():
    var dot_radius = 7

    var draw_dot = func(square_bw_frets: Rect2):
        var center = Vector2(square_bw_frets.get_center())
        draw_circle(center, dot_radius, Color(0.7, 0.55, 0.4))

    var draw_double_dot = func(square_bw_frets: Rect2):
        var center = Vector2(square_bw_frets.get_center())
        draw_circle(center - Vector2(0, dot_radius * 3), dot_radius, Color(0.9, 0.8, 0.7))
        draw_circle(center + Vector2(0, dot_radius * 3), dot_radius, Color(0.9, 0.8, 0.7))

    var indices_to_draw = [3, 5, 7, 9, 15, 17, 19, 21]

    # Draw regular dot
    for i in indices_to_draw:
        draw_dot.call(Rect2(self.frets[i - 1].top_point,
                       self.frets[i].bottom_point - self.frets[i - 1].top_point))

    # Draw 12 fret dot
    draw_double_dot.call(Rect2(self.frets[11].top_point,
                       self.frets[12].bottom_point - self.frets[11].top_point))

func draw_strings():
    # Strings width from thinner to thicker
    var strings_width = [0.9, 1.2, 1.5, 2.0, 3.5, 4.5]
    # String colors from thinner to thicker
    var string_colors = [Color(.8, .9, 1),
                         Color(.8, .9, 1),
                         Color(.8, .9, 1),
                         Color(.8, .9, 1),
                         Color(1, .95, 0.8),
                         Color(1, .95, 0.8)]

    for i in range(6):
        draw_line(self.strings[i].left_point, self.strings[i].right_point,
                  string_colors[i], strings_width[i] / 2, true)

func draw_hovered_note():
    if not self.current_note:
        return

    var x = self.frets[self.current_note.fret].top_point.x
    var y = self.strings[self.current_note.string].left_point.y

    draw_circle(Vector2(x, y), 10, Color(0.3, 1.0, 0.4, 0.7))

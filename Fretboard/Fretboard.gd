class_name Fretboard

extends Node2D

const DataTypes = preload("res://Fretboard/DataTypes.gd")

# Board width in fraction of viewport height
const BOARD_WIDTH = 0.15
# Board margin in pixels
const BOARD_MARGIN = 30
const NUM_FRETS = 24
const FRET_POSITION_DIVIDER = 17.817

var frets: Array[DataTypes.Fret]
var strings: Array[DataTypes.AString]

var top_left_point: Vector2
var top_right_point: Vector2
var bottom_left_point: Vector2
var bottom_right_point: Vector2
# Polygon which we use to highlight mouse position event if mouse is out of the fretboard boundaries
var out_of_bounds_polygon: PackedVector2Array

var inlay_texture: Texture2D = load("res://Sprites/common_inlay.png")
var twelve_inlay_texture: Texture2D = load("res://Sprites/12_inlay.png")

# Current
var current_note: DataTypes.HighlightedNote
var highlights: Array[NoteHighlight]

signal note_clicked(string: int, fret: int)

# Highlight note with a dot
func highlight_note(string: int, fret: int, color: Color):
    var node_highlight = NoteHighlight.new(color, NoteHighlight.HighLightType.BLINK)
    node_highlight.set_position(current_note.position())
    self.add_child(node_highlight)

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

    self.__calculate_frets()
    self.__calculate_strings()

func _input(event):
    # Mouse in viewport coordinates.
    if event is InputEventMouseButton and (event as InputEventMouseButton).pressed and current_note:
        # String counts backwards
        self.note_clicked.emit(6 - current_note.string, current_note.fret)
    elif event is InputEventMouseMotion:
        var hovered_position = __detect_current_highlited_note(event.position)

        # If out of bound, clear nighlight marker
        if not hovered_position:
            if self.current_note:
                self.current_note.clear()
                self.current_note = null
            return

        # Else create or update marker
        if not self.current_note:
            self.current_note = DataTypes.HighlightedNote.new(self)
        self.current_note.move(hovered_position.string, hovered_position.fret, hovered_position.position)

func _draw():
    self.__draw_fretboard()
    self.__draw_markers()
    self.__draw_frets()
    self.__draw_strings()
    self.__draw_zero_fret()

func __calculate_frets():
    var fretboard_width = (self.top_right_point.x - self.top_left_point.x)
    var scale_len = fretboard_width * 1.31

    #Add zero fret
    self.frets.append(DataTypes.Fret.new(self.top_left_point, self.bottom_left_point))

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

        self.frets.append(DataTypes.Fret.new(top_intersection, bottom_intersection))

        # New fretboard scale len to use in the formula
        scale_len -= distance_from_last_fret
        last_fret_x = current_fret_x

func __calculate_strings():
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
        self.strings.append(DataTypes.AString.new(current_left_pos, current_right_pos))

        current_left_pos += Vector2(0, left_distance)
        current_right_pos += Vector2(0, right_distance)

# Detect highlited note. Return [] if out of bounds, or [string, fret, position]
func __detect_current_highlited_note(mouse_position: Vector2) -> DataTypes.FretboardPosition:
    if not Geometry2D.is_point_in_polygon(mouse_position, self.out_of_bounds_polygon):
        return null

    var fret_search = func(fret: DataTypes.Fret, mpos_x: DataTypes.Fret):
        return fret.top_point.x < mpos_x.top_point.x
    var string_search = func(string: DataTypes.AString, mpos_y: DataTypes.AString):
        return string.left_point.y < mpos_y.left_point.y

    var first_line_is_closer = func(line1_start, line1_end, line2_start, line2_end) -> bool:
        var first_point = Geometry2D.get_closest_point_to_segment_uncapped(mouse_position, line1_start, line1_end)
        var second_point = Geometry2D.get_closest_point_to_segment_uncapped(mouse_position, line2_start, line2_end)

        return mouse_position.distance_to(first_point) < mouse_position.distance_to(second_point)

    # Search for hovered fret and string
    # We have to create new inner class values, because type system fails to typecheck the Callable
    # Binary search finds next to mouse position fret or string. But, we still need to check if mouse
    # position is closer to the previous entity

    # Next to mouse fret and string
    var fret = self.frets.bsearch_custom(DataTypes.Fret.new(mouse_position, mouse_position), fret_search)
    var string = self.strings.bsearch_custom(DataTypes.AString.new(mouse_position, mouse_position), string_search)

    # Cap to the last string and fret
    fret = min(fret, self.frets.size() - 1)
    string = min(string, self.strings.size() - 1)

    # Find closer fret
    if fret > 0:
        fret = fret if first_line_is_closer.call(self.frets[fret].top_point,
                                                 self.frets[fret].bottom_point,
                                                 self.frets[fret - 1].top_point,
                                                 self.frets[fret - 1].bottom_point) else fret - 1
    # Find actually closer string
    if string > 0:
        string = string if first_line_is_closer.call(self.strings[string].left_point,
                                                 self.strings[string].right_point,
                                                 self.strings[string - 1].left_point,
                                                 self.strings[string - 1].right_point) else string - 1

    # Find fret and string intersection
    var intersection = Geometry2D.line_intersects_line(
        self.frets[fret].top_point,
        Vector2(0, 1),
        self.strings[string].left_point,
        self.strings[string].right_point - self.strings[string].left_point)

    queue_redraw()

    return DataTypes.FretboardPosition.new(string, fret, intersection)

func __draw_fretboard():
    draw_colored_polygon([self.top_left_point, self.top_right_point,
                   self.bottom_right_point, self.bottom_left_point,
                   self.top_left_point],
        Color(.05, .05, .05))

    draw_polyline([self.top_left_point, self.top_right_point,
                   self.bottom_right_point, self.bottom_left_point,
                   self.top_left_point],
        Color(.2, .2, .2),
        0.5,
        true)

# Draw frets. vectors are used to detect intersections with frets
func __draw_frets():
    for i in range(1, self.frets.size()):
        var fret = self.frets[i]
        draw_line(fret.top_point, fret.bottom_point, Color(.4, .4, .4), 3, true)

func __draw_zero_fret():
    var fret = self.frets[0]
    draw_line(fret.top_point, fret.bottom_point, Color(.8, .8, .8), 7, true)

func __draw_markers():
    # Marker margin from one side
    var marker_margin = Vector2(1./4, 2./12)

    var draw_dot = func(square_bw_frets: Rect2):
        var pos = square_bw_frets.position + square_bw_frets.size * marker_margin
        var size = square_bw_frets.size * (Vector2.ONE - marker_margin * 2)

        draw_rect(Rect2(pos, size), Color(.9, .9, .9))

    var draw_double_dot = func(square_bw_frets: Rect2):
        # Make 12 fret a bit longer
        var twelve_margin = marker_margin * Vector2(1., 0.7)

        var pos = square_bw_frets.position + square_bw_frets.size * twelve_margin
        # Total markers size
        var size = square_bw_frets.size * (Vector2.ONE - twelve_margin * 2)
        # Single marker size
        var single_marker_size = Vector2(size.x, size.y * 0.45)

        # Top square
        draw_rect(Rect2(pos, single_marker_size), Color(.9, .9, .9))
        # Bottom square
        draw_rect(Rect2(pos + size, -single_marker_size), Color(.9, .9, .9))

    var indices_to_draw = [3, 5, 7, 9, 15, 17, 19, 21]

    # Draw regular dot
    for i in indices_to_draw:
        draw_dot.call(Rect2(self.frets[i - 1].top_point,
                       self.frets[i].bottom_point - self.frets[i - 1].top_point))

    # Draw 12 fret dot
    draw_double_dot.call(Rect2(self.frets[11].top_point,
                       self.frets[12].bottom_point - self.frets[11].top_point))

func __draw_strings():
    # Strings width from thinner to thicker
    var strings_width = [1., 1.1, 1.2, 1.5, 2, 3]
    # String colors from thinner to thicker
    var string_colors = [Color(.9, .95, 1),
                         Color(.9, .95, 1),
                         Color(.9, .95, 1),
                         Color(.9, .95, 1),
                         Color(1, .95, 0.9),
                         Color(1, .95, 0.9)]

    for i in range(6):
        # Draw shadow
        draw_line(self.strings[i].left_point, self.strings[i].right_point,
                  Color(0, 0, 0, .5), strings_width[i] * 1.5, true)

        # Draw string
        draw_line(self.strings[i].left_point, self.strings[i].right_point,
                  string_colors[i], strings_width[i] / 2, true)
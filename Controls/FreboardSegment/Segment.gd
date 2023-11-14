class_name FretboardSegment

extends Control

const DataTypes = preload("res://Controls/DataTypes.gd")
const HoveredNote = preload("res://Controls/Fretboard/HoveredNote.gd")

# Board width in fraction of self control height
const BOARD_WIDTH = 0.5
# Fret width as a fraction of the fretboard width
const FRET_WIDTH = 0.5

var frets: Array[DataTypes.Fret]
var strings: Array[DataTypes.AString]

var top_left_point: Vector2
var top_right_point: Vector2
var bottom_left_point: Vector2
var bottom_right_point: Vector2
# Polygon which we use to highlight mouse position event if mouse is out of the fretboard boundaries
var out_of_bounds_polygon: PackedVector2Array

# Current
var current_note: HoveredNote
var highlights: Array[NoteHighlight]

var num_frets: int = 6
var first_fret_num: int = 8
# Distance between strings to resize highlight marker
var strings_distance = 0

signal note_clicked(string: int, fret: int)

# Highlight note with a dot
func highlight_note(string: int, fret: int, color: Color):
    # convert to intenal string
    var self_string = 6 - string

    var intersection = Geometry2D.line_intersects_line(
        self.frets[fret].top_point,
        Vector2(0, 1),
        self.strings[self_string].left_point,
        self.strings[self_string].right_point - self.strings[self_string].left_point)

    var node_highlight = NoteHighlight.new(color, NoteHighlight.HighLightType.PERSISTENT)
    node_highlight.resize(self.strings_distance / 2)
    node_highlight.set_position(intersection)
    node_highlight.set_z_index(10)
    self.add_child(node_highlight)

    self.highlights.append(node_highlight)

# Highlight note with a dot
func blink_note(string: int, fret: int, color: Color):
    # convert to intenal string
    var self_string = 6 - string

    var intersection = Geometry2D.line_intersects_line(
        self.frets[fret].top_point,
        Vector2(0, 1),
        self.strings[self_string].left_point,
        self.strings[self_string].right_point - self.strings[self_string].left_point)

    var node_highlight = NoteHighlight.new(color, NoteHighlight.HighLightType.BLINK)
    node_highlight.resize(self.strings_distance / 2)
    node_highlight.set_position(intersection)
    self.add_child(node_highlight)

func reset(new_num_frets: int, a_first_fret_num: int):
    assert(new_num_frets > 0)

    self.num_frets = new_num_frets
    self.first_fret_num = a_first_fret_num

    for a_highlights in self.highlights:
        a_highlights.queue_free()
    self.highlights = []

    self.__resize(self.size)

# Called when the node enters the scene tree for the first time.
func _ready():
    var view_size = get_viewport().get_visible_rect().size

    self.__resize(view_size)

func _input(event):
    # Mouse in viewport coordinates.
    if event is InputEventMouseButton and (event as InputEventMouseButton).pressed and current_note:
        # String counts backwards
        self.note_clicked.emit(6 - current_note.string, current_note.fret)
    elif event is InputEventMouseMotion:
        var hovered_position = __detect_current_highlited_note(event.position - self.global_position)

        # If out of bound, clear nighlight marker
        if not hovered_position:
            if self.current_note:
                self.current_note.clear()
                self.current_note = null
            return

        # Else create or update marker
        if not self.current_note:
            self.current_note = HoveredNote.new(self, hovered_position.position, self.strings_distance / 2)
        else:
            self.current_note.move(hovered_position.string, hovered_position.fret, hovered_position.position)

func _notification(what):
    match what:
        NOTIFICATION_RESIZED:
            self.__resize(self.size)

func _draw():
    self.__draw_fretboard()
    self.__draw_markers()
    self.__draw_frets()
    self.__draw_strings()
    self.__draw_zero_fret()
    self.__draw_fret_num()

func __resize(new_size: Vector2):
    # Fretboard width
    var fretboard_width = new_size.y * BOARD_WIDTH
    # Total fretboard length
    var fretboard_length = fretboard_width * FRET_WIDTH * self.num_frets

    self.top_left_point = Vector2((new_size.x - fretboard_length) / 2, (new_size.y  - fretboard_width) / 2)
    self.top_right_point = Vector2((new_size.x  + fretboard_length) / 2, (new_size.y  - fretboard_width) / 2)
    self.bottom_left_point = Vector2((new_size.x - fretboard_length) / 2, (new_size.y  + fretboard_width) / 2)
    self.bottom_right_point = Vector2((new_size.x + fretboard_length) / 2, (new_size.y  + fretboard_width) / 2)

    # Mouse radiuse out of fretboard, which we still use to calculate closest fretboard position
    var out_of_bounds_mouse_radius = fretboard_width / 5
    self.out_of_bounds_polygon = [
        self.top_left_point + Vector2(-out_of_bounds_mouse_radius, -out_of_bounds_mouse_radius),
        self.top_right_point + Vector2(out_of_bounds_mouse_radius, -out_of_bounds_mouse_radius),
        self.bottom_right_point + Vector2(out_of_bounds_mouse_radius, out_of_bounds_mouse_radius),
        self.bottom_left_point + Vector2(-out_of_bounds_mouse_radius, out_of_bounds_mouse_radius),
    ]

    self.__calculate_frets()
    self.__calculate_strings()

    if self.current_note:
        self.current_note.clear()
        self.current_note = null

func __calculate_frets():
    self.frets = []

    var fretboard_width = (self.bottom_left_point.y - self.top_left_point.y)
    # Distance between frets
    var fret_distance = fretboard_width * FRET_WIDTH

    #Add zero fret
    self.frets.append(DataTypes.Fret.new(self.top_left_point, self.bottom_left_point))

    # Current fret x from which we calculate next fret position
    var last_fret_x = self.top_left_point.x
    for i in self.num_frets:
        var current_fret_x  = last_fret_x + fret_distance

        # Calculate fret edges
        var top_intersection = Geometry2D.line_intersects_line(Vector2(current_fret_x, 0),
            Vector2(0, 1),
            self.top_left_point,
            Vector2(1, 0))

        var bottom_intersection = Geometry2D.line_intersects_line(Vector2(current_fret_x, 0),
            Vector2(0, 1),
            self.bottom_left_point,
            Vector2(1, 0))

        self.frets.append(DataTypes.Fret.new(top_intersection, bottom_intersection))

        # New fretboard scale len to use in the formula
        last_fret_x = current_fret_x

func __calculate_strings():
    self.strings = []

    var fretboad_left_width = self.bottom_left_point.y - self.top_left_point.y
    var fretboad_right_width = self.bottom_right_point.y - self.top_right_point.y

    # Strings margin from the edge of the fretboard
    var string_margin = fretboad_left_width / 10

    # Distanses between the strings
    self.strings_distance = (fretboad_left_width - (string_margin * 2)) / 5

    # Current string left and right positions. Update during iteration
    var current_left_pos = self.top_left_point + Vector2(0, string_margin)
    var current_right_pos = self.top_right_point + Vector2(0, string_margin)
    for i in range(6):
        self.strings.append(DataTypes.AString.new(current_left_pos, current_right_pos))

        current_left_pos += Vector2(0, self.strings_distance)
        current_right_pos += Vector2(0, self.strings_distance)

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
    for i in self.frets.size():
        var fret = self.frets[i]
        draw_line(fret.top_point, fret.bottom_point, Color(.4, .4, .4), 5, true)

func __draw_zero_fret():
    if self.first_fret_num != 0:
        return

    var fret = self.frets[0]
    draw_line(fret.top_point, fret.bottom_point, Color(.8, .8, .8), 15, true)

func __draw_markers():
    # Marker margin from one side
    var marker_margin = Vector2(1./4, 2./12)

    var draw_dot = func(square_bw_frets: Rect2):
        var pos = square_bw_frets.position + square_bw_frets.size * marker_margin
        var rect_size = square_bw_frets.size * (Vector2.ONE - marker_margin * 2)

        draw_rect(Rect2(pos, rect_size), Color(.9, .9, .9))

    var draw_double_dot = func(square_bw_frets: Rect2):
        # Make 12 fret a bit longer
        var twelve_margin = marker_margin * Vector2(1., 0.7)

        var pos = square_bw_frets.position + square_bw_frets.size * twelve_margin
        # Total markers size
        var rect_size = square_bw_frets.size * (Vector2.ONE - twelve_margin * 2)
        # Single marker size
        var single_marker_size = Vector2(rect_size.x, rect_size.y * 0.45)

        # Top square
        draw_rect(Rect2(pos, single_marker_size), Color(.9, .9, .9))
        # Bottom square
        draw_rect(Rect2(pos + rect_size, -single_marker_size), Color(.9, .9, .9))

    var indices_to_draw = {
        3:  null,
        5:  null,
        7:  null,
        9:  null,
        15:  null,
        17:  null,
        19:  null,
        21:  null
        }

    # Draw regular dot
    for i in range(self.first_fret_num, self.first_fret_num + self.num_frets):
        # Index of the fret in self array
        var self_fret_index = i - self.first_fret_num
        if i == 11:
            # Draw 12 fret dot
            draw_double_dot.call(Rect2(self.frets[self_fret_index].top_point,
                            self.frets[self_fret_index + 1].bottom_point - self.frets[self_fret_index].top_point))
        elif (i + 1) in indices_to_draw:
            draw_dot.call(Rect2(self.frets[self_fret_index].top_point,
                        self.frets[self_fret_index + 1].bottom_point - self.frets[self_fret_index].top_point))

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
                  Color(0, 0, 0, .5), strings_width[i] * 2, true)

        # Draw string
        draw_line(self.strings[i].left_point, self.strings[i].right_point,
                  string_colors[i], strings_width[i] / 2, true)

func __draw_fret_num():
    var top_margin = 50

    if self.first_fret_num == 0:
        return

    draw_char(get_theme_default_font(), self.bottom_left_point + Vector2(-10, top_margin),
        "%d" % self.first_fret_num,
        30, Color(.5, .5, .5))

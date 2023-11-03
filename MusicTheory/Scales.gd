class_name Scale

var notes = {}
var __root: Note

static func empty():
    return Scale.new()

static func note(a_note: Note):
    return Scale.__new_with_steps(a_note, [])

static func major(a_root: Note) -> Scale:
    return Scale.__new_with_steps(a_root, [2, 4, 5, 7, 9, 11])

static func minor(a_root: Note) -> Scale:
    return Scale.__new_with_steps(a_root, [2, 3, 5, 7, 8, 10])

static func minor_pentatonic(a_root: Note) -> Scale:
    return Scale.__new_with_steps(a_root, [3, 5, 7, 10])


func contains(a_note: Note) -> bool:
    return a_note.note in self.notes

func root() -> Note:
    return self.__root

# TODO: it probably doesnt' work
func _all_notes_in_scale() -> Array[Note]:
    var result: Array[Note] = [self.__root]

    var current_note = self.__root

    # Set current note octave to 2 - the lovest possible on the freatboard
    current_note.octave = 2
    # Find all notes in the sclae while note's not equal to D6 - the highest possible
    var highest_possible_note = Note.new(Note.D, 6)
    while true:
        current_note = current_note.shift(1)
        if self.contains(current_note):
            result.append(current_note)
        if current_note.equal(highest_possible_note):
            break

    return result

static func __new_with_steps(a_root: Note, steps: Array[int]) -> Scale:
    a_root.octave = 0

    var this = Scale.new()
    this.__root = a_root
    this.notes[a_root.note] = null

    for step in steps:
        var next_note = a_root.shift(step)
        assert(next_note.note not in this.notes)
        this.notes[next_note.note] = null

    return this

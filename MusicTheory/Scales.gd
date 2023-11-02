class_name Scale

var notes = {}
var __root: Note

static func major(root: Note) -> Scale:
    return Scale.__new_with_steps(root, [2, 4, 5, 7, 9, 11])

static func minor(root: Note) -> Scale:
    return Scale.__new_with_steps(root, [2, 3, 5, 7, 8, 10])

static func minor_pentatonic(root: Note) -> Scale:
    return Scale.__new_with_steps(root, [3, 5, 7, 10])

func contains(note: Note) -> bool:
    return note.note in self.notes

func root() -> Note:
    return self.__root

static func __new_with_steps(a_root: Note, steps: Array[int]) -> Scale:
    a_root.octave = 0

    var this = Scale.new()
    this.__root = a_root
    this.notes[a_root.note] = null

    for step in steps:
        var note = a_root.shift(step)
        assert(note.note not in this.notes)
        this.notes[note.note] = null

    return this

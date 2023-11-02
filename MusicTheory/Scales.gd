class_name Scale

var notes = {}

static func major(root: Note) -> Scale:
    root.octave = 0
    return Scale.__new_with_steps(root, [2, 4, 5, 7, 9, 11])

static func minor(root: Note) -> Scale:
    root.octave = 0
    return Scale.__new_with_steps(root, [2, 3, 5, 7, 8, 10])

static func minor_pentatonic(root: Note) -> Scale:
    root.octave = 0
    return Scale.__new_with_steps(root, [3, 5, 7, 10])

func contains_note(note: Note) -> bool:
    return note.note in self.notes

static func __new_with_steps(root: Note, steps: Array[int]) -> Scale:
    var this = Scale.new()
    this.notes[root.note] = null

    for step in steps:
        var note = root.shift(step)
        assert(note.note not in this.notes)
        this.notes[note.note] = null

    return this

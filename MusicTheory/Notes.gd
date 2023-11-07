class_name Note

const NOTES_STRINGS: Array[String] = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']

enum {
    C,
    C_SHARP,
    D,
    D_SHARP,
    E,
    F,
    F_SHARP,
    G,
    G_SHARP,
    A,
    A_SHARP,
    B
}

var note: int
var octave: int

static var sounds = {
    'E2': load('res://Sounds/E2.ogg'), 'F2': load('res://Sounds/F2.ogg'), 'F#2': load('res://Sounds/F#2.ogg'),
    'G2': load('res://Sounds/G2.ogg'), 'G#2': load('res://Sounds/G#2.ogg'), 'A2': load('res://Sounds/A2.ogg'),
    'A#2': load('res://Sounds/A#2.ogg'), 'B2': load('res://Sounds/B2.ogg'), 'C3': load('res://Sounds/C3.ogg'),
    'C#3': load('res://Sounds/C#3.ogg'), 'D3': load('res://Sounds/D3.ogg'), 'D#3': load('res://Sounds/D#3.ogg'),
    'E3': load('res://Sounds/E3.ogg'), 'F3': load('res://Sounds/F3.ogg'), 'F#3': load('res://Sounds/F#3.ogg'),
    'G3': load('res://Sounds/G3.ogg'), 'G#3': load('res://Sounds/G#3.ogg'), 'A3': load('res://Sounds/A3.ogg'),
    'A#3': load('res://Sounds/A#3.ogg'), 'B3': load('res://Sounds/B3.ogg'), 'C4': load('res://Sounds/C4.ogg'),
    'C#4': load('res://Sounds/C#4.ogg'), 'D4': load('res://Sounds/D4.ogg'), 'D#4': load('res://Sounds/D#4.ogg'),
    'E4': load('res://Sounds/E4.ogg'), 'F4': load('res://Sounds/F4.ogg'), 'F#4': load('res://Sounds/F#4.ogg'),
    'G4': load('res://Sounds/G4.ogg'), 'G#4': load('res://Sounds/G#4.ogg'), 'A4': load('res://Sounds/A4.ogg'),
    'A#4': load('res://Sounds/A#4.ogg'), 'B4': load('res://Sounds/B4.ogg'), 'C5': load('res://Sounds/C5.ogg'),
    'C#5': load('res://Sounds/C#5.ogg'), 'D5': load('res://Sounds/D5.ogg'), 'D#5': load('res://Sounds/D#5.ogg'),
    'E5': load('res://Sounds/E5.ogg'), 'F5': load('res://Sounds/F5.ogg'), 'F#5': load('res://Sounds/F#5.ogg'),
    'G5': load('res://Sounds/G5.ogg'), 'G#5': load('res://Sounds/G#5.ogg'), 'A5': load('res://Sounds/A5.ogg'),
    'A#5': load('res://Sounds/A#5.ogg'), 'B5': load('res://Sounds/B5.ogg'), 'C6': load('res://Sounds/C6.ogg'),
    'C#6': load('res://Sounds/C#6.ogg'), 'D6': load('res://Sounds/D6.ogg'),
}

func _init(a_note: int, an_octave):
    self.note = a_note
    self.octave = an_octave

func _to_string():
    return "%s%d" % [NOTES_STRINGS[self.note], self.octave]

func note_string():
    return NOTES_STRINGS[self.note]

func shift(steps: int) -> Note:
    @warning_ignore("integer_division")
    return Note.new((self.note + steps) % 12, self.octave + (self.note + steps) / 12)

# Compare note disregard to an octave
func is_same_note(other: int) -> bool:
    return self.note == other

func equal(other: Note) -> bool:
    return self.note == other.note and self.octave == other.octave

func play_sound(a_player: AudioStreamPlayer):
    var sound = Note.sounds[self._to_string()]
    a_player.set_stream(sound)
    a_player.play()

static func note_to_string(a_note: int) -> String:
    #print('--> %d %s', a_note, NOTES_STRINGS[a_note])
    return NOTES_STRINGS[a_note]

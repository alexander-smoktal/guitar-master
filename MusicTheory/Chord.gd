class_name Chord

var notes: Array[Note] = []
var chord_name: String

# Audio players to play the chord. Instantiate now to be able to play only one chord
static var audio_players: Array[AudioStreamPlayer] = []

static func E_major(first_fret: int = 0) -> Chord:
    var result: Chord = Chord.new('E')
    match first_fret:
        0:
            result.notes = [Note.new(Note.E, 2), Note.new(Note.B, 2), Note.new(Note.E, 3),
                Note.new(Note.G_SHARP, 3), Note.new(Note.B, 3), Note.new(Note.E, 4)]

    return result

static func E_minor(first_fret: int = 0) -> Chord:
    var result: Chord = Chord.new('Em')
    match first_fret:
        0:
            result.notes = [Note.new(Note.E, 2), Note.new(Note.B, 2), Note.new(Note.E, 3),
                Note.new(Note.G, 3), Note.new(Note.B, 3), Note.new(Note.E, 4)]

    return result

func _init(a_chord_name: String):
    self.chord_name = a_chord_name

func _to_string():
    return self.chord_name

func contains(note: int) -> bool:
    for self_note in self.notes:
        # Method compares only not w/o the octate
        if self_note.is_same_note(note):
            return true
    return false

func contains_note(note: Note) -> bool:
    for self_note in self.notes:
        # Method compares only not w/o the octate
        if self_note.equal(note):
            return true
    return false

func play_sound(a_node: Node, first_note: int = 0, num_notes: int = 6):
    var notes_delay = .05

    self.__init_players(a_node)

    var tween = a_node.create_tween()
    for i in range(first_note, first_note + num_notes):
        tween.tween_callback(self.notes[i].play_sound.bind(Chord.audio_players[i])).set_delay(notes_delay)

func __init_players(a_node: Node):
    if not Chord.audio_players.is_empty():
        return

    for i in 6:
        var player = AudioStreamPlayer.new()
        # Make each sound quiter
        player.set_volume_db(-13)
        a_node.add_child(player)
        audio_players.append(player)

func __free_audio_players(players: Array[AudioStreamPlayer]):
    for player in players:
        player.queue_free()

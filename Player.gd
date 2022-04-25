extends KinematicBody2D

const UP = Vector2(0, 1)
const FLAP = 200
const MAXFALLSPEED = 200
const GRAVITY = 10

var motion = Vector2()
var Wall = preload("res://WallNode.tscn")
var score = 0

var spectrum
var note_strings = [
	"C",
	"Db",
	"D",
	"Eb",
	"E",
	"F",
	"Gb",
	"G",
	"Ab",
	"A",
	"Bb",
	"B"
]
var fftsize = 1024 # match size of effect on mic

func _ready():
	spectrum = AudioServer.get_bus_effect_instance(1, 1)

func note_from_pitch(freq):
	var note_num = 12 * log(freq / 440) / log(2)
	return int(round(note_num) + 69)

func _physics_process(delta):
	motion.y += GRAVITY
	if motion.y > MAXFALLSPEED:
		motion.y = MAXFALLSPEED

	if Input.is_action_just_pressed("FLAP"):
		motion.y = -FLAP

	motion = move_and_slide(motion, UP)
	
	get_parent().get_parent().get_node("CanvasLayer/ScoreLabel").text = str(score)
	
#	var lowest_frequency = 27.5
#	var max_mag = -1000
#	var max_freq = -1
#	for idx in range(0, 88):
#		var freq = lowest_frequency * pow(2.0, (1.0 / 12.0) * idx)
#		var frequency_start: float = lowest_frequency * pow(2.0, (1.0 / 12.0) * (idx - 0.4))
#		var frequency_end: float = lowest_frequency * pow(2.0, (1.0 / 12.0) * (idx + 0.4))
#
#		var magnitude: Vector2 = spectrum.get_magnitude_for_frequency_range(frequency_start, frequency_end, AudioEffectSpectrumAnalyzerInstance.MAGNITUDE_AVERAGE)
#		var magnitude_db: float = linear2db((magnitude.x + magnitude.y) / 2)
#		if magnitude_db > max_mag:
#			max_freq = freq
#			max_mag = magnitude_db
#
#	var pitch_label = get_parent().get_parent().get_node("CanvasLayer/PitchLabel")
#	if max_mag > -50:
#		var note = note_strings[note_from_pitch(max_freq) % 12]
#		pitch_label.text = note
#
#		var normalized = (max_freq - 138.59) / (1046.50 - 138.59)
#		position.y = (normalized * 288) - 144
#	else:
#		pitch_label.text = ""

func Wall_reset():
	var Wall_instance = Wall.instance()
	Wall_instance.position = Vector2(450, rand_range(-60, 60))
	get_parent().call_deferred("add_child", Wall_instance)
	
func _on_Resetter_body_entered(body):
	if body.name == "Walls":
		body.queue_free()
		Wall_reset()

func _on_Detect_area_entered(area):
	if area.name == "PointArea":
		score += 1

func _on_Detect_body_entered(body):
	if body.name == "Walls" or body.name == "Barrier":
		get_tree().reload_current_scene()

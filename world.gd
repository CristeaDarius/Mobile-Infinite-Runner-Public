extends Node2D


@onready var part1 = $Part1
@onready var part2 = $Part2

@onready var start = $Start.position
@onready var end = $End.position

@onready var btnStart = $CanvasLayer/ButtonStart
@onready var btnMenu = $CanvasLayer/ButtonMenu
@onready var menu = $CanvasLayer/Menu

@onready var score = $CanvasLayer/Score
@onready var time = $CanvasLayer/Menu/Time
@onready var highScore = $CanvasLayer/HighScore

@onready var endMenu = $CanvasLayer/EndMenu

@onready var movBtns = $CanvasLayer/MovementButtons

@onready var player = $Player

@onready var lineL = $TrailL
@onready var lineR = $TrailR

@onready var musicPlayer = $MusicPlayer
@onready var soundsPlayer = $SoundsPlayer

@onready var stuffSpawner = $StuffSpawner

@onready var credits = $CanvasLayer/Credits

const music = [
	preload("res://assets/sounds/jingle-snow-182330.mp3"),
	preload("res://assets/sounds/silly-pups-in-snow-222528.mp3"),
	preload("res://assets/sounds/snow-268420.mp3")
]

const endSound = preload("res://assets/sounds/hit-tree-01-266310.mp3")
const menuSound = preload("res://assets/sounds/menu-selection-102220.mp3")

const savePath = "user://save_file.json"

var seconds = 0
var minutes = 0
var hours = 0

var points = 0

var health = 1;

const speed = 100

var moveTilt = true

var random = RandomNumberGenerator.new()

var lastMusic = -1

var save_data = {
	"points": points,
	"moveTilt": moveTilt,
	"sounds": 5,
	"music": 5
}

func reset():
	highScore.text = str(save_data.points)
	stuffSpawner.reload(2)
	toggleMenu()
	btnMenu.visible = false
	score.visible = false
	highScore.visible = true
	endMenu.visible = false
	movBtns.visible = false
	credits.visible = false
	
	$CanvasLayer/MovementType.visible = true
	if save_data.moveTilt:
		$CanvasLayer/MovementType/ButtonTilt.grab_focus()
	else:
		$CanvasLayer/MovementType/ButtonButtons.grab_focus()
	
	get_tree().paused = true
	AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("Music"), 0, false)

func _ready():
	handleSave()
	reset()
	random.randomize()
	
	$CanvasLayer/Menu/Music.value = save_data.music
	$CanvasLayer/Menu/Sounds.value = save_data.sounds
	adjustSounds()
	playRandomMusic()


func _process(delta):
	part1.position.y -= speed * delta
	part2.position.y -= speed * delta
	
	if part1.position.y < end.y:
		stuffSpawner.reload(1)
		part1.position.y = start.y
	
	if part2.position.y < end.y:
		stuffSpawner.reload(2)
		part2.position.y = start.y
	
	handleTrail(speed*delta)

func handleTrail(off):
	lineL.add_point(player.position)
	for i in range(lineL.get_point_count()):
		var point = lineL.get_point_position(i)
		point.y -= off
		lineL.set_point_position(i, point)
	lineR.add_point(player.position)
	for i in range(lineR.get_point_count()):
		var point = lineR.get_point_position(i)
		point.y -= off
		lineR.set_point_position(i, point)


func _on_button_start_pressed():
	playSound(menuSound)
	btnMenu.visible = true
	btnStart.visible = false
	score.visible = true
	movBtns.visible = !save_data.moveTilt
	$CanvasLayer/MovementType.visible = false
	get_tree().paused = false


func _on_button_menu_button_down():
	get_tree().paused = !get_tree().paused
	toggleMenu()
	playSound(menuSound)

func toggleMenu():
	movBtns.visible = false
	menu.visible = not menu.visible
	if menu.visible:
		if save_data.moveTilt:
			$CanvasLayer/Menu/MovementType/ButtonTilt.grab_focus()
		else:
			$CanvasLayer/Menu/MovementType/ButtonButtons.grab_focus()
	else:
		movBtns.visible = !save_data.moveTilt


func _on_timer_timeout():
	seconds += 1;
	
	if seconds == 60:
		seconds = 0
		minutes +=1;
	
	if minutes == 60:
		minutes = 0
		hours += 1
	
	time.text = str(hours).pad_zeros(2) + ":" + str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)

func increaseScore(s):
	points += s
	score.text = str(points);

func decreaseHealth(h):
	health -= h
	if health <= 0:
		endGame()

func endGame():
	playSound(endSound)
	AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("Music"), 0, true)
	
	if points > save_data.points:
		save_data.points = points
		saveData()
	
	$CanvasLayer/EndMenu/Control/Control/HighScore.text = str(save_data.points)
	btnMenu.visible = false
	score.visible = false
	highScore.visible = false
	endMenu.visible = true
	movBtns.visible = false
	get_tree().paused = true
	$CanvasLayer/EndMenu/Control/Control/Score.text = str(points)
	$CanvasLayer/EndMenu/Control/Control/Time.text = time.text


func _on_retry_pressed():
	btnStart.visible = false
	get_tree().reload_current_scene()


func _on_button_tilt_pressed():
	playSound(menuSound)
	moveTilt = true
	save_data.moveTilt = moveTilt
	saveData()


func _on_button_buttons_pressed():
	playSound(menuSound)
	moveTilt = false
	save_data.moveTilt = moveTilt
	saveData()

func handleSave():
	if !FileAccess.file_exists(savePath):
		saveData()
	else:
		save_data = loadSave()


func saveData():
	var file = FileAccess.open(savePath, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()

func loadSave() -> Dictionary:
	var file = FileAccess.open(savePath, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		var json = JSON.new()
		var parsed = json.parse(content)
		
		if parsed == OK:
			return json.get_data()
	return {}

func _on_music_player_finished():
	playRandomMusic()

func playRandomMusic():
	var indexes = []
	
	for i in range(music.size()):
		indexes.append(i)
	
	if lastMusic != -1:
		indexes.erase(lastMusic)
	
	lastMusic = indexes[random.randi_range(0, indexes.size() - 1)]
	musicPlayer.stream = music[lastMusic]
	musicPlayer.play()


func _on_music_value_changed(value):
	save_data.music = value
	saveData()
	adjustSounds()
	playSound(menuSound)


func _on_sounds_value_changed(value):
	save_data.sounds = value
	saveData()
	adjustSounds()
	playSound(menuSound)

func adjustSounds():
	var music_db = -40 + (save_data.music * 4)
	music_db = clamp(music_db, -40, 0)
	if music_db == -36: AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), true)
	else: AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), false)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), music_db)
	
	var sounds_db = -40 + (save_data.sounds * 4)
	sounds_db = clamp(sounds_db, -40, 0)
	if sounds_db == -36: AudioServer.set_bus_mute(AudioServer.get_bus_index("Sounds") ,true)
	else: AudioServer.set_bus_mute(AudioServer.get_bus_index("Sounds"), false)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"), sounds_db)

func playSound(s):
	soundsPlayer.stream = s
	soundsPlayer.play()


func _on_button_pressed():
	playSound(menuSound)
	credits.visible = true
	menu.visible = false


func _on_close_credits_pressed():
	playSound(menuSound)
	credits.visible = false
	menu.visible = true

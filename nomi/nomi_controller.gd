extends Node

## NOMI controller: state machine managing NOMI's behavior during races.
## States: idle, navigating, commenting, celebrating

enum NOMIState { IDLE, NAVIGATING, COMMENTING, CELEBRATING }

signal state_changed(new_state: NOMIState)
signal expression_changed(expression: String)
signal commentary_requested(text: String, duration: float)

var current_state: NOMIState = NOMIState.IDLE
var state_timer: float = 0.0
var comment_cooldown: float = 0.0

# Race data references
var player_car: VehicleBody3D
var race_manager: Node  # RaceManager autoload

# Commentary triggers
var last_position: int = 1
var last_lap: int = 0
var was_drifting: bool = false
var near_miss_distance: float = 100.0

# Configuration
const COMMENT_COOLDOWN: float = 3.0
const POSITION_CHANGE_COMMENT_CHANCE: float = 0.8
const LAP_COMMENT_CHANCE: float = 1.0
const DRIFT_COMMENT_CHANCE: float = 0.5

func _ready() -> void:
	race_manager = RaceManager

func _process(delta: float) -> void:
	comment_cooldown = maxf(comment_cooldown - delta, 0.0)
	state_timer += delta

	match current_state:
		NOMIState.IDLE:
			_process_idle(delta)
		NOMIState.NAVIGATING:
			_process_navigating(delta)
		NOMIState.COMMENTING:
			_process_commenting(delta)
		NOMIState.CELEBRATING:
			_process_celebrating(delta)

func set_player_car(car: VehicleBody3D) -> void:
	player_car = car

func start_race() -> void:
	current_state = NOMIState.NAVIGATING
	state_timer = 0.0
	expression_changed.emit("happy")

func _process_idle(_delta: float) -> void:
	pass

func _process_navigating(_delta: float) -> void:
	if not player_car or not race_manager:
		return

	# Check for position changes
	var current_pos: int = race_manager.get_car_position(player_car)
	if current_pos != last_position:
		if comment_cooldown <= 0.0 and randf() < POSITION_CHANGE_COMMENT_CHANCE:
			var direction: String = "up" if current_pos < last_position else "down"
			_comment_on_position_change(current_pos, direction)
		last_position = current_pos

	# Check for lap completion
	var current_lap: int = race_manager.get_car_lap(player_car)
	if current_lap > last_lap:
		if comment_cooldown <= 0.0 and randf() < LAP_COMMENT_CHANCE:
			_comment_on_lap(current_lap)
		last_lap = current_lap

	# Check for drifting
	if player_car.is_drifting and not was_drifting:
		if comment_cooldown <= 0.0 and randf() < DRIFT_COMMENT_CHANCE:
			_comment_on_drift()
		was_drifting = true
	elif not player_car.is_drifting:
		was_drifting = false

func _process_commenting(_delta: float) -> void:
	# Wait for commentary to finish
	if state_timer > 3.0:
		_change_state(NOMIState.NAVIGATING)

func _process_celebrating(_delta: float) -> void:
	if state_timer > 5.0:
		_change_state(NOMIState.IDLE)

func _change_state(new_state: NOMIState) -> void:
	current_state = new_state
	state_timer = 0.0
	state_changed.emit(new_state)

func _comment_on_position_change(new_pos: int, direction: String) -> void:
	comment_cooldown = COMMENT_COOLDOWN
	_change_state(NOMIState.COMMENTING)

	var text: String
	if direction == "up":
		match new_pos:
			1:
				text = "You're in the lead! Amazing driving!"
				expression_changed.emit("celebrating")
			2:
				text = "Second place! Keep pushing!"
				expression_changed.emit("happy")
			3:
				text = "Podium position! Great overtake!"
				expression_changed.emit("happy")
			_:
				text = "Nice move! You're now P%d!" % new_pos
				expression_changed.emit("happy")
	else:
		match new_pos:
			1:
				text = "Lost the lead... Let's get it back!"
				expression_changed.emit("nervous")
			_:
				text = "Dropped to P%d. Stay focused!" % new_pos
				expression_changed.emit("nervous")

	commentary_requested.emit(text, 3.0)

func _comment_on_lap(lap: int) -> void:
	comment_cooldown = COMMENT_COOLDOWN
	_change_state(NOMIState.COMMENTING)

	var total_laps: int = race_manager.total_laps
	var text: String
	if lap >= total_laps:
		text = "Final lap! Give it everything!"
		expression_changed.emit("surprised")
	elif lap == total_laps - 1:
		text = "Last lap coming up! Stay sharp!"
		expression_changed.emit("happy")
	else:
		text = "Lap %d complete! Keep it up!" % lap
		expression_changed.emit("happy")

	commentary_requested.emit(text, 3.0)

func _comment_on_drift() -> void:
	comment_cooldown = COMMENT_COOLDOWN
	_change_state(NOMIState.COMMENTING)

	var drift_comments: Array[String] = [
		"Nice drift!",
		"Smooth slide!",
		"That was beautiful!",
		"Drift king!",
		"Incredible control!",
	]
	var text: String = drift_comments[randi() % drift_comments.size()]
	expression_changed.emit("happy")
	commentary_requested.emit(text, 2.0)

func celebrate_victory() -> void:
	_change_state(NOMIState.CELEBRATING)
	expression_changed.emit("celebrating")
	commentary_requested.emit("You did it! First place! Incredible race!", 5.0)

func react_to_collision() -> void:
	if comment_cooldown > 0.0:
		return
	comment_cooldown = COMMENT_COOLDOWN
	_change_state(NOMIState.COMMENTING)
	expression_changed.emit("surprised")
	commentary_requested.emit("Watch out! That was close!", 2.0)

func react_to_speed(speed_kph: float) -> void:
	if speed_kph > 250.0 and comment_cooldown <= 0.0:
		comment_cooldown = COMMENT_COOLDOWN * 2.0
		_change_state(NOMIState.COMMENTING)
		expression_changed.emit("surprised")
		commentary_requested.emit("Wow! %d km/h! Incredible speed!" % int(speed_kph), 3.0)

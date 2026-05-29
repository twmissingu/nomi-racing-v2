extends Node

## NOMI controller: state machine managing NOMI's behavior during races.
## Uses NOMIExpressions for visual states and NOMICommentary for text.

enum NOMIState { IDLE, NAVIGATING, COMMENTING, CELEBRATING }

signal state_changed(new_state: NOMIState)
signal expression_changed(expression: String)
signal commentary_requested(text: String, duration: float)

var current_state: NOMIState = NOMIState.IDLE
var state_timer: float = 0.0
var comment_cooldown: float = 0.0

# Race data references
var player_car: VehicleBody3D
var race_manager: Node

# Commentary triggers
var last_position: int = 1
var last_lap: int = 0
var was_drifting: bool = false
var collision_count: int = 0
var drift_total: float = 0.0
var best_lap_time: float = 0.0

# Configuration
const COMMENT_COOLDOWN: float = 3.5
const POSITION_CHANGE_COMMENT_CHANCE: float = 0.85
const LAP_COMMENT_CHANCE: float = 1.0
const DRIFT_COMMENT_CHANCE: float = 0.6
const SPEED_COMMENT_CHANCE: float = 0.3

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
	drift_total = 0.0
	best_lap_time = 0.0
	expression_changed.emit("happy")
	# Race start comment
	comment_cooldown = COMMENT_COOLDOWN
	_change_state(NOMIState.COMMENTING)
	commentary_requested.emit(NOMICommentary.get_race_start_comment(), 3.0)

func _process_idle(_delta: float) -> void:
	pass

func _process_navigating(delta: float) -> void:
	if not player_car or not race_manager:
		return

	# Check for position changes
	var current_pos: int = race_manager.get_car_position(player_car)
	if current_pos != last_position:
		if comment_cooldown <= 0.0 and randf() < POSITION_CHANGE_COMMENT_CHANCE:
			if current_pos < last_position:
				_comment_overtake(current_pos)
			else:
				_comment_overtaken(current_pos)
		last_position = current_pos

	# Check for lap completion
	var current_lap: int = race_manager.get_car_lap(player_car)
	if current_lap > last_lap:
		if comment_cooldown <= 0.0 and randf() < LAP_COMMENT_CHANCE:
			_comment_on_lap(current_lap)
		last_lap = current_lap

	# Check for drifting — track duration and trigger commentary
	if player_car.is_drifting:
		drift_total += delta
		AchievementManager.check_drift(drift_total)
		if not was_drifting:
			if comment_cooldown <= 0.0 and randf() < DRIFT_COMMENT_CHANCE:
				_comment_on_drift()
			was_drifting = true
	else:
		was_drifting = false

	# Check for high speed
	if player_car.current_speed_kph > 250.0 and comment_cooldown <= 0.0:
		if randf() < SPEED_COMMENT_CHANCE:
			_comment_on_speed(player_car.current_speed_kph)

func _process_commenting(_delta: float) -> void:
	if state_timer > 3.0:
		_change_state(NOMIState.NAVIGATING)

func _process_celebrating(_delta: float) -> void:
	if state_timer > 5.0:
		_change_state(NOMIState.IDLE)

func _change_state(new_state: NOMIState) -> void:
	current_state = new_state
	state_timer = 0.0
	state_changed.emit(new_state)

func _comment_overtake(new_pos: int) -> void:
	comment_cooldown = COMMENT_COOLDOWN
	_change_state(NOMIState.COMMENTING)

	if new_pos == 1:
		expression_changed.emit("celebrating")
		commentary_requested.emit("You're in the lead! " + NOMICommentary.get_overtake_comment(), 3.0)
	else:
		expression_changed.emit("happy")
		commentary_requested.emit(NOMICommentary.get_overtake_comment(), 3.0)

func _comment_overtaken(new_pos: int) -> void:
	comment_cooldown = COMMENT_COOLDOWN
	_change_state(NOMIState.COMMENTING)

	if new_pos == 1:
		expression_changed.emit("nervous")
		commentary_requested.emit(NOMICommentary.get_being_overtaken_comment(), 3.0)
	else:
		expression_changed.emit("nervous")
		commentary_requested.emit(NOMICommentary.get_being_overtaken_comment(), 3.0)

func _comment_on_lap(lap: int) -> void:
	comment_cooldown = COMMENT_COOLDOWN
	_change_state(NOMIState.COMMENTING)

	# Check for fastest lap
	var lap_time: float = race_manager.get_car_last_lap_time(player_car)
	if lap_time > 0.0 and (best_lap_time <= 0.0 or lap_time < best_lap_time):
		best_lap_time = lap_time
		expression_changed.emit("celebrating")
		commentary_requested.emit(NOMICommentary.get_fastest_lap_comment(), 3.0)
		return

	var total_laps: int = race_manager.total_laps
	if lap >= total_laps:
		expression_changed.emit("surprised")
		commentary_requested.emit(NOMICommentary.get_final_lap_comment(), 3.0)
	else:
		expression_changed.emit("happy")
		commentary_requested.emit(NOMICommentary.get_lap_complete_comment(), 3.0)

func _comment_on_drift() -> void:
	comment_cooldown = COMMENT_COOLDOWN
	_change_state(NOMIState.COMMENTING)
	expression_changed.emit("happy")
	commentary_requested.emit(NOMICommentary.get_drift_comment(), 2.0)

func _comment_on_speed(speed_kph: float) -> void:
	comment_cooldown = COMMENT_COOLDOWN * 2.0
	_change_state(NOMIState.COMMENTING)
	expression_changed.emit("surprised")
	commentary_requested.emit(NOMICommentary.get_speed_comment() + " %d km/h!" % int(speed_kph), 3.0)

func celebrate_victory() -> void:
	_change_state(NOMIState.CELEBRATING)
	expression_changed.emit("celebrating")
	commentary_requested.emit(NOMICommentary.get_victory_comment(), 5.0)

func celebrate_podium() -> void:
	_change_state(NOMIState.CELEBRATING)
	expression_changed.emit("celebrating")
	commentary_requested.emit(NOMICommentary.get_podium_comment(), 4.0)

func react_to_collision() -> void:
	if comment_cooldown > 0.0:
		return
	comment_cooldown = COMMENT_COOLDOWN
	_change_state(NOMIState.COMMENTING)
	expression_changed.emit("surprised")
	collision_count += 1
	commentary_requested.emit(NOMICommentary.get_collision_comment(), 2.0)

func get_collision_count() -> int:
	return collision_count

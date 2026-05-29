extends RefCounted

## NOMI race commentary text generation.
## Provides contextual comments based on race events.

# Pre-written commentary pools
const RACE_START_COMMENTS := [
	"Let's go! Show them what you've got!",
	"Race time! I believe in you!",
	"Here we go! Smooth driving!",
	"Green light! Let's do this!",
]

const OVERTAKE_COMMENTS := [
	"Great overtake!",
	"Beautiful move!",
	"Clean pass!",
	"That's how it's done!",
	"Brilliant driving!",
]

const BEING_OVERTAKEN_COMMENTS := [
	"They got past... Stay focused!",
	"Don't give up! Push harder!",
	"Let them go for now. We'll get them back!",
]

const FASTEST_LAP_COMMENTS := [
	"That's the fastest lap! Incredible!",
	"New fastest lap! You're on fire!",
	"Record pace! Keep it going!",
]

const FINAL_LAP_COMMENTS := [
	"Final lap! Everything you've got!",
	"Last one! This is it!",
	"The final lap! Make it count!",
]

const VICTORY_COMMENTS := [
	"WINNER! You did it!",
	"FIRST PLACE! What a race!",
	"Champion! Incredible performance!",
	"P1! You're unstoppable!",
]

const PODIUM_COMMENTS := [
	"PODIUM! Great result!",
	"Top 3! Fantastic race!",
	"Podium finish! Well done!",
]

const COLLISION_COMMENTS := [
	"Watch out!",
	"Careful!",
	"That was close!",
	"Easy there!",
]

const SPEED_COMMENTS := [
	"What a speed!",
	"Incredible pace!",
	"You're flying!",
	"Maximum attack!",
]

const DRIFT_COMMENTS := [
	"Nice drift!",
	"Smooth slide!",
	"Beautiful angle!",
	"Drift master!",
]

const LAP_COMPLETE_COMMENTS := [
	"Lap done! Keep pushing!",
	"Good lap! Stay consistent!",
	"Solid lap! Keep it up!",
]

static func get_race_start_comment() -> String:
	return RACE_START_COMMENTS[randi() % RACE_START_COMMENTS.size()]

static func get_overtake_comment() -> String:
	return OVERTAKE_COMMENTS[randi() % OVERTAKE_COMMENTS.size()]

static func get_being_overtaken_comment() -> String:
	return BEING_OVERTAKEN_COMMENTS[randi() % BEING_OVERTAKEN_COMMENTS.size()]

static func get_fastest_lap_comment() -> String:
	return FASTEST_LAP_COMMENTS[randi() % FASTEST_LAP_COMMENTS.size()]

static func get_final_lap_comment() -> String:
	return FINAL_LAP_COMMENTS[randi() % FINAL_LAP_COMMENTS.size()]

static func get_victory_comment() -> String:
	return VICTORY_COMMENTS[randi() % VICTORY_COMMENTS.size()]

static func get_podium_comment() -> String:
	return PODIUM_COMMENTS[randi() % PODIUM_COMMENTS.size()]

static func get_collision_comment() -> String:
	return COLLISION_COMMENTS[randi() % COLLISION_COMMENTS.size()]

static func get_speed_comment() -> String:
	return SPEED_COMMENTS[randi() % SPEED_COMMENTS.size()]

static func get_drift_comment() -> String:
	return DRIFT_COMMENTS[randi() % DRIFT_COMMENTS.size()]

static func get_lap_complete_comment() -> String:
	return LAP_COMPLETE_COMMENTS[randi() % LAP_COMPLETE_COMMENTS.size()]

static func get_position_comment(position: int, total: int) -> String:
	match position:
		1:
			return "You're leading! %d cars behind you!" % (total - 1)
		2:
			return "Second place! Just one car to pass!"
		3:
			return "Podium position! Keep pushing!"
		_:
			return "P%d out of %d. Stay focused!" % [position, total]

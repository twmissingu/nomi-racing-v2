extends Node

## Achievement system with NIO community culture naming.

signal achievement_unlocked(achievement_id: String, name: String)

var unlocked_achievements: Array[String] = []
var _podium_count: int = 0

# Achievement definitions
const ACHIEVEMENTS := {
	"first_race": {
		"name": "初次上路",
		"description": "Complete your first race",
		"icon": "🏁",
	},
	"first_win": {
		"name": "首胜",
		"description": "Win your first race",
		"icon": "🏆",
	},
	"nio_collector": {
		"name": "蔚来收藏家",
		"description": "Own all 4 NIO cars",
		"icon": "🚗",
	},
	"speed_demon": {
		"name": "速度恶魔",
		"description": "Reach 300 km/h",
		"icon": "⚡",
	},
	"drift_king": {
		"name": "漂移之王",
		"description": "Drift for 10 seconds total in one race",
		"icon": "🌀",
	},
	"niwu_changke": {
		"name": "牛屋常客",
		"description": "Complete 10 races",
		"icon": "🏠",
	},
	"huandian_daren": {
		"name": "换电达人",
		"description": "Use NIO Power pit stop 5 times",
		"icon": "🔋",
	},
	"niubei_chuanqi": {
		"name": "纽北传奇",
		"description": "Beat EP9's Nurburgring record of 6:45.9",
		"icon": "👑",
	},
	"podium_master": {
		"name": "领奖台之王",
		"description": "Finish on the podium 20 times",
		"icon": "🥇",
	},
	"season_champion": {
		"name": "赛季冠军",
		"description": "Win a season championship",
		"icon": "🎖️",
	},
	"perfect_race": {
		"name": "完美比赛",
		"description": "Win a race without any collisions",
		"icon": "✨",
	},
	"comeback_king": {
		"name": "逆转之王",
		"description": "Win a race after being in last place",
		"icon": "🔄",
	},
}

func _ready() -> void:
	_load_achievements()

func _load_achievements() -> void:
	var path := "user://achievements.json"
	if FileAccess.file_exists(path):
		var file := FileAccess.open(path, FileAccess.READ)
		if file:
			var text: String = file.get_as_text()
			file.close()
			var json := JSON.new()
			if json.parse(text) == OK and json.data is Dictionary:
				if "unlocked" in json.data and json.data.unlocked is Array:
					for id in json.data.unlocked:
						unlocked_achievements.append(str(id))
				if "podium_count" in json.data:
					_podium_count = int(json.data.podium_count)
			elif json.parse(text) == OK and json.data is Array:
				# Legacy format: just an array of IDs
				for id in json.data:
					unlocked_achievements.append(str(id))

func _save_achievements() -> void:
	var data := {
		"unlocked": unlocked_achievements,
		"podium_count": _podium_count,
	}
	var file := FileAccess.open("user://achievements.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func unlock(achievement_id: String) -> void:
	if achievement_id in unlocked_achievements:
		return
	if achievement_id not in ACHIEVEMENTS:
		return

	unlocked_achievements.append(achievement_id)
	_save_achievements()

	var ach: Dictionary = ACHIEVEMENTS[achievement_id]
	achievement_unlocked.emit(achievement_id, ach.name)

func is_unlocked(achievement_id: String) -> bool:
	return achievement_id in unlocked_achievements

func get_achievement_name(achievement_id: String) -> String:
	if achievement_id in ACHIEVEMENTS:
		return ACHIEVEMENTS[achievement_id].name
	return ""

func get_achievement_description(achievement_id: String) -> String:
	if achievement_id in ACHIEVEMENTS:
		return ACHIEVEMENTS[achievement_id].description
	return ""

func get_all_achievements() -> Dictionary:
	return ACHIEVEMENTS

func get_unlocked_count() -> int:
	return unlocked_achievements.size()

func get_total_count() -> int:
	return ACHIEVEMENTS.size()

# Achievement check hooks — call these from game events

func check_race_complete(finish_position: int, total_races: int) -> void:
	if total_races == 1:
		unlock("first_race")
	if finish_position == 1:
		unlock("first_win")
	if total_races >= 10:
		unlock("niwu_changke")
	if finish_position <= 3:
		_podium_count += 1
		_save_achievements()
		if _podium_count >= 20:
			unlock("podium_master")

func check_perfect_race(finish_position: int, collision_count: int) -> void:
	if finish_position == 1 and collision_count == 0:
		unlock("perfect_race")

func check_comeback(total_cars: int, was_last: bool, finish_position: int) -> void:
	if was_last and finish_position == 1:
		unlock("comeback_king")

func check_speed(speed_kph: float) -> void:
	if speed_kph >= 300.0:
		unlock("speed_demon")

func check_nio_collection(owned_cars: Array[int]) -> void:
	var nio_indices: Array[int] = [42, 43, 44, 45]
	var all_owned: bool = true
	for idx in nio_indices:
		if idx not in owned_cars:
			all_owned = false
			break
	if all_owned:
		unlock("nio_collector")

func check_season_win() -> void:
	unlock("season_champion")

func check_drift(duration_seconds: float) -> void:
	if duration_seconds >= 10.0:
		unlock("drift_king")

class_name NOMIExpressions
extends RefCounted

## NOMI expression management: maps expression names to visual states.
## NOMI is presented as a friendly, round, animated companion.

enum Expression { HAPPY, NERVOUS, SURPRISED, CELEBRATING, IDLE, FOCUSED }

const EXPRESSION_COLORS := {
	"happy": Color(0.0, 0.63, 0.88),      # NIO Blue
	"nervous": Color(0.9, 0.6, 0.0),       # Orange
	"surprised": Color(0.9, 0.9, 0.0),     # Yellow
	"celebrating": Color(0.0, 0.9, 0.4),   # Green
	"idle": Color(0.5, 0.5, 0.6),          # Grey
	"focused": Color(0.0, 0.8, 0.9),       # Cyan
}

const EXPRESSION_EYE_STATES := {
	"happy": {"open": true, "shape": "normal", "blink": false},
	"nervous": {"open": true, "shape": "wide", "blink": true},
	"surprised": {"open": true, "shape": "wide", "blink": false},
	"celebrating": {"open": true, "shape": "happy", "blink": false},
	"idle": {"open": true, "shape": "normal", "blink": true},
	"focused": {"open": true, "shape": "narrow", "blink": false},
}

const EXPRESSION_MOUTH_STATES := {
	"happy": {"shape": "smile", "open": false},
	"nervous": {"shape": "flat", "open": false},
	"surprised": {"shape": "o", "open": true},
	"celebrating": {"shape": "smile_wide", "open": true},
	"idle": {"shape": "flat", "open": false},
	"focused": {"shape": "flat", "open": false},
}

static func get_color(expression: String) -> Color:
	return EXPRESSION_COLORS.get(expression, Color(0.5, 0.5, 0.6))

static func get_eye_state(expression: String) -> Dictionary:
	return EXPRESSION_EYE_STATES.get(expression, {"open": true, "shape": "normal", "blink": true})

static func get_mouth_state(expression: String) -> Dictionary:
	return EXPRESSION_MOUTH_STATES.get(expression, {"shape": "flat", "open": false})

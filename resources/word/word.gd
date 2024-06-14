extends Resource
class_name Word

@export var first_hint: String
@export var second_hint: String
@export var third_hint: String

@export var accepted_answers: Array[String]

var hints: Array[String]:
	get:
		return [first_hint, second_hint, third_hint]

var cleaned_accepted_answers: Array:
	get:
		return accepted_answers.map(_clean_up)
		
func _clean_up(text: String):
	return text.to_upper()

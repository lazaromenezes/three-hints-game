extends HBoxContainer

signal guessed(guess: String)

func _on_guess_text_submitted(new_text: String) -> void:
	if not new_text.is_empty():
		guessed.emit(%Guess.text.to_upper())
		%Guess.clear()

func _on_guess_visibility_changed() -> void:
	if visible:
		%Guess.grab_focus()

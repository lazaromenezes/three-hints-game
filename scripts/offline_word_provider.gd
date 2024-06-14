extends Node
class_name OfflineWordProvider

@export var words: Array[Word]

func take_random(amount: int) -> Array[Word]:
	var result: Array[Word] = []
	
	words.shuffle()
	
	for i in range(amount):
		result.push_back(words[i])
		
	return result

extends Node

class_name StringUtils

static func snake_to_sentence(snake: String) -> String:
    var words = snake.split("_")
    for i in len(words):
        if i == 0:
            words[i] = words[i].capitalize()
        else:
            words[i] = words[i].to_lower()
    return " ".join(words)

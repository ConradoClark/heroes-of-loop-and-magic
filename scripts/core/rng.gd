extends Node

func pick(entries: Dictionary[Variant, float]) -> Variant:
    var sum_of_weights = 0.0
    for weight in entries.values():
        sum_of_weights += weight
    var normalized_weights = []
    var accumulated_weight = 0.0
    for weight in entries.values():
        accumulated_weight += weight / sum_of_weights
        normalized_weights.append(accumulated_weight)
    var result = randf()
    var keys = entries.keys()
    for i in range(normalized_weights.size()):
        if result <= normalized_weights[i]:
            return keys[i]
    return null

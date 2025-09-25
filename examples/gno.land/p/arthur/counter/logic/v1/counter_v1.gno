package v1

import (
	"gno.land/p/arthur/proxy/storage"
)

// Counter V1 Logic - Simplified counter operations
// This version includes only: Add, Reset

func Add(amount int) storage.ExecFn {
	return func(state storage.State) any {
		current, exists := state.Get("counter")
		var value int
		if exists && current != nil {
			value = current.(int)
		}
		newValue := value + amount
		state.Set("counter", newValue)
		return newValue
	}
}

func Reset() storage.ExecFn {
	return func(state storage.State) any {
		state.Set("counter", 0)
		return 0
	}
}
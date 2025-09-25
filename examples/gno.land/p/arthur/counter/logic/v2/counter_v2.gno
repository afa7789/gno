package v2

import (
	"gno.land/p/arthur/proxy/storage"
)

// Counter V2 Logic - Simplified counter operations
// This version includes only: Add, Decrement

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

func Decrement() storage.ExecFn {
	return func(state storage.State) any {
		current, exists := state.Get("counter")
		var value int
		if exists && current != nil {
			value = current.(int)
		}
		newValue := value - 1
		state.Set("counter", newValue)
		return newValue
	}
}
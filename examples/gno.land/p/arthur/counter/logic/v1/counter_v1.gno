package v1

import (
	"gno.land/p/arthur/proxy/storage"
)

// Counter V1 Logic - Basic counter operations
// This version includes: Increment, Decrement, GetValue, Reset, SetValue, Add, Subtract

func Increment() storage.ExecFn {
	return func(state storage.State) any {
		current := storage.GetCustomValue(state, "counter")
		var value int
		if current != nil {
			value = current.(int)
		}
		newValue := value + 1
		storage.SetCustomValue(state, "counter", newValue)
		return newValue
	}
}

func Decrement() storage.ExecFn {
	return func(state storage.State) any {
		current := storage.GetCustomValue(state, "counter")
		var value int
		if current != nil {
			value = current.(int)
		}
		newValue := value - 1
		storage.SetCustomValue(state, "counter", newValue)
		return newValue
	}
}

func GetValue() storage.ExecFn {
	return func(state storage.State) any {
		current := storage.GetCustomValue(state, "counter")
		if current == nil {
			return 0
		}
		return current.(int)
	}
}

func Reset() storage.ExecFn {
	return func(state storage.State) any {
		storage.SetCustomValue(state, "counter", 0)
		return 0
	}
}

func SetValue(value int) storage.ExecFn {
	return func(state storage.State) any {
		storage.SetCustomValue(state, "counter", value)
		return value
	}
}

func Add(amount int) storage.ExecFn {
	return func(state storage.State) any {
		current := storage.GetCustomValue(state, "counter")
		var value int
		if current != nil {
			value = current.(int)
		}
		newValue := value + amount
		storage.SetCustomValue(state, "counter", newValue)
		return newValue
	}
}

func Subtract(amount int) storage.ExecFn {
	return func(state storage.State) any {
		current := storage.GetCustomValue(state, "counter")
		var value int
		if current != nil {
			value = current.(int)
		}
		newValue := value - amount
		storage.SetCustomValue(state, "counter", newValue)
		return newValue
	}
}
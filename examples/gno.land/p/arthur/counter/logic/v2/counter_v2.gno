package v2

import (
	"gno.land/p/arthur/proxy/storage"
)

// Counter V2 Logic - Enhanced counter operations
// This version REMOVES: Reset (deprecated)
// This version ADDS: Multiply, Divide, Power, GetHistory
// This version KEEPS: Increment, Decrement, GetValue, SetValue, Add, Subtract

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

// NEW FUNCTIONS IN V2
func Multiply(factor int) storage.ExecFn {
	return func(state storage.State) any {
		current := storage.GetCustomValue(state, "counter")
		var value int
		if current != nil {
			value = current.(int)
		}
		newValue := value * factor
		storage.SetCustomValue(state, "counter", newValue)
		return newValue
	}
}

func Divide(divisor int) storage.ExecFn {
	return func(state storage.State) any {
		if divisor == 0 {
			panic("division by zero")
		}
		current := storage.GetCustomValue(state, "counter")
		var value int
		if current != nil {
			value = current.(int)
		}
		newValue := value / divisor
		storage.SetCustomValue(state, "counter", newValue)
		return newValue
	}
}

func Power(exponent int) storage.ExecFn {
	return func(state storage.State) any {
		current := storage.GetCustomValue(state, "counter")
		var value int
		if current != nil {
			value = current.(int)
		}
		
		newValue := 1
		for i := 0; i < exponent; i++ {
			newValue *= value
		}
		storage.SetCustomValue(state, "counter", newValue)
		return newValue
	}
}

func GetHistory() storage.ExecFn {
	return func(state storage.State) any {
		historyAny := storage.GetCustomValue(state, "operation_history")
		if historyAny == nil {
			return []string{}
		}
		
		if history, ok := historyAny.([]string); ok {
			return history
		}
		return []string{}
	}
}

// Helper function to log operations (used by interpreter)
func LogOperation(operation string) storage.ExecFn {
	return func(state storage.State) any {
		historyAny := storage.GetCustomValue(state, "operation_history")
		var history []string
		if historyAny != nil {
			if h, ok := historyAny.([]string); ok {
				history = h
			}
		}
		
		history = append(history, operation)
		// Keep only last 10 operations
		if len(history) > 10 {
			history = history[len(history)-10:]
		}
		
		storage.SetCustomValue(state, "operation_history", history)
		return nil
	}
}

// NOTE: Reset function is NOT AVAILABLE in V2
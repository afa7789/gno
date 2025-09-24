package v1

import (
	"gno.land/p/arthur/proxy/interfaces"
	"gno.land/p/arthur/proxy/storage"
	counterlogicv1 "gno.land/p/arthur/counter/logic/v1"
)

// CounterInterpreterV1 - Uses counter V1 logic
type CounterInterpreterV1 struct{}

func NewCounterInterpreterV1() interfaces.IInterpreter {
	return &CounterInterpreterV1{}
}

func (ci *CounterInterpreterV1) GetVersion() string {
	return "counter-interpreter-v1.0.0"
}

func (ci *CounterInterpreterV1) GetSupportedFunctions(contractType string) []string {
	if contractType == "counter" {
		return []string{
			"Increment",
			"Decrement",
			"GetValue",
			"Reset",      // Available in V1
			"SetValue",
			"Add",
			"Subtract",
		}
	}
	return []string{}
}

func (ci *CounterInterpreterV1) GetFunctionSignature(contractType, functionName string) string {
	if contractType != "counter" {
		return ""
	}
	
	switch functionName {
	case "Increment":
		return "Increment() -> int"
	case "Decrement":
		return "Decrement() -> int"
	case "GetValue":
		return "GetValue() -> int"
	case "Reset":
		return "Reset() -> int"
	case "SetValue":
		return "SetValue(value int) -> int"
	case "Add":
		return "Add(amount int) -> int"
	case "Subtract":
		return "Subtract(amount int) -> int"
	default:
		return ""
	}
}

func (ci *CounterInterpreterV1) ValidateCall(contractType, functionName string, args ...any) error {
	if contractType != "counter" {
		return interfaces.ErrUnsupportedContract
	}
	
	supportedFunctions := ci.GetSupportedFunctions(contractType)
	for _, fn := range supportedFunctions {
		if fn == functionName {
			return nil
		}
	}
	
	return interfaces.ErrUnsupportedFunction
}

func (ci *CounterInterpreterV1) MasterCall(state storage.State, functionName string, args ...any) any {
	switch functionName {
	case "Increment":
		if len(args) != 0 {
			panic("Increment requires 0 arguments")
		}
		return counterlogicv1.Increment()(state)
		
	case "Decrement":
		if len(args) != 0 {
			panic("Decrement requires 0 arguments")
		}
		return counterlogicv1.Decrement()(state)
		
	case "GetValue":
		if len(args) != 0 {
			panic("GetValue requires 0 arguments")
		}
		return counterlogicv1.GetValue()(state)
		
	case "Reset":
		if len(args) != 0 {
			panic("Reset requires 0 arguments")
		}
		return counterlogicv1.Reset()(state)
		
	case "SetValue":
		if len(args) != 1 {
			panic("SetValue requires 1 argument: value")
		}
		value := convertToInt(args[0])
		return counterlogicv1.SetValue(value)(state)
		
	case "Add":
		if len(args) != 1 {
			panic("Add requires 1 argument: amount")
		}
		amount := convertToInt(args[0])
		return counterlogicv1.Add(amount)(state)
		
	case "Subtract":
		if len(args) != 1 {
			panic("Subtract requires 1 argument: amount")
		}
		amount := convertToInt(args[0])
		return counterlogicv1.Subtract(amount)(state)
		
	default:
		panic("unsupported counter function: " + functionName)
	}
}

// Helper functions
func convertToInt(v any) int {
	switch val := v.(type) {
	case int:
		return val
	case int64:
		return int(val)
	case string:
		// Simple string to int conversion for demo
		if val == "0" { return 0 }
		if val == "1" { return 1 }
		if val == "2" { return 2 }
		if val == "5" { return 5 }
		if val == "10" { return 10 }
		panic("unsupported string value: " + val)
	default:
		panic("unsupported argument type")
	}
}
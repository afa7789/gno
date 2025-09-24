package v2

import (
	"gno.land/p/arthur/proxy/interfaces"
	"gno.land/p/arthur/proxy/storage"
	counterlogicv2 "gno.land/p/arthur/counter/logic/v2"
)

// CounterInterpreterV2 - Uses counter V2 logic
type CounterInterpreterV2 struct{}

func NewCounterInterpreterV2() interfaces.IInterpreter {
	return &CounterInterpreterV2{}
}

func (ci *CounterInterpreterV2) GetVersion() string {
	return "counter-interpreter-v2.0.0"
}

func (ci *CounterInterpreterV2) GetSupportedFunctions(contractType string) []string {
	if contractType == "counter" {
		return []string{
			"Increment",     // kept from v1
			"Decrement",     // kept from v1  
			"GetValue",      // kept from v1
			// "Reset",      // REMOVED in v2
			"SetValue",      // kept from v1
			"Add",           // kept from v1
			"Subtract",      // kept from v1
			"Multiply",      // NEW in v2
			"Divide",        // NEW in v2
			"Power",         // NEW in v2
			"GetHistory",    // NEW in v2
		}
	}
	return []string{}
}

func (ci *CounterInterpreterV2) GetFunctionSignature(contractType, functionName string) string {
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
	case "SetValue":
		return "SetValue(value int) -> int"
	case "Add":
		return "Add(amount int) -> int"
	case "Subtract":
		return "Subtract(amount int) -> int"
	case "Multiply":
		return "Multiply(factor int) -> int"
	case "Divide":
		return "Divide(divisor int) -> int"
	case "Power":
		return "Power(exponent int) -> int"
	case "GetHistory":
		return "GetHistory() -> []string"
	default:
		return ""
	}
}

func (ci *CounterInterpreterV2) ValidateCall(contractType, functionName string, args ...any) error {
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

func (ci *CounterInterpreterV2) MasterCall(state storage.State, functionName string, args ...any) any {
	// Log the operation first (new feature in V2)
	logOperation(state, functionName, args...)
	
	switch functionName {
	case "Increment":
		if len(args) != 0 {
			panic("Increment requires 0 arguments")
		}
		return counterlogicv2.Increment()(state)
		
	case "Decrement":
		if len(args) != 0 {
			panic("Decrement requires 0 arguments")
		}
		return counterlogicv2.Decrement()(state)
		
	case "GetValue":
		if len(args) != 0 {
			panic("GetValue requires 0 arguments")
		}
		return counterlogicv2.GetValue()(state)
		
	case "SetValue":
		if len(args) != 1 {
			panic("SetValue requires 1 argument: value")
		}
		value := convertToInt(args[0])
		return counterlogicv2.SetValue(value)(state)
		
	case "Add":
		if len(args) != 1 {
			panic("Add requires 1 argument: amount")
		}
		amount := convertToInt(args[0])
		return counterlogicv2.Add(amount)(state)
		
	case "Subtract":
		if len(args) != 1 {
			panic("Subtract requires 1 argument: amount")
		}
		amount := convertToInt(args[0])
		return counterlogicv2.Subtract(amount)(state)
		
	// NEW FUNCTIONS IN V2
	case "Multiply":
		if len(args) != 1 {
			panic("Multiply requires 1 argument: factor")
		}
		factor := convertToInt(args[0])
		return counterlogicv2.Multiply(factor)(state)
		
	case "Divide":
		if len(args) != 1 {
			panic("Divide requires 1 argument: divisor")
		}
		divisor := convertToInt(args[0])
		return counterlogicv2.Divide(divisor)(state)
		
	case "Power":
		if len(args) != 1 {
			panic("Power requires 1 argument: exponent")
		}
		exponent := convertToInt(args[0])
		return counterlogicv2.Power(exponent)(state)
		
	case "GetHistory":
		if len(args) != 0 {
			panic("GetHistory requires 0 arguments")
		}
		return counterlogicv2.GetHistory()(state)
		
	// NOTE: Reset function is REMOVED in V2
	default:
		panic("unsupported counter function: " + functionName)
	}
}

// Operation logging (new feature in V2)
func logOperation(state storage.State, operation string, args ...any) {
	entry := operation
	if len(args) > 0 {
		entry += "(" + toString(args[0]) + ")"
	} else {
		entry += "()"
	}
	
	// Use the V2 logic to log the operation
	counterlogicv2.LogOperation(entry)(state)
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

func toString(v any) string {
	switch val := v.(type) {
	case int:
		return itoa(val)
	case int64:
		return itoa(int(val))
	case string:
		return val
	default:
		return "unknown"
	}
}

func itoa(i int) string {
	if i == 0 {
		return "0"
	}
	
	var digits []byte
	negative := i < 0
	if negative {
		i = -i
	}
	
	for i > 0 {
		digits = append([]byte{byte(i%10) + '0'}, digits...)
		i /= 10
	}
	
	result := string(digits)
	if negative {
		result = "-" + result
	}
	return result
}
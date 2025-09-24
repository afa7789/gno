package interpreter

import (
	"strconv"

	"gno.land/p/arthur/proxy/storage"
	"gno.land/p/arthur/proxy/interfaces"
	counterlogic "gno.land/p/arthur/counter/logic"
)

// CounterInterpreter implements the IInterpreter interface for counter contracts
type CounterInterpreter struct {
	version        string
	supportedTypes []string
}

// NewCounterInterpreter creates a new counter interpreter instance
func NewCounterInterpreter() interfaces.IInterpreter {
	return &CounterInterpreter{
		version:        "v1.0.0",
		supportedTypes: []string{"counter"},
	}
}

// MasterCall implements the IInterpreter interface
func (c *CounterInterpreter) MasterCall(state storage.State, functionName string, args ...any) any {
	// Get the contract type to determine which logic to use
	contractType := storage.GetContractType(state)
	
	// Route to appropriate contract logic based on type
	switch contractType {
	case "counter":
		return routeCounterCall(state, functionName, args...)
	case "token":
		// Future: could add token routing here
		panic("token contract type not yet implemented")
	default:
		panic("unsupported contract type: " + contractType)
	}
}

// routeCounterCall handles all counter contract function calls
// This is the generated dispatcher for counter functions
func routeCounterCall(state storage.State, functionName string, args ...any) any {
	// Validate the function call before routing
	validateCounterCall(functionName, args...)
	
	switch functionName {
	case "Initialize":
		if len(args) != 1 {
			panic("Initialize requires 1 argument: initialValue")
		}
		initialValue := convertToInt(args[0])
		return counterlogic.Initialize(initialValue)(state)
		
	case "Increment":
		if len(args) != 0 {
			panic("Increment requires 0 arguments")
		}
		return counterlogic.Increment()(state)
		
	case "Decrement":
		if len(args) != 0 {
			panic("Decrement requires 0 arguments")
		}
		return counterlogic.Decrement()(state)
		
	case "GetValue":
		if len(args) != 0 {
			panic("GetValue requires 0 arguments")
		}
		return counterlogic.GetValue()(state)
		
	case "Reset":
		if len(args) != 0 {
			panic("Reset requires 0 arguments")
		}
		return counterlogic.Reset()(state)
		
	case "SetValue":
		if len(args) != 1 {
			panic("SetValue requires 1 argument: value")
		}
		value := convertToInt(args[0])
		return counterlogic.SetValue(value)(state)
		
	case "Add":
		if len(args) != 1 {
			panic("Add requires 1 argument: amount")
		}
		amount := convertToInt(args[0])
		return counterlogic.Add(amount)(state)
		
	case "Subtract":
		if len(args) != 1 {
			panic("Subtract requires 1 argument: amount")
		}
		amount := convertToInt(args[0])
		return counterlogic.Subtract(amount)(state)
		
	default:
		panic("unsupported counter function: " + functionName)
	}
}

// Parameter conversion utilities - handles the interface{} -> concrete type conversion
func convertToInt(arg any) int {
	switch v := arg.(type) {
	case int:
		return v
	case int64:
		return int(v)
	case string:
		val, err := strconv.Atoi(v)
		if err != nil {
			panic("cannot convert string to int: " + v + " (error: " + err.Error() + ")")
		}
		return val
	default:
		panic("unsupported type for int conversion")
	}
}

func convertToString(arg any) string {
	switch v := arg.(type) {
	case string:
		return v
	case int:
		return strconv.Itoa(v)
	case int64:
		return strconv.Itoa(int(v))
	default:
		panic("unsupported type for string conversion")
	}
}

// GetSupportedFunctions implements the IInterpreter interface
func (c *CounterInterpreter) GetSupportedFunctions(contractType string) []string {
	switch contractType {
	case "counter":
		return []string{
			"Initialize",
			"Increment",
			"Decrement", 
			"GetValue",
			"Reset",
			"SetValue",
			"Add",
			"Subtract",
		}
	default:
		return []string{}
	}
}

// Function registry and validation (backwards compatibility)
func GetSupportedFunctions(contractType string) []string {
	return NewCounterInterpreter().GetSupportedFunctions(contractType)
}

// ValidateCall implements the IInterpreter interface
func (c *CounterInterpreter) ValidateCall(contractType, functionName string, args ...any) error {
	if contractType != "counter" {
		return interfaces.UnsupportedTypeError(contractType)
	}
	
	supportedFuncs := c.GetSupportedFunctions(contractType)
	
	// Check if function is supported
	found := false
	for _, fn := range supportedFuncs {
		if fn == functionName {
			found = true
			break
		}
	}
	
	if !found {
		return interfaces.InvalidFunctionError(functionName, contractType)
	}
	
	// Validate argument count
	expectedArgs := getExpectedArgCount(functionName)
	if len(args) != expectedArgs {
		return interfaces.InvalidArgsError(functionName, expectedArgs, len(args))
	}
	
	return nil
}

func validateCounterCall(functionName string, args ...any) {
	err := NewCounterInterpreter().(*CounterInterpreter).ValidateCall("counter", functionName, args...)
	if err != nil {
		panic(err.Error())
	}
}

// GetFunctionSignature implements the IInterpreter interface
func (c *CounterInterpreter) GetFunctionSignature(contractType, functionName string) string {
	if contractType != "counter" {
		return ""
	}
	
	switch functionName {
	case "Initialize":
		return "Initialize(initialValue int) -> any"
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

// Function signature documentation for tooling/UI generation (backwards compatibility)
func GetFunctionSignature(contractType, functionName string) string {
	return NewCounterInterpreter().GetFunctionSignature(contractType, functionName)
}

// GetVersion implements the IInterpreter interface
func (c *CounterInterpreter) GetVersion() string {
	return c.version
}

// GetSupportedContractTypes implements the IInterpreter interface
func (c *CounterInterpreter) GetSupportedContractTypes() []string {
	return c.supportedTypes
}

// Version information for this interpreter (backwards compatibility)
func GetInterpreterVersion() string {
	return NewCounterInterpreter().GetVersion()
}

func GetSupportedContractTypes() []string {
	return NewCounterInterpreter().GetSupportedContractTypes()
}

// Introspection functions for debugging/tooling
// getExpectedArgCount returns the expected number of arguments for a function
func getExpectedArgCount(functionName string) int {
	switch functionName {
	case "Initialize", "SetValue", "Add", "Subtract":
		return 1
	case "Increment", "Decrement", "GetValue", "Reset":
		return 0
	default:
		return -1 // Unknown function
	}
}

// MasterCall function for backwards compatibility
func MasterCall(state storage.State, functionName string, args ...any) any {
	interpreter := NewCounterInterpreter()
	return interpreter.MasterCall(state, functionName, args...)
}

func IntrospectContract(state storage.State) map[string]any {
	contractType := storage.GetContractType(state)
	
	return map[string]any{
		"contractType":       contractType,
		"supportedFunctions": GetSupportedFunctions(contractType),
		"interpreterVersion": GetInterpreterVersion(),
		"contractVersion":    storage.GetVersion(state),
	}
}
package v2

import (
	"strconv"

	"gno.land/p/arthur/proxy/storage"
	"gno.land/p/arthur/proxy/interfaces"
	counterlogic "gno.land/p/arthur/counter/logic"
)

// CounterInterpreterV2 implements enhanced counter functionality
// This demonstrates how to create a new interpreter with additional features
type CounterInterpreterV2 struct {
	version        string
	supportedTypes []string
}

// NewCounterInterpreterV2 creates a new V2 counter interpreter instance
func NewCounterInterpreterV2() interfaces.IInterpreter {
	return &CounterInterpreterV2{
		version:        "v2.0.0",
		supportedTypes: []string{"counter"},
	}
}

// MasterCall implements the IInterpreter interface with enhanced functionality
func (c *CounterInterpreterV2) MasterCall(state storage.State, functionName string, args ...any) any {
	contractType := storage.GetContractType(state)
	
	// Route to appropriate contract logic based on type
	switch contractType {
	case "counter":
		return c.routeCounterCallV2(state, functionName, args...)
	default:
		return interfaces.UnsupportedTypeError(contractType)
	}
}

// routeCounterCallV2 handles counter calls with V2 enhancements
func (c *CounterInterpreterV2) routeCounterCallV2(state storage.State, functionName string, args ...any) any {
	// Validate the function call
	c.ValidateCall("counter", functionName, args...)
	
	switch functionName {
	// V1 functions (backward compatibility)
	case "Initialize":
		initialValue := convertToInt(args[0])
		return counterlogic.Initialize(initialValue)(state)
	case "Increment":
		return counterlogic.Increment()(state)
	case "Decrement":
		return counterlogic.Decrement()(state)
	case "GetValue":
		return counterlogic.GetValue()(state)
	case "Reset":
		return counterlogic.Reset()(state)
	case "SetValue":
		value := convertToInt(args[0])
		return counterlogic.SetValue(value)(state)
	case "Add":
		amount := convertToInt(args[0])
		return counterlogic.Add(amount)(state)
	case "Subtract":
		amount := convertToInt(args[0])
		return counterlogic.Subtract(amount)(state)
		
	// V2 NEW FUNCTIONS - Enhanced capabilities
	case "Multiply":
		factor := convertToInt(args[0])
		return c.multiply(state, factor)
	case "Divide":
		divisor := convertToInt(args[0])
		return c.divide(state, divisor)
	case "Power":
		exponent := convertToInt(args[0])
		return c.power(state, exponent)
	case "GetHistory":
		return c.getHistory(state)
	case "GetStats":
		return c.getStats(state)
		
	default:
		panic("unsupported counter function: " + functionName)
	}
}

// V2 Enhanced Functions

func (c *CounterInterpreterV2) multiply(state storage.State, factor int) any {
	if factor == 0 {
		panic("cannot multiply by zero")
	}
	
	currentValue := getCurrentValue(state)
	newValue := currentValue * factor
	state.Set("counter_value", newValue)
	state.Set("last_modified", getHeight())
	
	// Track operation in history
	c.addToHistory(state, "multiply", strconv.Itoa(factor), strconv.Itoa(currentValue), strconv.Itoa(newValue))
	
	return newValue
}

func (c *CounterInterpreterV2) divide(state storage.State, divisor int) any {
	if divisor == 0 {
		panic("cannot divide by zero")
	}
	
	currentValue := getCurrentValue(state)
	newValue := currentValue / divisor
	state.Set("counter_value", newValue)
	state.Set("last_modified", getHeight())
	
	// Track operation in history
	c.addToHistory(state, "divide", strconv.Itoa(divisor), strconv.Itoa(currentValue), strconv.Itoa(newValue))
	
	return newValue
}

func (c *CounterInterpreterV2) power(state storage.State, exponent int) any {
	if exponent < 0 {
		panic("negative exponents not supported")
	}
	
	currentValue := getCurrentValue(state)
	newValue := intPower(currentValue, exponent)
	state.Set("counter_value", newValue)
	state.Set("last_modified", getHeight())
	
	// Track operation in history
	c.addToHistory(state, "power", strconv.Itoa(exponent), strconv.Itoa(currentValue), strconv.Itoa(newValue))
	
	return newValue
}

func (c *CounterInterpreterV2) getHistory(state storage.State) any {
	history, ok := state.Get("operation_history")
	if !ok {
		return []string{}
	}
	return history.([]string)
}

func (c *CounterInterpreterV2) getStats(state storage.State) any {
	totalOps, _ := state.Get("total_operations")
	if totalOps == nil {
		totalOps = 0
	}
	
	return map[string]any{
		"totalOperations": totalOps.(int),
		"currentValue":   getCurrentValue(state),
		"version":        "v2.0.0",
		"features":       []string{"history", "statistics", "advanced_math"},
	}
}

func (c *CounterInterpreterV2) addToHistory(state storage.State, operation, arg, oldValue, newValue string) {
	history, ok := state.Get("operation_history")
	var historyList []string
	if !ok {
		historyList = []string{}
	} else {
		historyList = history.([]string)
	}
	
	entry := operation + "(" + arg + "): " + oldValue + " -> " + newValue
	historyList = append(historyList, entry)
	
	// Keep only last 10 entries
	if len(historyList) > 10 {
		historyList = historyList[len(historyList)-10:]
	}
	
	state.Set("operation_history", historyList)
	
	// Update total operations count
	totalOps, ok := state.Get("total_operations")
	if !ok {
		state.Set("total_operations", 1)
	} else {
		state.Set("total_operations", totalOps.(int)+1)
	}
}

// Interface implementations

func (c *CounterInterpreterV2) GetSupportedFunctions(contractType string) []string {
	switch contractType {
	case "counter":
		return []string{
			// V1 functions
			"Initialize", "Increment", "Decrement", "GetValue", "Reset", "SetValue", "Add", "Subtract",
			// V2 NEW functions
			"Multiply", "Divide", "Power", "GetHistory", "GetStats",
		}
	default:
		return []string{}
	}
}

func (c *CounterInterpreterV2) ValidateCall(contractType, functionName string, args ...any) error {
	if contractType != "counter" {
		return interfaces.UnsupportedTypeError(contractType)
	}
	
	supportedFuncs := c.GetSupportedFunctions(contractType)
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
	
	expectedArgs := c.getExpectedArgCount(functionName)
	if len(args) != expectedArgs {
		return interfaces.InvalidArgsError(functionName, expectedArgs, len(args))
	}
	
	return nil
}

func (c *CounterInterpreterV2) GetFunctionSignature(contractType, functionName string) string {
	if contractType != "counter" {
		return ""
	}
	
	switch functionName {
	// V1 signatures
	case "Initialize": return "Initialize(initialValue int) -> any"
	case "Increment": return "Increment() -> int"
	case "Decrement": return "Decrement() -> int"
	case "GetValue": return "GetValue() -> int"
	case "Reset": return "Reset() -> int"
	case "SetValue": return "SetValue(value int) -> int"
	case "Add": return "Add(amount int) -> int"
	case "Subtract": return "Subtract(amount int) -> int"
	// V2 NEW signatures
	case "Multiply": return "Multiply(factor int) -> int"
	case "Divide": return "Divide(divisor int) -> int"
	case "Power": return "Power(exponent int) -> int"
	case "GetHistory": return "GetHistory() -> []string"
	case "GetStats": return "GetStats() -> map[string]any"
	default:
		return ""
	}
}

func (c *CounterInterpreterV2) GetVersion() string {
	return c.version
}

func (c *CounterInterpreterV2) GetSupportedContractTypes() []string {
	return c.supportedTypes
}

// Helper functions

func (c *CounterInterpreterV2) getExpectedArgCount(functionName string) int {
	switch functionName {
	case "Initialize", "SetValue", "Add", "Subtract", "Multiply", "Divide", "Power":
		return 1
	case "Increment", "Decrement", "GetValue", "Reset", "GetHistory", "GetStats":
		return 0
	default:
		return -1
	}
}

func convertToInt(arg any) int {
	switch v := arg.(type) {
	case int:
		return v
	case int64:
		return int(v)
	case string:
		val, err := strconv.Atoi(v)
		if err != nil {
			panic("cannot convert string to int: " + v)
		}
		return val
	default:
		panic("unsupported type for int conversion")
	}
}

func getCurrentValue(state storage.State) int {
	v, ok := state.Get("counter_value")
	if !ok {
		panic("counter not initialized")
	}
	return v.(int)
}

func getHeight() int64 {
	// This would normally use std.GetHeight() but we can't import std in a pure package
	// In practice, this would be handled by the calling realm layer
	return 0
}

func intPower(base, exp int) int {
	if exp == 0 {
		return 1
	}
	if exp == 1 {
		return base
	}
	
	result := 1
	for i := 0; i < exp; i++ {
		result *= base
	}
	return result
}
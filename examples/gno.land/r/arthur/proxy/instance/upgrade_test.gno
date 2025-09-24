package instance

import (
	"testing"
	"std"
	
	interpreterv1 "gno.land/p/arthur/proxy/interpreter/v1"
	interpreterv2 "gno.land/p/arthur/proxy/interpreter/v2"
)

func TestProxyUpgradeV1ToV2WithStatePreservation(t *testing.T) {
	// Reset proxy state for clean test
	initialized = false
	currentInterpreter = nil
	contractType = ""
	
	// PHASE 1: Initialize proxy with V1 interpreter and V1 logic
	t.Log("=== PHASE 1: Initialize with V1 ===")
	
	interpreterV1 := interpreterv1.NewCounterInterpreterV1()
	Initialize("", "counter", "v1.0.0", interpreterV1)
	
	if !initialized {
		t.Error("proxy should be initialized")
	}
	
	if currentInterpreter.GetVersion() != "counter-interpreter-v1.0.0" {
		t.Errorf("expected V1 interpreter, got %s", currentInterpreter.GetVersion())
	}
	
	// Test V1 functions
	t.Log("Testing V1 functions...")
	
	// Start with counter = 0, increment to 5
	result := Call("", "SetValue", 5)
	if result.(int) != 5 {
		t.Errorf("SetValue(5) should return 5, got %v", result)
	}
	
	result = Call("", "Add", 3)
	if result.(int) != 8 {
		t.Errorf("Add(3) should return 8, got %v", result)
	}
	
	result = Call("", "Subtract", 2)
	if result.(int) != 6 {
		t.Errorf("Subtract(2) should return 6, got %v", result)
	}
	
	// Test Reset function (available in V1)
	result = Call("", "Reset")
	if result.(int) != 0 {
		t.Errorf("Reset() should return 0, got %v", result)
	}
	
	// Set final value for upgrade test
	result = Call("", "SetValue", 42)
	if result.(int) != 42 {
		t.Errorf("SetValue(42) should return 42, got %v", result)
	}
	
	storedValue := Call("", "GetValue")
	if storedValue.(int) != 42 {
		t.Errorf("GetValue() should return 42 before upgrade, got %v", storedValue)
	}
	
	// PHASE 2: Upgrade to V2 interpreter and V2 logic
	t.Log("=== PHASE 2: Upgrade to V2 ===")
	
	interpreterV2 := interpreterv2.NewCounterInterpreterV2()
	UpgradeInterpreter("", interpreterV2)
	
	if currentInterpreter.GetVersion() != "counter-interpreter-v2.0.0" {
		t.Errorf("expected V2 interpreter after upgrade, got %s", currentInterpreter.GetVersion())
	}
	
	// CRITICAL TEST: State should be preserved across upgrade
	storedValue = Call("", "GetValue")
	if storedValue.(int) != 42 {
		t.Errorf("State not preserved! GetValue() should return 42 after upgrade, got %v", storedValue)
	}
	
	t.Log("✅ State preserved across upgrade!")
	
	// PHASE 3: Test V2-specific functionality
	t.Log("=== PHASE 3: Test V2 New Functions ===")
	
	// Test new Multiply function
	result = Call("", "Multiply", 2)
	if result.(int) != 84 {
		t.Errorf("Multiply(2) should return 84, got %v", result)
	}
	
	// Test new Divide function  
	result = Call("", "Divide", 4)
	if result.(int) != 21 {
		t.Errorf("Divide(4) should return 21, got %v", result)
	}
	
	// Test new Power function
	result = Call("", "SetValue", 3)
	result = Call("", "Power", 2)
	if result.(int) != 9 {
		t.Errorf("Power(2) should return 9, got %v", result)
	}
	
	// Test new GetHistory function
	history := Call("", "GetHistory")
	historySlice := history.([]string)
	if len(historySlice) == 0 {
		t.Error("GetHistory() should return operation history")
	}
	
	t.Logf("Operation history: %v", historySlice)
	
	// PHASE 4: Test removed functionality
	t.Log("=== PHASE 4: Test Removed Functions ===")
	
	// Reset should no longer be available in V2
	defer func() {
		if r := recover(); r != nil {
			expectedError := "unsupported counter function: Reset"
			if r.(string) == expectedError {
				t.Log("✅ Reset function correctly removed in V2")
			} else {
				t.Errorf("Expected Reset to panic with '%s', got '%v'", expectedError, r)
			}
		} else {
			t.Error("Reset function should not be available in V2")
		}
	}()
	
	Call("", "Reset") // This should panic
}

func TestBackwardCompatibleFunctions(t *testing.T) {
	// Test that all V1 functions (except Reset) work in V2
	t.Log("=== Testing Backward Compatibility ===")
	
	// Reset for clean test
	initialized = false 
	currentInterpreter = nil
	
	interpreterV2 := interpreterv2.NewCounterInterpreterV2()
	Initialize("", "counter", "v2.0.0", interpreterV2)
	
	// All these should work in both V1 and V2
	backwardCompatibleFunctions := []string{
		"Increment",
		"Decrement", 
		"SetValue",
		"Add",
		"Subtract",
		"GetValue",
	}
	
	for _, funcName := range backwardCompatibleFunctions {
		supportedFuncs := currentInterpreter.GetSupportedFunctions("counter")
		found := false
		for _, supported := range supportedFuncs {
			if supported == funcName {
				found = true
				break
			}
		}
		
		if !found {
			t.Errorf("Function %s should be backward compatible in V2", funcName)
		}
	}
	
	t.Log("✅ All backward compatible functions are available in V2")
}

func TestVersionInformation(t *testing.T) {
	t.Log("=== Testing Version Information ===")
	
	// Test V1
	v1 := interpreterv1.NewCounterInterpreterV1()
	if v1.GetVersion() != "counter-interpreter-v1.0.0" {
		t.Errorf("V1 version mismatch: %s", v1.GetVersion())
	}
	
	// Test V2  
	v2 := interpreterv2.NewCounterInterpreterV2()
	if v2.GetVersion() != "counter-interpreter-v2.0.0" {
		t.Errorf("V2 version mismatch: %s", v2.GetVersion())
	}
	
	// Test function counts
	v1Functions := v1.GetSupportedFunctions("counter")
	v2Functions := v2.GetSupportedFunctions("counter") 
	
	t.Logf("V1 supports %d functions: %v", len(v1Functions), v1Functions)
	t.Logf("V2 supports %d functions: %v", len(v2Functions), v2Functions)
	
	if len(v2Functions) <= len(v1Functions) {
		t.Error("V2 should support more functions than V1 (due to new additions)")
	}
}
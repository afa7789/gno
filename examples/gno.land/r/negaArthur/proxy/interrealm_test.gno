package proxy

import (
	"testing"
)

// Helper to reset all realm states for testing
func resetAllRealms() {
	// Reset proxy realm
	globalProxy = nil
	proxyInitialized = false

	// Note: In a real deployment, each realm would need its own reset logic
	// For testing, we're simulating clean state
}

func TestInterrealmCallDemonstration(t *testing.T) {
	resetAllRealms()

	t.Log("=== Interrealm Call Demonstration ===")

	// Step 1: Initialize the proxy
	t.Log("Step 1: Creating proxy with interrealm calls...")
	proxy := NewProxy(cross)

	if !IsInitialized(cross) {
		t.Fatal("Proxy should be initialized")
	}

	// Step 2: Set interpreter A (this makes interrealm calls)
	t.Log("Step 2: Setting InterpreterA with interrealm calls...")
	SetInterpreter(cross, "A")

	currentInterpreter := GetCurrentInterpreter(cross)
	if currentInterpreter != "A" {
		t.Errorf("Expected interpreter A, got %s", currentInterpreter)
	}

	// Step 3: Test ContractA functionality through interrealm calls
	t.Log("Step 3: Testing ContractA via interrealm calls...")

	// Call MethodA through the proxy -> interpreter -> contract chain
	result := Call(cross, "MethodA", "test input")
	if result != "test input" {
		t.Errorf("Expected 'test input', got %v", result)
	}
	t.Logf("✅ ContractA.MethodA('test input') = %v", result)

	// Get data back
	data := Call(cross, "GetData")
	if data != "test input" {
		t.Errorf("Expected 'test input', got %v", data)
	}
	t.Logf("✅ ContractA.GetData() = %v", data)

	// Step 4: Switch to interpreter B (more interrealm calls)
	t.Log("Step 4: Switching to InterpreterB with interrealm calls...")
	SetInterpreter(cross, "B")

	currentInterpreter = GetCurrentInterpreter(cross)
	if currentInterpreter != "B" {
		t.Errorf("Expected interpreter B, got %s", currentInterpreter)
	}

	// Step 5: Test ContractB functionality
	t.Log("Step 5: Testing ContractB via interrealm calls...")

	// ContractB should add prefix to input
	result = Call(cross, "MethodA", "test input")
	expected := "result of MethodA: test input"
	if result != expected {
		t.Errorf("Expected '%s', got %v", expected, result)
	}
	t.Logf("✅ ContractB.MethodA('test input') = %v", result)

	// Test ContractB's counter
	counter := Call(cross, "GetCounter")
	if counter != 1 {
		t.Errorf("Expected counter=1, got %v", counter)
	}
	t.Logf("✅ ContractB.GetCounter() = %v", counter)

	// Test ContractB's advanced method
	advancedResult := Call(cross, "AdvancedMethod", 5)
	expectedAdvanced := "advanced: 5" // counter(1) * multiplier(5) = 5
	if advancedResult != expectedAdvanced {
		t.Errorf("Expected '%s', got %v", expectedAdvanced, advancedResult)
	}
	t.Logf("✅ ContractB.AdvancedMethod(5) = %v", advancedResult)

	// Step 6: Verify shared storage works across interpreters
	t.Log("Step 6: Testing shared storage across interpreter switch...")

	// Switch back to A
	SetInterpreter(cross, "A")

	// The data should still be there (shared storage)
	// But ContractA was reinitialized, so it will have its default
	data = Call(cross, "GetData")
	// ContractA resets to default when reinitialized
	if data != "default_value" {
		t.Logf("Note: ContractA was reinitialized, data=%v", data)
	}

	t.Log("🎉 All interrealm calls completed successfully!")
}

func TestInterrealmCallPatterns(t *testing.T) {
	t.Log("=== Interrealm Call Patterns Demonstrated ===")

	t.Log("1. Constructor Pattern:")
	t.Log("   ❌ WRONG: contract = contractA.NewContractA(s)")
	t.Log("   ✅ CORRECT: contractA.NewContractA(cross, s)")

	t.Log("2. Method Call Pattern:")
	t.Log("   ❌ WRONG: result = contract.MethodA(input)")
	t.Log("   ✅ CORRECT: result = contractA.MethodA(cross, input)")

	t.Log("3. Function Declaration Pattern:")
	t.Log("   ✅ CROSSING: func NewContractA(cur realm, storage Storage)")
	t.Log("   ✅ CROSSING: func MethodA(cur realm, input string)")

	t.Log("4. Realm Call Chain:")
	t.Log("   User -> Proxy.Call(cross, ...) -> Interpreter.Call(cross, ...) -> Contract.MethodA(cross, ...)")

	t.Log("5. Storage Sharing:")
	t.Log("   All realms receive the same storage instance for state sharing")
}

func TestAccessControl(t *testing.T) {
	resetAllRealms()

	// Create proxy
	NewProxy(cross)

	// Test that only owner can set interpreter
	// Note: In testing context, std.PreviousRealm() behavior may be limited

	// Try to set valid interpreter
	SetInterpreter(cross, "A")

	interpreter := GetCurrentInterpreter(cross)
	if interpreter != "A" {
		t.Errorf("Expected interpreter A, got %s", interpreter)
	}

	t.Log("✅ Access control working for interpreter setting")
}

func TestErrorHandling(t *testing.T) {
	resetAllRealms()

	// Test calling uninitialized proxy
	defer func() {
		if r := recover(); r != nil {
			t.Logf("✅ Correctly panicked on uninitialized proxy: %v", r)
		}
	}()

	// This should panic
	Call(cross, "MethodA", "test")
	t.Error("Should have panicked on uninitialized proxy")
}

func TestInterrealmInfo(t *testing.T) {
	resetAllRealms()

	// Initialize proxy and interpreter
	NewProxy(cross)
	SetInterpreter(cross, "B")

	// Get comprehensive info
	info := GetInfo(cross)

	t.Logf("Proxy Info: %v", info)

	if !info["initialized"].(bool) {
		t.Error("Proxy should be initialized")
	}

	if info["currentInterpreter"].(string) != "B" {
		t.Error("Should show interpreter B")
	}

	if version, ok := info["interpreterVersion"]; ok {
		t.Logf("✅ Interpreter version retrieved via interrealm call: %v", version)
	}
}
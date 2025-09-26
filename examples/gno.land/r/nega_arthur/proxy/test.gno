package minimalProxy

import "testing"

func TestMinimalInterrealmChain(t *testing.T) {
	// Reset all states for test
	storage = nil
	currentInterpreter = ""
	initialized = false

	t.Log("=== MINIMAL INTERREALM CALL CHAIN WITH STORAGE TEST ===")

	// Step 1: Initialize proxy (proxy creates and holds storage)
	Init(cross)
	if !initialized {
		t.Fatal("Should be initialized")
	}
	t.Log("✅ Proxy initialized with storage")

	// Check initial storage
	info := GetStorageInfo(cross)
	if info["counter"] != 0 {
		t.Errorf("Initial counter should be 0, got %v", info["counter"])
	}

	// Step 2: Set implementation A
	SetImplementation(cross, "A")
	if GetImplementation(cross) != "A" {
		t.Fatal("Should be implementation A")
	}
	t.Log("✅ Set to Implementation A")

	// Step 3: Call through proxy directly to ContractA
	result := Call(cross, "MethodA", "test data")
	if result != "test data" {
		t.Errorf("Expected 'test data', got %v", result)
	}
	t.Log("✅ Direct call works: Proxy(storage) → ContractA")

	// Check storage was updated
	info = GetStorageInfo(cross)
	if info["last_input"] != "test data" {
		t.Errorf("Storage should have 'test data', got %v", info["last_input"])
	}
	if info["processed_by"] != "ContractA" {
		t.Errorf("Should be processed by ContractA, got %v", info["processed_by"])
	}

	// Step 4: Switch to implementation B
	SetImplementation(cross, "B")
	if GetImplementation(cross) != "B" {
		t.Fatal("Should be implementation B")
	}
	t.Log("✅ Switched to Implementation B")

	// Step 5: Call through proxy directly to ContractB
	result = Call(cross, "MethodA", "test data")
	expected := "enhanced: test data"
	if result != expected {
		t.Errorf("Expected '%s', got %v", expected, result)
	}
	t.Log("✅ Direct call works: Proxy(storage) → ContractB")

	// Check storage was updated by ContractB
	info = GetStorageInfo(cross)
	if info["last_input"] != "enhanced: test data" {
		t.Errorf("Storage should have enhanced data, got %v", info["last_input"])
	}
	if info["processed_by"] != "ContractB" {
		t.Errorf("Should be processed by ContractB, got %v", info["processed_by"])
	}
	if info["counter"] != 1 {
		t.Errorf("ContractB should increment counter to 1, got %v", info["counter"])
	}

	t.Log("🎉 COMPLETE PROXY PATTERN SUCCESS!")
	t.Log("   User → Proxy(holds storage) → Contract(processes data on storage)")
}

func TestInterrealmCallPattern(t *testing.T) {
	t.Log("=== INTERREALM CALL PATTERN DEMONSTRATION ===")

	t.Log("Call Flow:")
	t.Log("1. User calls: proxy.Call(cross, \"MethodA\", \"input\")")
	t.Log("2. Proxy delegates: interpreterA.Call(cross, \"MethodA\", \"input\")")
	t.Log("3. InterpreterA routes: contractA.MethodA(cross, \"input\")")
	t.Log("4. ContractA processes and returns result")
	t.Log("5. Result flows back through the chain")

	t.Log("✅ Each arrow (→) represents an interrealm call with 'cross' syntax")
}
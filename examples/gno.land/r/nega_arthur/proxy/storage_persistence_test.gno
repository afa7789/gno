package minimalProxy

import "testing"

func TestStoragePersistenceAcrossImplementationSwitch(t *testing.T) {
	// Reset for clean test
	storage = nil
	currentInterpreter = ""
	initialized = false

	t.Log("=== STORAGE PERSISTENCE TEST: ContractA → ContractB ===")

	// Step 1: Initialize proxy with storage
	Init(cross)
	t.Log("✅ Proxy initialized with storage")

	// Step 2: Set to ContractA implementation
	SetImplementation(cross, "A")
	if GetImplementation(cross) != "A" {
		t.Fatal("Should be implementation A")
	}
	t.Log("✅ Using ContractA implementation")

	// Step 3: Store data using ContractA
	result := Call(cross, "MethodA", "original data")
	if result != "original data" {
		t.Errorf("ContractA should return 'original data', got %v", result)
	}
	t.Log("✅ ContractA stored: 'original data'")

	// Step 4: Verify ContractA stored the data
	storedData := Call(cross, "GetData")
	if storedData != "original data" {
		t.Errorf("ContractA should have stored 'original data', got %v", storedData)
	}

	// Check storage info
	info := GetStorageInfo(cross)
	if info["last_input"] != "original data" {
		t.Errorf("Storage should contain 'original data', got %v", info["last_input"])
	}
	if info["processed_by"] != "ContractA" {
		t.Errorf("Should be processed by ContractA, got %v", info["processed_by"])
	}
	t.Log("✅ Verified: Storage contains ContractA data")

	// Step 5: SWITCH TO ContractB - CRITICAL TEST
	t.Log("🔄 SWITCHING TO ContractB - STORAGE MUST PERSIST!")
	SetImplementation(cross, "B")
	if GetImplementation(cross) != "B" {
		t.Fatal("Should be implementation B")
	}
	t.Log("✅ Switched to ContractB implementation")

	// Step 6: VERIFY STORAGE PERSISTED - The data from ContractA should still be there!
	persistedData := Call(cross, "GetData")
	if persistedData != "original data" {
		t.Errorf("❌ STORAGE NOT PERSISTED! Expected 'original data', got %v", persistedData)
	} else {
		t.Log("🎉 STORAGE PERSISTED! ContractB can see ContractA's data: 'original data'")
	}

	// Step 7: Use ContractB to process new data (enhanced processing)
	result = Call(cross, "MethodA", "new data")
	expected := "enhanced: new data"
	if result != expected {
		t.Errorf("ContractB should return '%s', got %v", expected, result)
	}
	t.Log("✅ ContractB processed new data with enhancement")

	// Step 8: Verify ContractB updated the storage
	newStoredData := Call(cross, "GetData")
	if newStoredData != "enhanced: new data" {
		t.Errorf("ContractB should have stored enhanced data, got %v", newStoredData)
	}

	// Check storage was updated by ContractB
	info = GetStorageInfo(cross)
	if info["last_input"] != "enhanced: new data" {
		t.Errorf("Storage should contain enhanced data, got %v", info["last_input"])
	}
	if info["processed_by"] != "ContractB" {
		t.Errorf("Should now be processed by ContractB, got %v", info["processed_by"])
	}
	if info["counter"] != 1 {
		t.Errorf("ContractB should increment counter to 1, got %v", info["counter"])
	}
	t.Log("✅ Verified: ContractB updated the same storage")

	// Step 9: SWITCH BACK TO ContractA - Test reverse persistence
	t.Log("🔄 SWITCHING BACK TO ContractA - Storage should still persist!")
	SetImplementation(cross, "A")

	// The storage should still contain ContractB's data
	finalData := Call(cross, "GetData")
	if finalData != "enhanced: new data" {
		t.Errorf("❌ REVERSE PERSISTENCE FAILED! Expected 'enhanced: new data', got %v", finalData)
	} else {
		t.Log("🎉 REVERSE PERSISTENCE WORKS! ContractA sees ContractB's data")
	}

	// Step 10: ContractA processes on the existing data
	result = Call(cross, "MethodA", "final data")
	if result != "final data" {
		t.Errorf("ContractA should return 'final data', got %v", result)
	}

	finalStoredData := Call(cross, "GetData")
	if finalStoredData != "final data" {
		t.Errorf("ContractA should have stored 'final data', got %v", finalStoredData)
	}

	// Final verification
	info = GetStorageInfo(cross)
	if info["last_input"] != "final data" {
		t.Errorf("Final storage should contain 'final data', got %v", info["last_input"])
	}
	if info["processed_by"] != "ContractA" {
		t.Errorf("Should be processed by ContractA again, got %v", info["processed_by"])
	}
	// Counter should still be 1 (ContractA doesn't increment it)
	if info["counter"] != 1 {
		t.Errorf("Counter should remain 1, got %v", info["counter"])
	}

	t.Log("🚀 COMPLETE SUCCESS!")
	t.Log("   ✅ Storage persisted: ContractA → ContractB")
	t.Log("   ✅ Storage persisted: ContractB → ContractA")
	t.Log("   ✅ Each implementation processes data differently")
	t.Log("   ✅ Same storage instance used throughout")
	t.Log("   🎉 PROXY PATTERN WORKS PERFECTLY!")
}

func TestDataProcessingDifferences(t *testing.T) {
	// Reset for clean test
	storage = nil
	currentInterpreter = ""
	initialized = false

	t.Log("=== DATA PROCESSING DIFFERENCES TEST ===")

	Init(cross)

	// Test ContractA processing
	SetImplementation(cross, "A")
	resultA := Call(cross, "MethodA", "test")
	if resultA != "test" {
		t.Errorf("ContractA should return input as-is, got %v", resultA)
	}
	t.Log("✅ ContractA: Simple pass-through processing")

	// Test ContractB processing
	SetImplementation(cross, "B")
	resultB := Call(cross, "MethodA", "test")
	expected := "enhanced: test"
	if resultB != expected {
		t.Errorf("ContractB should enhance input, expected '%s', got %v", expected, resultB)
	}
	t.Log("✅ ContractB: Enhanced processing with prefix")

	// Verify different behaviors but same storage
	info := GetStorageInfo(cross)
	t.Logf("Final storage state: %v", info)
	t.Log("🎉 Different implementations, same storage!")
}
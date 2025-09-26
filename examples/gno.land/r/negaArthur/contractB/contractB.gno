package contractB

import (
	"std"
	"gno.land/p/negaArthur/storage"
)

// ContractB represents a more advanced contract with enhanced logic
type ContractB struct {
	storage storage.Storage
	owner   std.Address
}

var (
	// Global instance - this realm manages a single contract instance
	globalContract *ContractB
	initialized    bool
)

// NewContractB is a crossing function that creates a new ContractB instance
// This MUST be called with cross syntax: NewContractB(cross, storage)
func NewContractB(cur realm, stor storage.Storage) *ContractB {
	if initialized {
		panic("ContractB already initialized in this realm")
	}

	// Get the caller information
	caller := std.PreviousRealm().Address()

	contract := &ContractB{
		storage: stor,
		owner:   caller,
	}

	// Initialize storage with default values
	contract.storage.Set("contractB_initialized", true)
	contract.storage.Set("contractB_owner", caller.String())
	contract.storage.Set("contractB_data", "enhanced_default")
	contract.storage.Set("contractB_counter", 0)

	// Store globally in this realm
	globalContract = contract
	initialized = true

	std.Emit("ContractBCreated",
		"owner", caller.String(),
		"realm", std.CurrentRealm().PkgPath())

	return contract
}

// GetContract returns the global contract instance (crossing function)
func GetContract(cur realm) *ContractB {
	if !initialized {
		panic("ContractB not initialized")
	}
	return globalContract
}

// MethodA is a crossing function with enhanced logic
func MethodA(cur realm, input string) string {
	if !initialized {
		panic("ContractB not initialized")
	}

	caller := std.PreviousRealm().Address()

	// Enhanced logic: add prefix and increment counter
	result := "result of MethodA: " + input

	// Update counter
	counter := 0
	if val := globalContract.storage.Get("contractB_counter"); val != nil {
		counter = val.(int)
	}
	counter++

	// Store the enhanced result
	globalContract.storage.Set("contractB_data", result)
	globalContract.storage.Set("contractB_counter", counter)
	globalContract.storage.Set("contractB_last_caller", caller.String())

	std.Emit("ContractBMethodACalled",
		"input", input,
		"result", result,
		"counter", itoa(counter),
		"caller", caller.String())

	return result
}

// GetData is a crossing function that retrieves stored data
func GetData(cur realm) string {
	if !initialized {
		panic("ContractB not initialized")
	}

	if val := globalContract.storage.Get("contractB_data"); val != nil {
		return val.(string)
	}
	return ""
}

// GetCounter returns the call counter (crossing function)
func GetCounter(cur realm) int {
	if !initialized {
		panic("ContractB not initialized")
	}

	if val := globalContract.storage.Get("contractB_counter"); val != nil {
		return val.(int)
	}
	return 0
}

// GetOwner returns the contract owner (crossing function)
func GetOwner(cur realm) string {
	if !initialized {
		panic("ContractB not initialized")
	}
	return globalContract.owner.String()
}

// AdvancedMethod is a new method only available in ContractB
func AdvancedMethod(cur realm, multiplier int) string {
	if !initialized {
		panic("ContractB not initialized")
	}

	counter := GetCounter(cur)
	result := "advanced: " + itoa(counter * multiplier)

	globalContract.storage.Set("contractB_advanced_result", result)

	std.Emit("ContractBAdvancedMethod",
		"multiplier", itoa(multiplier),
		"result", result)

	return result
}

// Helper function to convert int to string
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
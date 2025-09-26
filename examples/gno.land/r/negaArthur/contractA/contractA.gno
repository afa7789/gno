package contractA

import (
	"std"
	"gno.land/p/negaArthur/storage"
)

// ContractA represents a simple contract that stores data
type ContractA struct {
	storage storage.Storage
	owner   std.Address
}

var (
	// Global instance - this realm manages a single contract instance
	globalContract *ContractA
	initialized    bool
)

// NewContractA is a crossing function that creates a new ContractA instance
// This MUST be called with cross syntax: NewContractA(cross, storage)
func NewContractA(cur realm, stor storage.Storage) *ContractA {
	if initialized {
		panic("ContractA already initialized in this realm")
	}

	// Get the caller information
	caller := std.PreviousRealm().Address()

	contract := &ContractA{
		storage: stor,
		owner:   caller,
	}

	// Initialize storage with default values
	contract.storage.Set("contractA_initialized", true)
	contract.storage.Set("contractA_owner", caller.String())
	contract.storage.Set("contractA_data", "default_value")

	// Store globally in this realm
	globalContract = contract
	initialized = true

	std.Emit("ContractACreated",
		"owner", caller.String(),
		"realm", std.CurrentRealm().PkgPath())

	return contract
}

// GetContract returns the global contract instance (crossing function)
func GetContract(cur realm) *ContractA {
	if !initialized {
		panic("ContractA not initialized")
	}
	return globalContract
}

// MethodA is a crossing function that stores input data
func MethodA(cur realm, input string) string {
	if !initialized {
		panic("ContractA not initialized")
	}

	caller := std.PreviousRealm().Address()

	// Store the input in storage
	globalContract.storage.Set("contractA_data", input)
	globalContract.storage.Set("contractA_last_caller", caller.String())

	std.Emit("ContractAMethodACalled",
		"input", input,
		"caller", caller.String())

	return input  // ContractA just returns the input as-is
}

// GetData is a crossing function that retrieves stored data
func GetData(cur realm) string {
	if !initialized {
		panic("ContractA not initialized")
	}

	if val := globalContract.storage.Get("contractA_data"); val != nil {
		return val.(string)
	}
	return ""
}

// GetOwner returns the contract owner (crossing function)
func GetOwner(cur realm) string {
	if !initialized {
		panic("ContractA not initialized")
	}
	return globalContract.owner.String()
}

// Reset is a crossing function that resets the contract data
func Reset(cur realm) {
	if !initialized {
		panic("ContractA not initialized")
	}

	caller := std.PreviousRealm().Address()
	if caller != globalContract.owner {
		panic("only owner can reset")
	}

	globalContract.storage.Set("contractA_data", "default_value")

	std.Emit("ContractAReset", "caller", caller.String())
}
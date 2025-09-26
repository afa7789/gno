package proxy

import (
	"std"
	"gno.land/p/nega_arthur/storage"
	"gno.land/p/nega_arthur/interpreter"
)

// MINIMAL PROXY - Holds storage, routes to data processors
// Each user deploys their own proxy, interpreters, and contracts
var (
	// PERSISTENT STORAGE - held by proxy, never changes
	storage *storage.Storage

	// CURRENT INTERPRETER ADDRESS - can be swapped (true proxy pattern)
	currentInterpreter std.Address

	owner std.Address
)

func init() {
	// Set deployer as owner during realm deployment
	owner = std.DeployerAddress()
	// Initialize interpreter registry
	interpreterRegistry = make(map[std.Address]string)
}

// Set current implementation address (true proxy pattern)
// Also handles initialization on first call
func SetImplementation(cur realm, implementationAddress std.Address) {
	caller := std.PreviousRealm().Address()
	if caller != owner {
		panic("only owner can set implementation")
	}

	// Initialize storage on first call
	if storage == nil {
		storage = storage.NewStorage()
		storage.Init()
	}

	currentInterpreter = implementationAddress
}

// Delegate call to current interpreter - LEAN PROXY
func Call(cur realm, method string, args ...interface{}) interface{} {
	if storage == nil {
		panic("proxy not initialized - call SetImplementation first")
	}
	if currentInterpreter == "" {
		panic("no implementation set")
	}

	return callInterpreter(currentInterpreter, method, storage, args...)
}

// Helper function to perform cross-realm call to interpreter
func callInterpreter(interpreterAddr std.Address, method string, storage *storage.Storage, args ...interface{}) interface{} {

	// ACTUAL CROSS-REALM CALLS based on registered realm path
	// switch realmPath {
	// case "gno.land/r/nega_arthur/interpreter_a":
	// 	return interpreter_a.Call(cross, method, storage, args...)
	// case "gno.land/r/nega_arthur/interpreter_b":
	// 	return interpreter_b.Call(cross, method, storage, args...)
	// default:
	// 	panic("unknown interpreter realm: " + realmPath)
	// }

	// TODO reasearch a std.Call if it exists.
	// it seems that it does not exists.
}

// Get current implementation address
func GetImplementation(cur realm) std.Address {
	return currentInterpreter
}

// Get storage (for testing/debugging only)
func GetStorage(cur realm) *storage.Storage {
	if storage == nil {
		panic("proxy not initialized - call SetImplementation first")
	}
	return storage
}
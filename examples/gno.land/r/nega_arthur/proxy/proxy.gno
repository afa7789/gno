package proxy

import (
	"std"
	"gno.land/p/nega_arthur/storage"
	"gno.land/r/nega_arthur/contract_a"
	"gno.land/r/nega_arthur/contract_b"
)

// MINIMAL PROXY - Holds storage, routes to data processors
// Each user deploys their own proxy, interpreters, and contracts
var (
	// PERSISTENT STORAGE - held by proxy, never changes
	storage *storage.Storage

	// CURRENT INTERPRETER - can be swapped
	currentInterpreter string // "A" or "B"

	owner       std.Address
	initialized bool
)

// Initialize proxy - proxy holds the storage
func Init(cur realm) {
	if initialized {
		panic("already initialized")
	}

	owner = std.PreviousRealm().Address()

	// PROXY HOLDS THE STORAGE
	storage = storage.NewStorage()
	storage.Init()

	initialized = true

	// Initialize both contracts (interrealm calls)
	contract_a.Init(cross)
	contract_b.Init(cross)
}

// Set current implementation (like upgradeTo)
func SetImplementation(cur realm, implementation string) {
	if !initialized {
		panic("not initialized")
	}

	caller := std.PreviousRealm().Address()
	if caller != owner {
		panic("only owner can set implementation")
	}

	if implementation != "A" && implementation != "B" {
		panic("invalid implementation")
	}

	currentInterpreter = implementation
}

// Delegate call to current implementation with storage
func Call(cur realm, method string, args ...interface{}) interface{} {
	if !initialized {
		panic("not initialized")
	}
	if currentInterpreter == "" {
		panic("no implementation set")
	}

	// DELEGATE to current implementation with PROXY'S STORAGE (interrealm calls)
	switch currentInterpreter {
	case "A":
		if method == "MethodA" {
			return contract_a.MethodA(cross, storage, args[0].(string))
		} else if method == "GetData" {
			return contract_a.GetData(cross, storage)
		}
	case "B":
		if method == "MethodA" {
			return contract_b.MethodA(cross, storage, args[0].(string))
		} else if method == "GetData" {
			return contract_b.GetData(cross, storage)
		}
	}
	panic("unknown method: " + method)
}

// Get current implementation
func GetImplementation(cur realm) string {
	return currentInterpreter
}

// Get storage info for debugging
func GetStorageInfo(cur realm) map[string]interface{} {
	if !initialized {
		panic("not initialized")
	}
	return map[string]interface{}{
		"counter":      storage.GetCounter(),
		"last_input":   storage.Get("last_input"),
		"processed_by": storage.Get("processed_by"),
	}
}

func Render(path string) string {
	if !initialized {
		return "# Minimal Proxy\n\nNot initialized."
	}

	output := "# Minimal Proxy - Holds Storage, Routes to Data Processors\n\n"
	output += "**Owner:** " + owner.String() + "\n"
	output += "**Current Interpreter:** " + currentInterpreter + "\n"
	output += "**Storage Counter:** " + itoa(storage.GetCounter()) + "\n\n"
	output += "## Architecture\n\n"
	output += "Proxy (holds storage) → Interpreter" + currentInterpreter + " → Contract" + currentInterpreter + " (processes data)\n\n"
	output += "## Usage\n"
	output += "- `SetInterpreter(\"A\")` - Use ContractA processor\n"
	output += "- `SetInterpreter(\"B\")` - Use ContractB processor\n"
	output += "- `Call(\"MethodA\", \"input\")` - Process data with current processor\n"

	return output
}

func itoa(i int) string {
	if i == 0 { return "0" }
	var digits []byte
	for i > 0 {
		digits = append([]byte{byte(i%10) + '0'}, digits...)
		i /= 10
	}
	return string(digits)
}
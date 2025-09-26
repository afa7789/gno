package interpreterA

import (
	"std"
	"gno.land/p/negaArthur/storage"
	"gno.land/r/negaArthur/contractA"
)

// InterpreterA manages calls to ContractA realm
type InterpreterA struct {
	initialized bool
	storage     storage.Storage
}

var (
	globalInterpreter *InterpreterA
	interpreterInitialized bool
)

// NewInterpreterA creates a new interpreter instance (crossing function)
// This demonstrates the interrealm call pattern mentioned by the user
func NewInterpreterA(cur realm, stor storage.Storage) *InterpreterA {
	if interpreterInitialized {
		panic("InterpreterA already initialized")
	}

	caller := std.PreviousRealm().Address()

	interpreter := &InterpreterA{
		initialized: true,
		storage:     stor,
	}

	// THIS IS THE KEY INTERREALM CALL DEMONSTRATION:
	// We need to call ContractA's constructor with proper cross syntax
	// This is equivalent to: contract = contractA.NewContractA(s)
	// But with proper interrealm syntax:
	contractA.NewContractA(cross, stor)

	globalInterpreter = interpreter
	interpreterInitialized = true

	std.Emit("InterpreterACreated",
		"creator", caller.String(),
		"realm", std.CurrentRealm().PkgPath())

	return interpreter
}

// GetInterpreter returns the global interpreter (crossing function)
func GetInterpreter(cur realm) *InterpreterA {
	if !interpreterInitialized {
		panic("InterpreterA not initialized")
	}
	return globalInterpreter
}

// Call is a crossing function that routes calls to ContractA
func Call(cur realm, method string, args ...interface{}) interface{} {
	if !interpreterInitialized {
		panic("InterpreterA not initialized")
	}

	caller := std.PreviousRealm().Address()

	switch method {
	case "MethodA":
		if len(args) != 1 {
			panic("MethodA requires exactly 1 argument")
		}
		input, ok := args[0].(string)
		if !ok {
			panic("MethodA argument must be string")
		}

		// INTERREALM CALL: Call ContractA's MethodA with cross syntax
		result := contractA.MethodA(cross, input)

		std.Emit("InterpreterACall",
			"method", method,
			"caller", caller.String(),
			"result", result)

		return result

	case "GetData":
		// INTERREALM CALL: Get data from ContractA
		result := contractA.GetData(cross)

		std.Emit("InterpreterACall",
			"method", method,
			"caller", caller.String(),
			"result", result)

		return result

	case "Reset":
		// INTERREALM CALL: Reset ContractA
		contractA.Reset(cross)

		std.Emit("InterpreterACall",
			"method", method,
			"caller", caller.String(),
			"result", "reset_complete")

		return "reset_complete"

	case "GetOwner":
		// INTERREALM CALL: Get owner from ContractA
		result := contractA.GetOwner(cross)

		std.Emit("InterpreterACall",
			"method", method,
			"caller", caller.String(),
			"result", result)

		return result

	default:
		panic("unsupported method: " + method)
	}
}

// GetVersion returns the interpreter version (crossing function)
func GetVersion(cur realm) string {
	return "InterpreterA-v1.0.0"
}

// IsInitialized checks if interpreter is ready (crossing function)
func IsInitialized(cur realm) bool {
	return interpreterInitialized
}
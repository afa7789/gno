package interpreterB

import (
	"std"
	"gno.land/p/negaArthur/storage"
	"gno.land/r/negaArthur/contractB"
)

// InterpreterB manages calls to ContractB realm
type InterpreterB struct {
	initialized bool
	storage     storage.Storage
}

var (
	globalInterpreter *InterpreterB
	interpreterInitialized bool
)

// NewInterpreterB creates a new interpreter instance (crossing function)
func NewInterpreterB(cur realm, stor storage.Storage) *InterpreterB {
	if interpreterInitialized {
		panic("InterpreterB already initialized")
	}

	caller := std.PreviousRealm().Address()

	interpreter := &InterpreterB{
		initialized: true,
		storage:     stor,
	}

	// INTERREALM CALL: Initialize ContractB with proper cross syntax
	contractB.NewContractB(cross, stor)

	globalInterpreter = interpreter
	interpreterInitialized = true

	std.Emit("InterpreterBCreated",
		"creator", caller.String(),
		"realm", std.CurrentRealm().PkgPath())

	return interpreter
}

// GetInterpreter returns the global interpreter (crossing function)
func GetInterpreter(cur realm) *InterpreterB {
	if !interpreterInitialized {
		panic("InterpreterB not initialized")
	}
	return globalInterpreter
}

// Call is a crossing function that routes calls to ContractB
func Call(cur realm, method string, args ...interface{}) interface{} {
	if !interpreterInitialized {
		panic("InterpreterB not initialized")
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

		// INTERREALM CALL: Call ContractB's MethodA with cross syntax
		result := contractB.MethodA(cross, input)

		std.Emit("InterpreterBCall",
			"method", method,
			"caller", caller.String(),
			"result", result)

		return result

	case "GetData":
		// INTERREALM CALL: Get data from ContractB
		result := contractB.GetData(cross)

		std.Emit("InterpreterBCall",
			"method", method,
			"caller", caller.String(),
			"result", result)

		return result

	case "GetCounter":
		// INTERREALM CALL: Get counter from ContractB
		result := contractB.GetCounter(cross)
		resultStr := itoa(result)

		std.Emit("InterpreterBCall",
			"method", method,
			"caller", caller.String(),
			"result", resultStr)

		return result

	case "AdvancedMethod":
		if len(args) != 1 {
			panic("AdvancedMethod requires exactly 1 argument")
		}
		multiplier, ok := args[0].(int)
		if !ok {
			panic("AdvancedMethod argument must be int")
		}

		// INTERREALM CALL: Call ContractB's AdvancedMethod
		result := contractB.AdvancedMethod(cross, multiplier)

		std.Emit("InterpreterBCall",
			"method", method,
			"caller", caller.String(),
			"result", result)

		return result

	case "GetOwner":
		// INTERREALM CALL: Get owner from ContractB
		result := contractB.GetOwner(cross)

		std.Emit("InterpreterBCall",
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
	return "InterpreterB-v2.0.0"
}

// IsInitialized checks if interpreter is ready (crossing function)
func IsInitialized(cur realm) bool {
	return interpreterInitialized
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
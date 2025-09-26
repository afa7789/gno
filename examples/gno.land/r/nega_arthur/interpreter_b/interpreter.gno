package interpreter_b

import (
	"gno.land/p/nega_arthur/storage"
	"gno.land/r/nega_arthur/contract_b"
)

// InterpreterB routes calls to ContractB
func Call(cur realm, method string, storage *storage.Storage, args ...interface{}) interface{} {
	switch method {
	case "MethodA":
		return contract_b.MethodA(cross, storage, args[0].(string))
	case "GetData":
		return contract_b.GetData(cross, storage)
	default:
		panic("unknown method: " + method)
	}
}

func GetVersion(cur realm) string {
	return "InterpreterB-v1.0.0"
}
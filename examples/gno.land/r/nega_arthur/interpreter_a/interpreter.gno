package interpreter_a

import (
	"gno.land/p/nega_arthur/storage"
	"gno.land/r/nega_arthur/contract_a"
)


// InterpreterA routes calls to ContractA
func Call(cur realm, method string, storage *storage.Storage, args ...interface{}) interface{} {
	switch method {
	case "MethodA":
		return contract_a.MethodA(cross, storage, args[0].(string))
	case "GetData":
		return contract_a.GetData(cross, storage)
	default:
		panic("unknown method: " + method)
	}
}

func GetVersion(cur realm) string {
	return "InterpreterA-v1.0.0"
}
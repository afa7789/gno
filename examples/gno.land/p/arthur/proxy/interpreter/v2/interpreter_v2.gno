package v2

import (
	"gno.land/p/arthur/proxy/interfaces"
	"gno.land/p/arthur/proxy/storage"
	counterlogicv2 "gno.land/p/arthur/counter/logic/v2"
)

// CounterInterpreterV2 - Uses counter V2 logic (Add, Decrement)
type CounterInterpreterV2 struct{}

func NewCounterInterpreterV2() interfaces.IInterpreter {
	return &CounterInterpreterV2{}
}

func (ci *CounterInterpreterV2) GetVersion() string {
	return "v2.0.0"
}

func (ci *CounterInterpreterV2) MasterCall(state storage.State, functionName string, args ...any) any {
	switch functionName {
	case "Add":
		if len(args) != 1 {
			panic("Add requires 1 argument: amount")
		}
		amount := convertToInt(args[0])
		return counterlogicv2.Add(amount)(state)

	case "Decrement":
		if len(args) != 0 {
			panic("Decrement requires 0 arguments")
		}
		return counterlogicv2.Decrement()(state)

	default:
		panic("unsupported function: " + functionName)
	}
}

func convertToInt(v any) int {
	switch val := v.(type) {
	case int:
		return val
	case int64:
		return int(val)
	default:
		panic("unsupported argument type")
	}
}
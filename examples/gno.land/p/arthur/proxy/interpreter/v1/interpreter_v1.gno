package v1

import (
	"gno.land/p/arthur/proxy/interfaces"
	"gno.land/p/arthur/proxy/storage"
	counterlogicv1 "gno.land/p/arthur/counter/logic/v1"
)

// CounterInterpreterV1 - Uses counter V1 logic (Add, Reset)
type CounterInterpreterV1 struct{}

func NewCounterInterpreterV1() interfaces.IInterpreter {
	return &CounterInterpreterV1{}
}

func (ci *CounterInterpreterV1) GetVersion() string {
	return "v1.0.0"
}

func (ci *CounterInterpreterV1) MasterCall(state storage.State, functionName string, args ...any) any {
	switch functionName {
	case "Add":
		if len(args) != 1 {
			panic("Add requires 1 argument: amount")
		}
		amount := convertToInt(args[0])
		return counterlogicv1.Add(amount)(state)

	case "Reset":
		if len(args) != 0 {
			panic("Reset requires 0 arguments")
		}
		return counterlogicv1.Reset()(state)

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
package interfaces

import "gno.land/p/arthur/proxy/storage"

// IInterpreter defines the minimal interface for interpreters
type IInterpreter interface {
	// MasterCall routes function calls to the appropriate logic implementation
	MasterCall(state storage.State, functionName string, args ...any) any

	// GetVersion returns the interpreter version
	GetVersion() string
}
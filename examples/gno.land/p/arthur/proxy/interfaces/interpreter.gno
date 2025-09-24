package interfaces

import "gno.land/p/arthur/proxy/storage"

// IInterpreter defines the interface that all interpreters must implement
// This enables the proxy to work with any interpreter that follows this contract
type IInterpreter interface {
	// MasterCall routes function calls to the appropriate logic implementation
	// This is the core method that every interpreter must implement
	MasterCall(state storage.State, functionName string, args ...any) any
	
	// GetSupportedFunctions returns list of functions this interpreter supports
	// Used for validation and introspection
	GetSupportedFunctions(contractType string) []string
	
	// ValidateCall checks if a function call is valid before execution
	// Returns nil if valid, error if invalid
	ValidateCall(contractType, functionName string, args ...any) error
	
	// GetFunctionSignature returns the expected signature for a function
	// Used for documentation and tooling
	GetFunctionSignature(contractType, functionName string) string
	
	// GetVersion returns the interpreter version
	GetVersion() string
	
	// GetSupportedContractTypes returns contract types this interpreter supports
	GetSupportedContractTypes() []string
}

// IInterpreterRegistry defines the interface for managing interpreter instances
// This allows the proxy to discover and switch between different interpreters
type IInterpreterRegistry interface {
	// RegisterInterpreter registers a new interpreter with a unique ID
	RegisterInterpreter(id string, interpreter IInterpreter)
	
	// GetInterpreter retrieves an interpreter by ID
	GetInterpreter(id string) (IInterpreter, bool)
	
	// ListInterpreters returns all registered interpreter IDs
	ListInterpreters() []string
	
	// GetInterpreterInfo returns metadata about an interpreter
	GetInterpreterInfo(id string) InterpreterInfo
}

// InterpreterInfo contains metadata about an interpreter
type InterpreterInfo struct {
	ID                   string
	Version              string
	SupportedTypes       []string
	Description          string
	CreatedBy            string
	RegistrationHeight   int64
}

// IProxyCore defines the core proxy interface
// This standardizes how proxies interact with storage and interpreters
type IProxyCore interface {
	// Deploy creates a new contract instance
	Deploy(contractType, version string) string
	
	// MasterCall routes calls through the interpreter
	MasterCall(accountID, functionName string, args ...any) any
	
	// SetInterpreter changes the interpreter for a contract
	SetInterpreter(accountID, interpreterID string)
	
	// GetInterpreter gets the current interpreter for a contract
	GetInterpreter(accountID string) string
	
	// GetContractInfo returns contract metadata
	GetContractInfo(accountID string) map[string]any
}

// CallContext provides context information for interpreter calls
// This can be expanded to include more contextual data as needed
type CallContext struct {
	CallerAddress    string
	ContractID       string
	ContractType     string
	BlockHeight      int64
	InterpreterID    string
}

// Validation errors for interpreter operations
type ValidationError struct {
	Code    string
	Message string
}

func (e ValidationError) Error() string {
	return "[" + e.Code + "] " + e.Message
}

// Standard validation error codes
const (
	ErrInvalidFunction    = "INVALID_FUNCTION"
	ErrInvalidArgs        = "INVALID_ARGS"
	ErrUnsupportedType    = "UNSUPPORTED_TYPE"
	ErrInvalidState       = "INVALID_STATE"
	ErrPermissionDenied   = "PERMISSION_DENIED"
)

// Helper functions for creating validation errors
func NewValidationError(code, message string) ValidationError {
	return ValidationError{Code: code, Message: message}
}

func InvalidFunctionError(functionName, contractType string) ValidationError {
	return NewValidationError(ErrInvalidFunction, 
		"function '"+functionName+"' not supported for contract type '"+contractType+"'")
}

func InvalidArgsError(functionName string, expected, actual int) ValidationError {
	return NewValidationError(ErrInvalidArgs,
		"function '"+functionName+"' expects "+itoa(expected)+" args, got "+itoa(actual))
}

func UnsupportedTypeError(contractType string) ValidationError {
	return NewValidationError(ErrUnsupportedType,
		"contract type '"+contractType+"' not supported")
}

// Helper function for int to string conversion
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
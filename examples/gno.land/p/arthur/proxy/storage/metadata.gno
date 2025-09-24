package storage

// Metadata keys for proxy contract management
const (
	InterpreterKey  = "__proxy_interpreter__"
	OwnerKey        = "__proxy_owner__"
	ContractTypeKey = "__proxy_contract_type__"
	VersionKey      = "__proxy_version__"
	CreatedAtKey    = "__proxy_created_at__"
	UpdatedAtKey    = "__proxy_updated_at__"
)

// SetInterpreter stores the current interpreter package path
func SetInterpreter(state State, interpreterPath string) {
	state.Set(InterpreterKey, interpreterPath)
	// Note: Height tracking would be handled by realm layer
}

// GetInterpreter retrieves the current interpreter package path
func GetInterpreter(state State) string {
	v, ok := state.Get(InterpreterKey)
	if !ok {
		return ""
	}
	return v.(string)
}

// SetOwner sets the contract owner
func SetOwner(state State, owner string) {
	state.Set(OwnerKey, owner)
}

// GetOwner gets the contract owner
func GetOwner(state State) string {
	v, ok := state.Get(OwnerKey)
	if !ok {
		return ""
	}
	return v.(string)
}

// SetContractType sets the contract type (e.g., "counter", "token")
func SetContractType(state State, contractType string) {
	state.Set(ContractTypeKey, contractType)
}

// GetContractType gets the contract type
func GetContractType(state State) string {
	v, ok := state.Get(ContractTypeKey)
	if !ok {
		return ""
	}
	return v.(string)
}

// SetVersion sets the contract version
func SetVersion(state State, version string) {
	state.Set(VersionKey, version)
	// Note: Height tracking would be handled by realm layer
}

// GetVersion gets the contract version
func GetVersion(state State) string {
	v, ok := state.Get(VersionKey)
	if !ok {
		return ""
	}
	return v.(string)
}

// SetCreated marks the contract as created
func SetCreated(state State) {
	// Note: Height tracking would be handled by realm layer
	state.Set(CreatedAtKey, int64(1)) // Placeholder value
}

// IsCreated checks if the contract has been created
func IsCreated(state State) bool {
	_, ok := state.Get(CreatedAtKey)
	return ok
}

// GetCreatedAt returns creation block height
func GetCreatedAt(state State) int64 {
	v, ok := state.Get(CreatedAtKey)
	if !ok {
		return 0
	}
	return v.(int64)
}

// GetUpdatedAt returns last update block height  
func GetUpdatedAt(state State) int64 {
	v, ok := state.Get(UpdatedAtKey)
	if !ok {
		return 0
	}
	return v.(int64)
}
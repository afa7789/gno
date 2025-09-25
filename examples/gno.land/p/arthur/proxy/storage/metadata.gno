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

// Generic helper to get string values (DRY principle)
func getString(state State, key string) string {
	v, ok := state.Get(key)
	if !ok {
		return ""
	}
	return v.(string)
}

// Generic helper to get int64 values (DRY principle)
func getInt64(state State, key string) int64 {
	v, ok := state.Get(key)
	if !ok {
		return 0
	}
	return v.(int64)
}

// Interpreter management
func SetInterpreter(state State, interpreterPath string) { state.Set(InterpreterKey, interpreterPath) }
func GetInterpreter(state State) string                 { return getString(state, InterpreterKey) }

// Owner management
func SetOwner(state State, owner string) { state.Set(OwnerKey, owner) }
func GetOwner(state State) string        { return getString(state, OwnerKey) }

// Contract type management
func SetContractType(state State, contractType string) { state.Set(ContractTypeKey, contractType) }
func GetContractType(state State) string               { return getString(state, ContractTypeKey) }

// Version management
func SetVersion(state State, version string) { state.Set(VersionKey, version) }
func GetVersion(state State) string          { return getString(state, VersionKey) }

// Creation timestamp management
func SetCreated(state State)            { state.Set(CreatedAtKey, int64(1)) }
func GetCreatedAt(state State) int64    { return getInt64(state, CreatedAtKey) }
func GetUpdatedAt(state State) int64    { return getInt64(state, UpdatedAtKey) }
func IsCreated(state State) bool        { _, ok := state.Get(CreatedAtKey); return ok }
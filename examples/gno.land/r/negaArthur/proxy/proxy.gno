package proxy

import (
	"std"
	"gno.land/p/negaArthur/storage"
	"gno.land/r/negaArthur/interpreterA"
	"gno.land/r/negaArthur/interpreterB"
)

// Proxy manages interrealm calls to different interpreters
type Proxy struct {
	storage            storage.Storage
	currentInterpreter string  // "A" or "B"
	owner              std.Address
	initialized        bool
}

var (
	globalProxy *Proxy
	proxyInitialized bool
)

func init() {
	// Set deployer as owner during realm initialization
	// Note: std.OriginCaller() works during deployment
}

// NewProxy is a crossing function that creates the proxy
func NewProxy(cur realm) *Proxy {
	if proxyInitialized {
		panic("Proxy already initialized")
	}

	caller := std.PreviousRealm().Address()

	// Create shared storage
	sharedStorage := storage.NewStorage()

	proxy := &Proxy{
		storage:            sharedStorage,
		currentInterpreter: "", // Not set initially
		owner:              caller,
		initialized:        true,
	}

	globalProxy = proxy
	proxyInitialized = true

	std.Emit("ProxyCreated",
		"owner", caller.String(),
		"realm", std.CurrentRealm().PkgPath())

	return proxy
}

// SetInterpreter switches between interpreters with proper interrealm calls
func SetInterpreter(cur realm, interpreterType string) {
	if !proxyInitialized {
		panic("Proxy not initialized")
	}

	caller := std.PreviousRealm().Address()
	if caller != globalProxy.owner {
		panic("only owner can set interpreter")
	}

	switch interpreterType {
	case "A":
		// INTERREALM CALL: Initialize InterpreterA with cross syntax
		// This demonstrates the pattern: contract = contractA.NewContractA(s)
		interpreterA.NewInterpreterA(cross, globalProxy.storage)
		globalProxy.currentInterpreter = "A"

		std.Emit("InterpreterSet",
			"type", "A",
			"owner", caller.String())

	case "B":
		// INTERREALM CALL: Initialize InterpreterB with cross syntax
		interpreterB.NewInterpreterB(cross, globalProxy.storage)
		globalProxy.currentInterpreter = "B"

		std.Emit("InterpreterSet",
			"type", "B",
			"owner", caller.String())

	default:
		panic("invalid interpreter type: " + interpreterType)
	}
}

// Call routes function calls to the current interpreter (crossing function)
func Call(cur realm, method string, args ...interface{}) interface{} {
	if !proxyInitialized {
		panic("Proxy not initialized")
	}

	if globalProxy.currentInterpreter == "" {
		panic("No interpreter set")
	}

	caller := std.PreviousRealm().Address()

	switch globalProxy.currentInterpreter {
	case "A":
		// INTERREALM CALL: Call InterpreterA with cross syntax
		result := interpreterA.Call(cross, method, args...)

		std.Emit("ProxyCall",
			"interpreter", "A",
			"method", method,
			"caller", caller.String())

		return result

	case "B":
		// INTERREALM CALL: Call InterpreterB with cross syntax
		result := interpreterB.Call(cross, method, args...)

		std.Emit("ProxyCall",
			"interpreter", "B",
			"method", method,
			"caller", caller.String())

		return result

	default:
		panic("unknown interpreter: " + globalProxy.currentInterpreter)
	}
}

// GetCurrentInterpreter returns the current interpreter type (crossing function)
func GetCurrentInterpreter(cur realm) string {
	if !proxyInitialized {
		panic("Proxy not initialized")
	}
	return globalProxy.currentInterpreter
}

// GetOwner returns the proxy owner (crossing function)
func GetOwner(cur realm) string {
	if !proxyInitialized {
		panic("Proxy not initialized")
	}
	return globalProxy.owner.String()
}

// GetInfo returns proxy information (crossing function)
func GetInfo(cur realm) map[string]interface{} {
	if !proxyInitialized {
		return map[string]interface{}{
			"initialized": false,
		}
	}

	info := map[string]interface{}{
		"initialized":        true,
		"currentInterpreter": globalProxy.currentInterpreter,
		"owner":              globalProxy.owner.String(),
		"realm":              std.CurrentRealm().PkgPath(),
	}

	// Add interpreter version if available
	if globalProxy.currentInterpreter != "" {
		switch globalProxy.currentInterpreter {
		case "A":
			// INTERREALM CALL: Get version from InterpreterA
			version := interpreterA.GetVersion(cross)
			info["interpreterVersion"] = version
		case "B":
			// INTERREALM CALL: Get version from InterpreterB
			version := interpreterB.GetVersion(cross)
			info["interpreterVersion"] = version
		}
	}

	return info
}

// IsInitialized checks if proxy is ready (crossing function)
func IsInitialized(cur realm) bool {
	return proxyInitialized
}

// Render provides a web interface for the proxy
func Render(path string) string {
	if !proxyInitialized {
		return renderNotInitialized()
	}

	switch path {
	case "":
		return renderMain()
	case "info":
		return renderInfo()
	default:
		return renderMain()
	}
}

func renderNotInitialized() string {
	return "# NegaArthur Proxy\n\n" +
		"**Status:** Not initialized\n\n" +
		"Call `NewProxy()` to initialize the proxy with interrealm calls."
}

func renderMain() string {
	info := GetInfo(cross)

	output := "# NegaArthur Proxy - Interrealm Call Demonstration\n\n"
	output += "**Initialized:** " + boolToString(info["initialized"].(bool)) + "\n"
	output += "**Current Interpreter:** " + toString(info["currentInterpreter"]) + "\n"
	output += "**Owner:** " + toString(info["owner"]) + "\n"

	if version, ok := info["interpreterVersion"]; ok {
		output += "**Interpreter Version:** " + toString(version) + "\n"
	}

	output += "\n## Interrealm Call Features\n\n"
	output += "This proxy demonstrates proper interrealm calls using the `cross` syntax:\n\n"
	output += "- `SetInterpreter(cross, \"A\")` - Switch to ContractA via InterpreterA\n"
	output += "- `SetInterpreter(cross, \"B\")` - Switch to ContractB via InterpreterB\n"
	output += "- `Call(cross, \"MethodA\", \"input\")` - Call current contract's MethodA\n"
	output += "- `Call(cross, \"GetData\")` - Get data from current contract\n\n"

	output += "## Key Interrealm Patterns Shown\n\n"
	output += "1. **Constructor Calls:** `contractA.NewContractA(cross, storage)`\n"
	output += "2. **Method Calls:** `contractA.MethodA(cross, input)`\n"
	output += "3. **Realm Boundaries:** Each component is a separate realm\n"
	output += "4. **Shared Storage:** All realms use the same storage instance\n"

	return output
}

func renderInfo() string {
	info := GetInfo(cross)
	output := "# Proxy Detailed Information\n\n"

	for key, value := range info {
		output += "**" + key + ":** " + toString(value) + "\n"
	}

	return output
}

// Helper functions
func boolToString(b bool) string {
	if b {
		return "true"
	}
	return "false"
}

func toString(v interface{}) string {
	if v == nil {
		return "nil"
	}

	switch val := v.(type) {
	case string:
		return val
	case bool:
		return boolToString(val)
	case int:
		return itoa(val)
	default:
		return "unknown"
	}
}

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
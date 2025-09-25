package instance

import (
	"std"

	"gno.land/p/arthur/proxy/storage"
	"gno.land/p/arthur/proxy/interfaces"
)

// THIS IS A SINGLE PROXY CONTRACT
// Each deployment of this creates ONE proxy for ONE contract
// The proxy points to:
// 1. Its own storage (persistent state)
// 2. Current interpreter (upgradeable logic)

var (
	// Single contract storage - THIS proxy's state only (immutable)
	contractStorage = storage.NewProxyStorage()
	
	// Current interpreter - THIS is what gets upgraded (mutable)
	currentInterpreter interfaces.IInterpreter
	
	// This proxy's metadata
	contractType string
	owner        std.Address
	initialized  bool
)

func init() {
	// Set deployer as owner
	owner = std.OriginCaller()
}

// Initialize sets up this specific proxy contract
func Initialize(_ realm, cType, version string, interpreter interfaces.IInterpreter) {
	if initialized {
		panic("proxy already initialized")
	}
	
	caller := std.PreviousRealm().Address()
	if caller != owner {
		panic("only owner can initialize")
	}
	
	contractType = cType
	currentInterpreter = interpreter
	initialized = true
	
	// Initialize storage for this single contract
	contractStorage.Execute("main", func(state storage.State) any {
		storage.SetContractType(state, cType)
		storage.SetVersion(state, version)
		storage.SetInterpreter(state, interpreter.GetVersion())
		storage.SetOwner(state, owner.String())
		storage.SetCreated(state)
		
		// Set ACL for this proxy instance
		storage.SetACL(state, []string{
			"gno.land/r/proxy/instance", // This proxy
		})
		
		return nil
	})
	
	std.Emit("ProxyInitialized", 
		"contractType", cType,
		"version", version, 
		"interpreter", interpreter.GetVersion(),
		"owner", owner.String())
}

// Call executes a function on THIS proxy's current interpreter
func Call(_ realm, functionName string, args ...any) any {
	if !initialized {
		panic("proxy not initialized")
	}
	
	return contractStorage.Execute("main", func(state storage.State) any {
		// Use the current interpreter directly
		if currentInterpreter == nil {
			panic("no interpreter set")
		}
		
		// Execute on THIS proxy's state
		return currentInterpreter.MasterCall(state, functionName, args...)
	})
}

// UpgradeInterpreter changes THIS proxy's interpreter
func UpgradeInterpreter(_ realm, newInterpreter interfaces.IInterpreter) {
	if !initialized {
		panic("proxy not initialized")
	}
	
	caller := std.PreviousRealm().Address()
	if caller != owner {
		panic("only owner can upgrade")
	}
	
	if newInterpreter == nil {
		panic("interpreter cannot be nil")
	}
	
	contractStorage.Execute("main", func(state storage.State) any {
		oldInterpreterID := storage.GetInterpreter(state)
		newInterpreterID := newInterpreter.GetVersion()
		storage.SetInterpreter(state, newInterpreterID)
		
		std.Emit("InterpreterUpgraded",
			"oldInterpreter", oldInterpreterID,
			"newInterpreter", newInterpreterID,
			"owner", caller.String())
		
		return nil
	})
	
	// Update direct reference
	currentInterpreter = newInterpreter
}

// GetInfo returns THIS proxy's information
func GetInfo() map[string]any {
	if !initialized {
		return map[string]any{"initialized": false}
	}
	
	return contractStorage.Execute("main", func(state storage.State) any {
		return map[string]any{
			"initialized":   true,
			"contractType":  storage.GetContractType(state),
			"version":       storage.GetVersion(state),
			"interpreter":   storage.GetInterpreter(state),
			"owner":         storage.GetOwner(state),
			"createdAt":     storage.GetCreatedAt(state),
			"updatedAt":     storage.GetUpdatedAt(state),
		}
	}).(map[string]any)
}


// Render provides web interface for THIS specific proxy
func Render(path string) string {
	if !initialized {
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
	return "# Proxy Contract\n\n" +
		"**Status:** Not initialized\n" +
		"**Owner:** " + owner.String() + "\n\n" +
		"Owner must call Initialize() to set up this proxy."
}

func renderMain() string {
	info := GetInfo()
	
	output := "# Proxy Contract\n\n"
	output += "**Type:** " + info["contractType"].(string) + "\n"
	output += "**Version:** " + info["version"].(string) + "\n"
	output += "**Current Interpreter:** " + info["interpreter"].(string) + "\n"
	output += "**Owner:** " + info["owner"].(string) + "\n"
	output += "**Initialized:** " + boolToString(info["initialized"].(bool)) + "\n\n"
	
	output += "## This Proxy Contract\n\n"
	output += "This is a **single proxy contract** that:\n"
	output += "- Points to ONE set of contract state (preserved across upgrades)\n"
	output += "- Points to ONE current interpreter (upgradeable logic)\n"
	output += "- Has its own realm address\n"
	output += "- Can be upgraded independently\n\n"
	
	output += "## Available Operations\n\n"

	// Get current interpreter info
	if currentInterpreter != nil {
		interpreterID := currentInterpreter.GetVersion()
		output += "**Current Interpreter:** " + interpreterID + "\n\n"
	}

	output += "**Management:**\n"
	output += "- `UpgradeInterpreter(newInterpreter)` - Upgrade logic (owner only)\n"
	output += "- `GetInfo()` - View contract metadata\n"
	
	return output
}

func renderInfo() string {
	info := GetInfo()
	output := "# Proxy Contract Details\n\n"
	
	for key, value := range info {
		output += "**" + key + ":** " + toString(value) + "\n"
	}
	
	if currentInterpreter != nil {
		output += "\n**Current Interpreter:**\n"
		output += "- Version: " + currentInterpreter.GetVersion() + "\n"
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

func toString(v any) string {
	switch val := v.(type) {
	case string:
		return val
	case bool:
		return boolToString(val)
	case int64:
		return itoa(int(val))
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
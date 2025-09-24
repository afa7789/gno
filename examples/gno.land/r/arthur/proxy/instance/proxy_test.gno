package instance

import (
	"testing"
	"std"
	
	"gno.land/p/arthur/proxy/interfaces"
	"gno.land/p/arthur/proxy/interpreter"
)

func TestSingleProxyArchitecture(t *testing.T) {
	// Test initialization
	if initialized {
		t.Error("proxy should not be initialized initially")
	}
	
	// Create interpreter
	interpreter1 := interpreter.NewCounterInterpreter()
	
	// Initialize proxy
	Initialize("", "counter", "v1.0.0", interpreter1)
	
	if !initialized {
		t.Error("proxy should be initialized")
	}
	
	if currentInterpreter == nil {
		t.Error("currentInterpreter should be set")
	}
	
	// Test GetInfo
	info := GetInfo()
	if info["contractType"] != "counter" {
		t.Errorf("expected contractType 'counter', got %v", info["contractType"])
	}
	
	// Test Call functionality
	result := Call("", "Increment")
	if result == nil {
		t.Error("Call should return result")
	}
	
	// Test upgrade
	interpreter2 := interpreter.NewCounterInterpreter() // New instance
	UpgradeInterpreter("", interpreter2)
	
	if currentInterpreter != interpreter2 {
		t.Error("currentInterpreter should be updated after upgrade")
	}
}

func TestDirectInterpreterAccess(t *testing.T) {
	// This demonstrates the simplified architecture:
	// - Single proxy instance
	// - Direct interpreter reference (no registry)
	// - Immutable storage, mutable logic
	
	if currentInterpreter == nil && initialized {
		t.Error("initialized proxy should have currentInterpreter")
	}
}
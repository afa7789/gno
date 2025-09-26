// PKGPATH: gno.land/r/negaArthur/proxy
package main

import (
	"gno.land/r/negaArthur/proxy"
)

func main() {
	// Test basic proxy functionality
	println("=== NegaArthur Proxy Interrealm Call Demo ===")

	// Initialize the proxy
	println("1. Creating proxy...")
	proxy.NewProxy(cross)

	if !proxy.IsInitialized(cross) {
		panic("proxy should be initialized")
	}
	println("✅ Proxy created successfully")

	// Set interpreter A
	println("2. Setting InterpreterA (with interrealm calls)...")
	proxy.SetInterpreter(cross, "A")

	currentInterpreter := proxy.GetCurrentInterpreter(cross)
	if currentInterpreter != "A" {
		panic("expected interpreter A")
	}
	println("✅ InterpreterA set via interrealm calls")

	// Test ContractA functionality
	println("3. Testing ContractA via interrealm calls...")
	result := proxy.Call(cross, "MethodA", "hello world")
	println("ContractA.MethodA result:", result)

	data := proxy.Call(cross, "GetData")
	println("ContractA.GetData result:", data)

	// Switch to interpreter B
	println("4. Switching to InterpreterB...")
	proxy.SetInterpreter(cross, "B")

	currentInterpreter = proxy.GetCurrentInterpreter(cross)
	if currentInterpreter != "B" {
		panic("expected interpreter B")
	}
	println("✅ InterpreterB set via interrealm calls")

	// Test ContractB functionality
	println("5. Testing ContractB via interrealm calls...")
	result = proxy.Call(cross, "MethodA", "hello world")
	println("ContractB.MethodA result:", result)

	counter := proxy.Call(cross, "GetCounter")
	println("ContractB.GetCounter result:", counter)

	advancedResult := proxy.Call(cross, "AdvancedMethod", 3)
	println("ContractB.AdvancedMethod(3) result:", advancedResult)

	// Show proxy info
	println("6. Getting proxy info...")
	info := proxy.GetInfo(cross)
	println("Proxy initialized:", info["initialized"])
	println("Current interpreter:", info["currentInterpreter"])
	println("Interpreter version:", info["interpreterVersion"])

	println("🎉 All interrealm calls completed successfully!")
}

// Output:
// === NegaArthur Proxy Interrealm Call Demo ===
// 1. Creating proxy...
// ✅ Proxy created successfully
// 2. Setting InterpreterA (with interrealm calls)...
// ✅ InterpreterA set via interrealm calls
// 3. Testing ContractA via interrealm calls...
// ContractA.MethodA result: hello world
// ContractA.GetData result: hello world
// 4. Switching to InterpreterB...
// ✅ InterpreterB set via interrealm calls
// 5. Testing ContractB via interrealm calls...
// ContractB.MethodA result: result of MethodA: hello world
// ContractB.GetCounter result: 1
// ContractB.AdvancedMethod(3) result: advanced: 3
// 6. Getting proxy info...
// Proxy initialized: true
// Current interpreter: B
// Interpreter version: InterpreterB-v2.0.0
// 🎉 All interrealm calls completed successfully!
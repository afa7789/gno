# Interrealm Call Patterns - Complete Guide

This guide demonstrates the **correct implementation of interrealm calls** in Gno, specifically addressing the issue where `contract = contractA.NewContractA(s)` needs proper interrealm syntax.

## 🔧 The Problem You Identified

**❌ Incorrect Pattern:**
```go
// This will fail with interrealm call error
contract = contractA.NewContractA(s)
```

**✅ Correct Pattern:**
```go
// Proper interrealm call syntax
contractA.NewContractA(cross, s)
```

## 📁 Complete File Structure

```
examples/gno.land/
├── p/negaArthur/storage/           # Pure package - no realm crossing needed
│   └── storage.gno                 # Shared storage interface
└── r/negaArthur/                   # Realm packages - all require crossing
    ├── contractA/
    │   └── contractA.gno           # Contract A realm with crossing functions
    ├── contractB/
    │   └── contractB.gno           # Contract B realm with crossing functions
    ├── interpreterA/
    │   └── interpreterA.gno        # Interpreter A realm (calls ContractA)
    ├── interpreterB/
    │   └── interpreterB.gno        # Interpreter B realm (calls ContractB)
    └── proxy/
        ├── proxy.gno               # Main proxy realm (calls Interpreters)
        ├── interrealm_test.gno     # Tests showing cross patterns
        ├── proxy_filetest.gno      # File test demonstration
        └── README.md               # Detailed documentation
```

## 🎯 Key Interrealm Patterns Implemented

### 1. Function Declaration Pattern

**All crossing functions MUST have `cur realm` as first parameter:**

```go
// ✅ Correct: Crossing function declaration
func NewContractA(cur realm, stor storage.Storage) *ContractA {
    caller := std.PreviousRealm().Address()
    // Implementation...
}

func MethodA(cur realm, input string) string {
    caller := std.PreviousRealm().Address()
    // Implementation...
}
```

### 2. Interrealm Call Pattern

**All calls to crossing functions MUST use `cross` syntax:**

```go
// ✅ Correct: Calling crossing functions
func NewInterpreterA(cur realm, stor storage.Storage) *InterpreterA {
    // Call ContractA's constructor with cross
    contractA.NewContractA(cross, stor)

    // Call ContractA's method with cross
    result := contractA.MethodA(cross, "test")

    return interpreter
}
```

### 3. Multi-Realm Call Chain

**Example showing complete call chain across multiple realms:**

```
User Request
    ↓
proxy.Call(cross, "MethodA", "input")              # User → Proxy
    ↓
interpreterA.Call(cross, "MethodA", "input")       # Proxy → InterpreterA
    ↓
contractA.MethodA(cross, "input")                  # InterpreterA → ContractA
    ↓
return "input"                                     # Result back through chain
```

### 4. Constructor Call Pattern

**Demonstrates the exact pattern you mentioned:**

```go
// In interpreterA.gno - Line 37-40
func NewInterpreterA(cur realm, stor storage.Storage) *InterpreterA {
    // THIS IS THE CORRECTED VERSION OF: contract = contractA.NewContractA(s)
    contractA.NewContractA(cross, stor)  // ✅ Proper interrealm syntax
    // ...
}
```

## 🔄 Upgrade Pattern with Interrealm Calls

**The proxy demonstrates upgradeable logic with proper realm crossing:**

```go
// In proxy.gno
func SetInterpreter(cur realm, interpreterType string) {
    switch interpreterType {
    case "A":
        // Switch to ContractA logic via InterpreterA
        interpreterA.NewInterpreterA(cross, globalProxy.storage)
        globalProxy.currentInterpreter = "A"

    case "B":
        // Switch to ContractB logic via InterpreterB
        interpreterB.NewInterpreterB(cross, globalProxy.storage)
        globalProxy.currentInterpreter = "B"
    }
}
```

## 🧪 Testing Interrealm Calls

**The test demonstrates proper usage:**

```go
// In interrealm_test.gno
func TestInterrealmCallDemonstration(t *testing.T) {
    // All calls use cross syntax
    proxy := NewProxy(cross)
    SetInterpreter(cross, "A")
    result := Call(cross, "MethodA", "test input")

    // Switch interpreters with interrealm calls
    SetInterpreter(cross, "B")
    result = Call(cross, "MethodA", "test input")
}
```

## ⚠️ Common Mistakes and Solutions

### Mistake 1: Missing `cur realm` Parameter
```go
// ❌ Wrong
func NewContractA(stor storage.Storage) *ContractA

// ✅ Correct
func NewContractA(cur realm, stor storage.Storage) *ContractA
```

### Mistake 2: Missing `cross` in Call
```go
// ❌ Wrong
contractA.NewContractA(stor)

// ✅ Correct
contractA.NewContractA(cross, stor)
```

### Mistake 3: Calling Non-crossing Functions with `cross`
```go
// ❌ Wrong (if function doesn't have cur realm parameter)
helper.UtilityFunction(cross, data)

// ✅ Correct (pure package functions don't need cross)
helper.UtilityFunction(data)
```

## 🎯 Benefits of This Architecture

1. **True Modularity**: Each component is a separate realm
2. **Independent Deployment**: Each realm can be deployed/upgraded separately
3. **Access Control**: Each realm manages its own permissions
4. **State Isolation**: Each realm has its own global state
5. **Interoperability**: Realms can be reused by multiple other systems

## 🚀 Deployment Order

1. Deploy storage package: `/p/negaArthur/storage`
2. Deploy contract realms: `/r/negaArthur/contractA`, `/r/negaArthur/contractB`
3. Deploy interpreter realms: `/r/negaArthur/interpreterA`, `/r/negaArthur/interpreterB`
4. Deploy proxy realm: `/r/negaArthur/proxy`

## 🔍 Key Files to Study

1. **`interpreterA.gno`** - Shows the exact pattern you asked about (line 37-40)
2. **`proxy.gno`** - Demonstrates multi-level interrealm calls
3. **`interrealm_test.gno`** - Complete test suite showing all patterns
4. **`contractA.gno`** and **`contractB.gno`** - Show proper crossing function declarations

This implementation provides a complete, working example of the interrealm call patterns needed for Gno realm-based proxy systems.
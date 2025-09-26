# NegaArthur Proxy - Interrealm Call Demonstration

This implementation demonstrates the **correct way to handle interrealm calls** in Gno, specifically addressing the pattern mentioned where `contract = contractA.NewContractA(s)` needs proper interrealm syntax.

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Proxy Realm   │    │ Interpreter     │    │  Contract       │
│ /r/.../proxy    │◄──►│ Realm           │◄──►│  Realm          │
│                 │    │ /r/.../interp*  │    │ /r/.../contract*│
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                        │                        │
         └────────────────────────┼────────────────────────┘
                                  │
                        ┌─────────▼─────────┐
                        │ Shared Storage    │
                        │ /p/.../storage    │
                        └───────────────────┘
```

## Key Interrealm Patterns Demonstrated

### 1. Constructor Calls with Cross Syntax

**❌ Wrong (would cause compilation/runtime error):**
```go
contract = contractA.NewContractA(s)
```

**✅ Correct (proper interrealm syntax):**
```go
contractA.NewContractA(cross, s)
```

### 2. Function Declarations with Realm Parameter

All crossing functions must be declared with `cur realm` as the first parameter:

```go
// Crossing function - can be called from other realms
func NewContractA(cur realm, stor storage.Storage) *ContractA {
    // Implementation
}

func MethodA(cur realm, input string) string {
    // Implementation
}
```

### 3. Interrealm Call Chain

The complete call flow demonstrates multiple realm crossings:

```
User Call
  ↓ (MsgCall)
Proxy.Call(cross, "MethodA", "input")
  ↓ (interrealm call)
InterpreterA.Call(cross, "MethodA", "input")
  ↓ (interrealm call)
ContractA.MethodA(cross, "input")
  ↓ (returns)
Result back to user
```

## File Structure

```
examples/gno.land/
├── p/negaArthur/storage/        # Pure package - shared storage
│   └── storage.gno
└── r/negaArthur/                # Realm packages
    ├── contractA/               # Contract A realm
    │   └── contractA.gno
    ├── contractB/               # Contract B realm
    │   └── contractB.gno
    ├── interpreterA/            # Interpreter A realm
    │   └── interpreterA.gno
    ├── interpreterB/            # Interpreter B realm
    │   └── interpreterB.gno
    └── proxy/                   # Main proxy realm
        ├── proxy.gno
        ├── interrealm_test.gno
        └── README.md
```

## Interrealm Call Examples

### Basic Contract Creation
```go
// In InterpreterA realm
func NewInterpreterA(cur realm, stor storage.Storage) *InterpreterA {
    // INTERREALM CALL: Create ContractA instance
    contractA.NewContractA(cross, stor)
    // ...
}
```

### Method Invocation
```go
// In Proxy realm
func Call(cur realm, method string, args ...interface{}) interface{} {
    switch globalProxy.currentInterpreter {
    case "A":
        // INTERREALM CALL: Call InterpreterA
        return interpreterA.Call(cross, method, args...)
    case "B":
        // INTERREALM CALL: Call InterpreterB
        return interpreterB.Call(cross, method, args...)
    }
}
```

### Data Retrieval
```go
// In InterpreterA realm
func Call(cur realm, method string, args ...interface{}) interface{} {
    switch method {
    case "GetData":
        // INTERREALM CALL: Get data from ContractA
        return contractA.GetData(cross)
    }
}
```

## Testing the Implementation

Run the tests to see interrealm calls in action:

```bash
gno test ./r/negaArthur/proxy/
```

The test demonstrates:
1. Proxy initialization with interrealm calls
2. Interpreter switching via interrealm calls
3. Contract method invocation across realm boundaries
4. Shared storage persistence across realm switches
5. Error handling for improper call patterns

## Key Differences from Pure Package Approach

### Pure Package Pattern (from /p/arthur/*)
```go
// No realm crossing needed - pure packages
interpreter := v1.NewCounterInterpreterV1()
result := interpreter.MasterCall(state, functionName, args...)
```

### Realm Pattern (this implementation)
```go
// Requires proper cross syntax for realm functions
interpreterA.NewInterpreterA(cross, storage)
result := interpreterA.Call(cross, method, args...)
```

## Benefits of Realm-Based Architecture

1. **True Modularity**: Each component is a separate realm with its own address
2. **Independent Upgradability**: Each realm can be upgraded separately
3. **Access Control**: Each realm can implement its own permission system
4. **State Isolation**: Each realm maintains its own global state
5. **Interoperability**: Realms can be used by multiple other realms

## Deployment Notes

To deploy this system:

1. Deploy storage package: `gno.land/p/negaArthur/storage`
2. Deploy contract realms: `gno.land/r/negaArthur/contractA`, `gno.land/r/negaArthur/contractB`
3. Deploy interpreter realms: `gno.land/r/negaArthur/interpreterA`, `gno.land/r/negaArthur/interpreterB`
4. Deploy proxy realm: `gno.land/r/negaArthur/proxy`

Each realm gets its own address and can be called independently while maintaining the proxy pattern for upgradability.
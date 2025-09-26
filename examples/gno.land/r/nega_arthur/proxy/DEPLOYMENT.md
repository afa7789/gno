# Minimal Proxy System - Deployment Guide

## 🎯 What Each User Deploys

Each user deploys **1 package + 4 realms** for a complete proxy system:

```
User Alice deploys:
├── gno.land/p/alice/storage        (storage package - shared)
├── gno.land/r/alice/contractA      (her ContractA processor)
├── gno.land/r/alice/contractB      (her ContractB processor)
├── gno.land/r/alice/interpreterA   (her InterpreterA instance)
├── gno.land/r/alice/interpreterB   (her InterpreterB instance)
└── gno.land/r/alice/proxy          (her Proxy - holds storage)

User Bob deploys:
├── gno.land/p/bob/storage          (storage package - shared)
├── gno.land/r/bob/contractA        (his ContractA processor)
├── gno.land/r/bob/contractB        (his ContractB processor)
├── gno.land/r/bob/interpreterA     (his InterpreterA instance)
├── gno.land/r/bob/interpreterB     (his InterpreterB instance)
└── gno.land/r/bob/proxy            (his Proxy - holds storage)
```

## 📋 Deployment Steps

### Step 1: Deploy Storage Package
```bash
# Deploy storage package (pure package)
gnokey maketx addpkg alice p/alice/storage minimalStorage/storage.gno
```

### Step 2: Deploy Data Processors
```bash
# Deploy ContractA (data processor)
gnokey maketx addpkg alice r/alice/contractA minimalContractA/contract.gno

# Deploy ContractB (enhanced data processor)
gnokey maketx addpkg alice r/alice/contractB minimalContractB/contract.gno
```

### Step 3: Deploy Interpreters
```bash
# Deploy InterpreterA
gnokey maketx addpkg alice r/alice/interpreterA minimalInterpreterA/interpreter.gno

# Deploy InterpreterB
gnokey maketx addpkg alice r/alice/interpreterB minimalInterpreterB/interpreter.gno
```

### Step 4: Deploy Proxy (Storage Holder)
```bash
# Deploy Proxy (holds storage, routes to processors)
gnokey maketx addpkg alice r/alice/proxy minimalProxy/proxy.gno
```

### Step 5: Initialize System
```bash
# Initialize proxy (creates storage)
gnokey maketx call alice r/alice/proxy Init

# Set initial interpreter
gnokey maketx call alice r/alice/proxy SetInterpreter "A"
```

### Step 6: Use Your Proxy
```bash
# Process data through ContractA
gnokey maketx call alice r/alice/proxy Call "MethodA" "hello world"

# Switch to enhanced processor
gnokey maketx call alice r/alice/proxy SetInterpreter "B"
gnokey maketx call alice r/alice/proxy Call "MethodA" "hello world"

# Check storage
gnokey maketx call alice r/alice/proxy GetStorageInfo
```

## 🔗 Interrealm Call Chain

```
User Transaction
    ↓
alice/proxy.Call(cross, storage, "MethodA", "input")
    ↓ (interrealm call with proxy's storage)
alice/interpreterA.Call(cross, storage, "MethodA", "input")
    ↓ (interrealm call with same storage)
alice/contractA.MethodA(cross, storage, "input")
    ↓ (processes data on proxy's storage)
Returns: "input" (and updates storage)
```

## 🎯 Architecture Benefits

✅ **Storage Separation**: Storage package (pure), proxy holds instances
✅ **Data Processors**: ContractA/B process data, don't hold it
✅ **Complete Independence**: Each user owns their entire stack
✅ **No Shared State**: Alice's storage ≠ Bob's storage
✅ **Proper Proxy Pattern**: Proxy holds storage, delegates to processors
✅ **Minimal Components**: Each component ~25-30 lines

## 📊 File Sizes

- `minimalStorage/storage.gno`: ~25 lines (package)
- `minimalContractA/contract.gno`: ~30 lines (data processor)
- `minimalContractB/contract.gno`: ~35 lines (enhanced data processor)
- `minimalInterpreterA/interpreter.gno`: ~30 lines (router)
- `minimalInterpreterB/interpreter.gno`: ~30 lines (router)
- `minimalProxy/proxy.gno`: ~80 lines (storage holder + router)

**Total**: ~230 lines for complete proxy system with proper storage separation!
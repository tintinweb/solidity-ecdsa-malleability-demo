# Solidity `ecrecover()` / ECDSA Playground


The Ethereum Virtual Machine (EVM) provides a pre-compile (it is actually a built-in contract) ECDSA signature verification functionality via a call to [ecrecover()](https://docs.soliditylang.org/en/v0.4.24/units-and-global-variables.html#mathematical-and-cryptographic-functions) and there are a couple of interesting quirks when using ECDSA signatures with Solidity Smart Contracts


⇒ 🕹️ [Demo Playground on Görli]()<br>
⇒ 📄 [EcdsaSignaturePlayground.sol](./EcdsaSignaturePlayground.sol)


## 1) Multiple parameters verify the same signature/message

Given a valid signature  `sig = (hash(m), v, r, s)` one can construct a signature  `sig' = (hash(m), v', r, -s mod N)` that validly verifies the same message `hash(m)`.


The second `sig'` can be created as follows:

* `v'` ... flip `v` from `27` ⇢ `28` respectively `28` ⇢ `27`  (`v=[27,28] ⇢ [28,27]`)
* `r` ... keep `r`
* `s'` ... is `-s mod N`

### 🕹️ Demo

⇒  `EcdsaSignaturePlayground.DEMO_malleableSignatureParams()`

### ⚠️ Security

This is the reason why you should never include a signature as part of the signed message hash or unique identifier (see [CWE-347: Improper Verification of Cryptographic Signature](https://swcregistry.io/docs/SWC-117)).


## 2) May recover arbitrary addresses for invalid signatures

This, can be forced by setting ...

* `s` ... to a random value

### 🕹️ Demo

⇒ `EcdsaSignaturePlayground.DEMO_arbitrarySigner()`

### ⚠️ Security

This is the reason why you should always check that `ecrecover(...) != address(expected)`, is an address you expect.

## 3) Does not throw on error

`ecrecover()` does not throw but returns `address(0x0)` on error.

This, can be forced by setting an ...

* `v` to an invalid value
* `r` to a invalid/random value

### 🕹️ Demo

⇒ `EcdsaSignaturePlayground.DEMO_forcedRecoverError()`
  
### ⚠️ Security

This is the reason why you should reject execution on an `ecrecover()` error condition: `ecrecover(...) != address(0x0)`.
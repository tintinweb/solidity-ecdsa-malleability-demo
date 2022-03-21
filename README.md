# Solidity `ecrecover()` / ECDSA Playground


The Ethereum Virtual Machine (EVM) provides a pre-compile (it is actually a built-in contract) ECDSA signature verification functionality via a call to [ecrecover()](https://docs.soliditylang.org/en/v0.4.24/units-and-global-variables.html#mathematical-and-cryptographic-functions) and there are a couple of interesting quirks when using ECDSA signatures with Solidity Smart Contracts


⇒ 🕹️ [Demo Playground on Görli]()<br>
⇒ 📄 [EcdsaSignaturePlayground.sol](./EcdsaSignaturePlayground.sol)


## 1) Multiple parameters verify the same signature/message

For a valid ECDSA signature `sig  = (v, r, s)` for message `hash(m)` there exists a sister signature pair `sig' = (v', r, -s mod N)` that validly verifies the same message `hash(m)`. 


The sister `sig'` can be created as follows:

* `v'` ... flip `v=[27,28] ⇢ v'=[28,27]`)
* `r` ... keep `r`
* `s'` ... calculate `-s mod N`

### 🕹️ Demo

⇒  `EcdsaSignaturePlayground.DEMO_malleableSignatureParams()`

### ⚠️ Security

Never use the raw signature bytes or signature parameters as a unique identifier in your system (see [CWE-347: Improper Verification of Cryptographic Signature](https://swcregistry.io/docs/SWC-117)).


## 2) May recover arbitrary addresses for invalid signatures

This, can be forced by setting ...

* `s` ... to a random value

### 🕹️ Demo

⇒ `EcdsaSignaturePlayground.DEMO_arbitrarySigner()`

### ⚠️ Security

Ensure the address recovered from the signature is an address you expect in the system.

## 3) Does not throw on error

`ecrecover()` does not throw but returns `address(0x0)` on error.

This, can be forced by setting an ...

* `v` to an invalid value
* `r` to a invalid/random value

### 🕹️ Demo

⇒ `EcdsaSignaturePlayground.DEMO_forcedRecoverError()`
  
### ⚠️ Security

Reject signatures that recover to `address(0x0)` as this indicates an error condition.

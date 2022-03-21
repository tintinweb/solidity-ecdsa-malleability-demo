# Solidity `ecrecover()` / ECDSA Playground


The Ethereum Virtual Machine (EVM) provides a pre-compile to verify and recover signers of ECDSA signed messages. However, there are a couple of interesting quirks one should know about [ecrecover()](https://docs.soliditylang.org/en/v0.4.24/units-and-global-variables.html#mathematical-and-cryptographic-functions) that may affect the security of the system using it.

⇒ 🕹️ [Demo Playground on Görli](https://goerli.etherscan.io/address/0xce9d78888b5bcce734a623c5e1d7a08061d40c74#readContract)<br>
⇒ 📄 [EcdsaSignaturePlayground.sol](./EcdsaSignaturePlayground.sol)

<a href="https://goerli.etherscan.io/address/0xce9d78888b5bcce734a623c5e1d7a08061d40c74#readContract" ><img width="691" alt="image" src="https://user-images.githubusercontent.com/2865694/159253926-a328cb2c-9147-491f-bcf3-05566bd4a5eb.png"></a>



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
* `r` to a value that is not in the field secp256k1 (`> SECP256K1_N`)

### 🕹️ Demo

⇒ `EcdsaSignaturePlayground.DEMO_forcedRecoverError()`
  
### ⚠️ Security

Reject signatures that recover to `address(0x0)` as this is indicative of an error condition.

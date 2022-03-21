/**
 * @author github.com/tintinweb
 * @license MIT
 * see https://github.com/tintinweb/solidity-ecdsa-malleability-demo
 **/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EcdsaSignaturePlayground {

    uint constant SECP256K1_N  = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;

    /**
     * @dev Demo Signature
     * @return Demo signature params (h(m), v, r, s)
     */
    function DEMO_getDemoSignature() public pure returns(bytes32 , uint8 , bytes32 , bytes32) {
        bytes32 hashedMessage = 0x1c8aff950685c2ed4bc3174f3472287b56d9517b9c948127319a09a7a36deac8;
        bytes32 r = 0xb7cf302145348387b9e69fde82d8e634a0f8761e78da3bfa059efced97cbed0d;
        bytes32 s = 0x2a66b69167cafe0ccfc726aec6ee393fea3cf0e4f3f9c394705e0f56d9bfe1c9;
        uint8 v = 28;
        return (hashedMessage, v, r, s);
    }

    /**
     * @dev Demo - take valid signature params and flip 's'.
     * @return mangled signature (hash, v', r, -s mod N)
     */
    function DEMO_malleableSignatureParams() public pure returns(bytes32 , uint8 , bytes32 , bytes32) {
        (bytes32 hashedMessage, uint8 v, bytes32 r, bytes32 s) = DEMO_getDemoSignature();
        return testMalleableSignature(hashedMessage, v, r, s);
    }

    /**
     * @dev TestCase - takes signature params, flips 's', verifies new sig params are valid
     * @param _hashedMessage (optional) hashed signed message (can be omitted)
     * @param _v signature param v (0 or 1 or 27 or 28)
     * @param _r signature param r
     * @param _s signature param s
     * @return signature (hash, v', r, -s mod N)
     */
    function testMalleableSignature(bytes32 _hashedMessage, uint8 _v, bytes32 _r, bytes32 _s) public pure returns(bytes32 , uint8 , bytes32 , bytes32) {
        
        // 1) get original signer
        address original_signer =  recoverSigner(_hashedMessage, _v, _r, _s);

        // 2) flip signature
        (, uint8 v2,, bytes32 s2) = flipSignatureParams(_hashedMessage, _v, _r, _s);

        // 3) verify flipped signature
        address mangled_signer = recoverSigner(_hashedMessage, v2, _r, s2);
        
        // x) sanity check & return mangled signer
        require(original_signer == mangled_signer && _v != v2 && _s != s2, "signature mismatch");
        return (_hashedMessage, v2, _r, s2);
    }
        

    /**
     * @dev Generate valid signature parameters by flipping signature parameter 's'
     * @dev Valid ECDSA signatures are: (v, r, s) == (v', r, -s mod N)
     * @param _hashedMessage (optional) hashed signed message
     * @param _v signature param v (0 or 1 or 27 or 28)
     * @param _r signature param r
     * @param _s signature param s
     * @return signature (hash, v', r, -s mod N)
     */
    function flipSignatureParams(bytes32 _hashedMessage, uint8 _v, bytes32 _r, bytes32 _s) public pure returns (bytes32 , uint8 , bytes32 , bytes32){
        // lift version to expected range [27/28]
        _v = (_v <= 1) ? _v + 27 : _v;
        require(_v==27 || _v==28, "err: unsupported v"); //

        // New signature is (v', r, -s mod N)
        unchecked {
            _v = _v == 27 ? 28 : 27; // flip v -> v'
            _s = bytes32(SECP256K1_N - uint(_s)); // -s mod N
        }
        return (_hashedMessage, _v, _r, _s);
    }


    /**
     * @dev Recover the signer of a messager. 
     * @param _hashedMessage hashed signed message (can be omitted)
     * @param _v signature param v
     * @param _r signature param r
     * @param _s signature param s
     * @return recovered signer (address(0x0) on error)
     */
    function recoverSigner(bytes32 _hashedMessage, uint8 _v, bytes32 _r, bytes32 _s) public pure returns (address) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHashMessage = keccak256(abi.encodePacked(prefix, _hashedMessage));
        address signer = ecrecover(prefixedHashMessage, _v, _r, _s);
        return signer;
    }

    /**
     * @dev Demo - return random signer address by changing 'r'
     * @param _nonce additional entropy
     * @return recoveredSigner
     */
    function DEMO_arbitrarySigner(uint _nonce) public view returns(address){
        bytes32 hashedMessage = 0x1c8aff950685c2ed4bc3174f3472287b56d9517b9c948127319a09a7a36deac8;
        bytes32 r = 0xb7cf302145348387b9e69fde82d8e634a0f8761e78da3bfa059efced97cbed0d;
        bytes32 s = bytes32(keccak256(abi.encodePacked(msg.sender, tx.origin, blockhash(block.number), _nonce)));
        uint8 v = 28;

        address recoveredSigner = recoverSigner(hashedMessage, v, r, s);
        return recoveredSigner;
    }

    /**
     * @dev Demo - ecrecover error (address(0x0)) by setting an invalid 'r' or 'v'
     * @param _nonce additional entropy
     * @return recoveredSigner
     */
    function DEMO_forcedRecoverError(uint _nonce) public pure returns(address){
        bytes32 hashedMessage = 0x1c8aff950685c2ed4bc3174f3472287b56d9517b9c948127319a09a7a36deac8;
        bytes32 r = bytes32(SECP256K1_N + _nonce);
        bytes32 s = 0xb7cf302145348387b9e69fde82d8e634a0f8761e78da3bfa059efced97cbed0d;
        uint8 v = 28;

        address recoveredSigner = recoverSigner(hashedMessage, v, r, s);
        return recoveredSigner;
    }
}
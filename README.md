
```solidity
// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.20;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract Storage {

	uint256 numberA;
	uint256 numberB;


	/**
	 * @dev Store value in storage variable `numberA`
	 * @param num value to store
	 */
	function storeA(uint256 num) public {
		numberA = num;
	}
	// hash : C534BE7A


	/**
	 * @dev Store value in storage variable `numberB`
	 * @param num value to store
	 */
	function storeB(uint256 num) public {
		numberB = num;
	}
	// hash : 9AE4B7D0


	/**
	 * @dev Return value 
	 * @return value of multiplification of `numberA` by `numberB`
	 */
	function retrieve() public view returns (uint256) {
		return Multiply( numberA, numberB);
	}
	// hash : 2E64CEC1


	/**
	 * @dev Return value 
	 * @return compute and return the multiplification of two values
	 */
	function Multiply(uint a, uint b) pure private returns(uint256) {
		return a * b;
	}
	// hash : xxxxxxxx

}
```

```json
[
	{
		"inputs": [],
		"name": "retrieve",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "num",
				"type": "uint256"
			}
		],
		"name": "storeA",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "num",
				"type": "uint256"
			}
		],
		"name": "storeB",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	}
]
```



```assembly
		tag 1			contract Storage {\n\n    uint...
			JUMPDEST 			contract Storage {\n\n    uint...
			POP 			contract Storage {\n\n    uint...
			PUSH 4			contract Storage {\n\n    uint...
			CALLDATASIZE 			contract Storage {\n\n    uint...
			LT 			contract Storage {\n\n    uint...
			PUSH [tag] 2			contract Storage {\n\n    uint...
			JUMPI 			contract Storage {\n\n    uint...
			PUSH 0			contract Storage {\n\n    uint...
			CALLDATALOAD 			contract Storage {\n\n    uint...
			PUSH E0			contract Storage {\n\n    uint...
			SHR 			contract Storage {\n\n    uint...
			DUP1 			contract Storage {\n\n    uint...
			PUSH 2E64CEC1			contract Storage {\n\n    uint...
			EQ 			contract Storage {\n\n    uint...
			PUSH [tag] 3			contract Storage {\n\n    uint...
			JUMPI 			contract Storage {\n\n    uint...
			DUP1 			contract Storage {\n\n    uint...
			PUSH 9AE4B7D0			contract Storage {\n\n    uint...
			EQ 			contract Storage {\n\n    uint...
			PUSH [tag] 4			contract Storage {\n\n    uint...
			JUMPI 			contract Storage {\n\n    uint...
			DUP1 			contract Storage {\n\n    uint...
			PUSH C534BE7A			contract Storage {\n\n    uint...
			EQ 			contract Storage {\n\n    uint...
			PUSH [tag] 5			contract Storage {\n\n    uint...
			JUMPI 			contract Storage {\n\n    uint...
```


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
    uint256 numberC;
    uint256 numberD;


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
     * @dev Store value in storage variable `numberC`
     * @param num value to store
     */
    function storeC(uint256 num) public {
        numberC = num;
    }
    // hash : 4CF56E0C


    /**
     * @dev Store value in storage variable `numberD`
     * @param num value to store
     */
    function storeD(uint256 num) public {
        numberD = num;
    }
    // hash : xxxxxxxx

    /**
     * @dev Return value 
     * @return value of multiplification of `numberA` by `numberB` by `numberC` by `numberD`
     */
    function retrieve() public view returns (uint256) {
        return Multiply( numberA, numberB, numberC, numberD);
    }
    // hash : 2E64CEC1


    /**
     * @dev Return value 
     * @return compute and return the multiplification of four values
     */
    function Multiply(uint a, uint b, uint c, uint d) pure private returns(uint256) {
        return a * b * c * d;
    }
    // hash : xxxxxxxx

}
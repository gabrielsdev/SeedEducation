// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Institutions.sol";

contract Operations {

    address public institutionContractAddress;

    modifier onlyAdmin() {
        require(Institutions(institutionContractAddress).isAuthorizedAdmin(msg.sender), "Sender not authorized");
        _;
    }

    constructor(address _institutionContractAddress) {
        institutionContractAddress = _institutionContractAddress;
    }

    function add
}
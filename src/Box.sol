// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
contract Box is Ownable {
        
    uint256 private s_number;

    event NumberChanged(uint256 indexed number);

    function store(uint256 newnumber) public onlyOwner {
        s_number = newnumber;
        emit NumberChanged(newnumber);
    }

    function getNumber() external view returns(uint256 currentNum) {
        return s_number;
    }
}
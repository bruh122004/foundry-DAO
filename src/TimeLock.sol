// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";


contract TimeLock is TimelockController {

    constructor(uint256 minDelay,
        address[] memory proposers,
        address[] memory executors) 
        TimelockController(minDelay, proposers, executors, msg.sender){}


}//test:1:12:48:53
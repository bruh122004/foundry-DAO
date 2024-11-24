// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {Box} from "src/Box.sol";
import {GovToken} from "src/GOVToken.sol";
import {TimeLock} from "src/TimeLock.sol";
import {MyGovernor} from "src/MyGovernor.sol";

contract MygovernorTest is Test {
    GovToken govToken;
    TimeLock timelock;
    Box box;
    MyGovernor governor;
    uint256 public constant VOTING_PERIOD = 50400;
    address public user = makeAddr("user");
    uint256 public constant INITIAL_SUPPLY = 100 ether;
    uint256 public constant MIN_DELAY = 3600;

    address[] pruposers;
    address[] executors;
    uint256[] values;
    bytes[] calldatas;
    address[] targets;
    function setUp() public {
        govToken = new GovToken();
        govToken.mint(user, INITIAL_SUPPLY);
        vm.startPrank(user);
        govToken.delegate(user);
        timelock = new TimeLock(MIN_DELAY, pruposers, executors); 
        governor = new MyGovernor(govToken, timelock);

        bytes32 proposerRole = timelock.PROPOSER_ROLE();
        bytes32 executorRole = timelock.EXECUTOR_ROLE();
        bytes32 adminRole = timelock.TIMELOCK_ADMIN_ROLE();
        
        
        timelock.grantRole(proposerRole, address(governor));
        timelock.grantRole(executorRole, address(0));
        timelock.revokeRole(adminRole, user);
        vm.stopPrank();
        box = new Box();

        box.transferOwnership(address(timelock));

    }

    function testCantUpdatBoxWithoutGovernance() public {
        vm.expectRevert();
        box.store(1);
    }


    function testGovernanceUpdatesBox() public {
        uint256 valueToStore = 888;
        string memory description = "store 1 in Box";

        bytes memory encodeFunctionCall = abi.encodeWithSignature("store(uint256)", valueToStore);

        values.push(0);

        calldatas.push(encodeFunctionCall);
        targets.push(address(box));

        // propose to the DAO

        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        //View the state
        console.log("Proposal State: ", uint256(governor.state(proposalId)));

        vm.warp(block.timestamp + 1 + 1);
        vm.roll(block.number + 1 + 1);

        console.log("Proposal State: ", uint256(governor.state(proposalId)));
        //voting
        string memory reason = "cuz I want a better life for my kids";

        uint8 votWay = 1;
        vm.prank(user);
        governor.castVoteWithReason(proposalId, votWay, reason);
        vm.warp(block.timestamp + VOTING_PERIOD + 1);
        vm.roll(block.number + VOTING_PERIOD + 1);
        
        

        //3queue the TX

        bytes32 descriptionhash = keccak256(abi.encodePacked(description));
        governor.queue(targets, values, calldatas, descriptionhash);
        console.log("Proposal State: ", uint256(governor.state(proposalId)));

        vm.warp(block.timestamp + MIN_DELAY + 1);
        vm.roll(block.number + MIN_DELAY + 1);

        //execute

        governor.execute(targets, values, calldatas, descriptionhash);
        assert(box.getNumber() == valueToStore);
        console.log("box value: ", box.getNumber());
    }//1:13:09
}
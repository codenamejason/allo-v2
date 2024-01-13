// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../shared/RegistrySetup.sol";

// Core Contracts
import {RegistryWrapperSetup} from "../shared/RegistryWrapperSetup.sol";
import {Anchor} from "../../../contracts/core/Anchor.sol";

// Internal libraries
import {Errors} from "../../../contracts/core/libraries/Errors.sol";
import {Native} from "../../../contracts/core/libraries/Native.sol";
import {Metadata} from "../../../contracts/core/libraries/Metadata.sol";
// Test libraries
import {TestUtilities} from "../../utils/TestUtilities.sol";
import {MockERC20} from "../../utils/MockERC20.sol";

contract RegistryWrapperTest is Test, RegistryWrapperSetup, Native, Errors {
    Metadata public metadata;
    string public name;
    uint256 public nonce;

    MockERC20 public token;

    function setUp() public {
        __RegistryWrapperSetup();
        metadata = Metadata({protocol: 1, pointer: "test metadata"});
        name = "New Profile";
        nonce = 2;

        token = new MockERC20();
    }

    function test_initialize() public {
        Registry newRegistry = new Registry();
        newRegistry.initialize(registry_owner());

        assertTrue(newRegistry.hasRole(newRegistry.ALLO_OWNER(), registry_owner()));
    }

    function testRevert_initialize_zeroAddress() public {
        Registry newRegistry = new Registry();

        vm.expectRevert(ZERO_ADDRESS.selector);
        newRegistry.initialize(address(0));
    }

    function testRevert_initialize_alreadyInitialized() public {
        Registry newRegistry = new Registry();
        newRegistry.initialize(registry_owner());

        vm.expectRevert();
        newRegistry.initialize(registry_owner());
    }

    function test_addRegistryToList() public {
        // bytes32 profileId = _registryWrapper_.createProfile(0, "New Profile", metadata, profile1_owner(), profile1_members());
        // address registry = address(new Registry());
        // bytes memory data = abi.encode(Metadata({protocol: 1, pointer: "test metadata"}));

        // string memory anchor = _registryWrapper_.addRegistryToList(profileId, registry, data);

        // assertTrue(_registryWrapper_.isRegistry(profileId, registry));
        // assertTrue(_registryWrapper_.isRegistryAnchor(profileId, registry));
        //assertEquals(anchor, _registry_.getProfileById(profileId).anchor);
    }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import "../shared/RegistrySetup.sol";

// Core Contracts
import {RegistryWrapperSetupFull} from "../shared/RegistryWrapperSetup.sol";
import {RegistryWrapper} from "../../../contracts/core/RegistryWrapper.sol";
import {Anchor} from "../../../contracts/core/Anchor.sol";
import {AlloSetup} from "../shared/AlloSetup.sol";

// Internal libraries
import {Metadata} from "../../../contracts/core/libraries/Metadata.sol";
// Test libraries
import {TestUtilities} from "../../utils/TestUtilities.sol";
import {MockERC20} from "../../utils/MockERC20.sol";

contract RegistryWrapperTest is AlloSetup, RegistryWrapper, RegistryWrapperSetupFull {
    Metadata public metadata;
    string public name;
    uint256 public nonce;

    MockERC20 public token;

    RegistryWrapper public registryWrapper;

    function setUp() public {
        __RegistryWrapperSetup();
        __AlloSetup(address(registry()));
        metadata = Metadata({protocol: 1, pointer: "test metadata"});
        name = "New Profile";
        nonce = 2;

        token = new MockERC20();

        registryWrapper = new RegistryWrapper();
        registryWrapper.initialize(
            registry_owner(), makeAddr("opeas"), RegistryType.OPEAS, abi.encode(makeAddr("opeas"))
        );
    }

    // function test_initialize() public {
    //     RegistryWrapper newRegistryWrapper = new RegistryWrapper();
    //     registryWrapper.initializeWrapper(registry_owner(), RegistryType.ALLO);
    //     assertTrue(newRegistryWrapper.hasRole(newRegistryWrapper.ALLO_OWNER(), registry_owner()));
    // }

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
        vm.prank(address(allo()));

        vm.expectEmit();
        emit RegistryUpdated(address(makeAddr("opeas")), true);

        registryWrapper.addRegistryToList(address(makeAddr("opeas")), abi.encode(metadata));
    }

    function testRevert_addRegistryToList_zeroAddress() public {
        vm.prank(address(allo()));

        vm.expectRevert(ZERO_ADDRESS.selector);
        registryWrapper.addRegistryToList(address(0), abi.encode(metadata));
    }

    // function testRevert_addRegistryToList_notAllo() public {
    //     vm.prank(address(allo()));
    //     vm.expectRevert();
    //     registryWrapper.addRegistryToList(address(makeAddr("opeas")), abi.encode(metadata));
    // }

    function test_updateRegistryList() public {
        vm.prank(address(allo()));

        vm.expectEmit();
        emit RegistryUpdated(address(makeAddr("opeas")), true);
        registryWrapper.addRegistryToList(address(makeAddr("opeas")), abi.encode(metadata, true));

        vm.expectEmit();
        emit RegistryUpdated(address(makeAddr("opeas")), false);
        registryWrapper.updateRegistryList(address(makeAddr("opeas")), abi.encode(metadata, false));

        (address owner, bool active, address registry, Metadata memory meatadata) =
            registryWrapper.registries(address(makeAddr("opeas")));

        assertEq(metadata.protocol, 1);
        assertEq(metadata.pointer, "test metadata");
        assertTrue(active == false);
    }
}

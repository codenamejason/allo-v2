// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IRegistryManager} from "./interfaces/IRegistryManager.sol";
import {IRegistryWrapper} from "./interfaces/IRegistryWrapper.sol";

contract RegistryManager is IRegistryManager {
    function wrappedRegistry() external view returns (IRegistryWrapper) {}
}

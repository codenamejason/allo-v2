// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IRegistryWrapper} from "./IRegistryWrapper.sol";

interface IRegistryManager {
    function wrappedRegistry() external view returns (IRegistryWrapper);

    event RegistryUpdated(address indexed registry, bool active);
}

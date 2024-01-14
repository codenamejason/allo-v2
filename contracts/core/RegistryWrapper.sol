// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.19;

// External Libraries
import "openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import {ERC20} from "solady/tokens/ERC20.sol";
// Core
import "./Registry.sol";
// Interfaces
import {IRegistryWrapper} from "./interfaces/IRegistryWrapper.sol";
import {IEAS, Attestation, AttestationRequest, AttestationRequestData} from "eas-contracts/IEAS.sol";
import {ISchemaRegistry, ISchemaResolver, SchemaRecord} from "eas-contracts/ISchemaRegistry.sol";
import {EASSchemaResolver} from "../eas/EASSchemaResolver.sol";

// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⣿⢿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⣿⡟⠘⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⠀⣀⣴⣾⣿⣿⣿⣿⣾⠻⣿⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⡿⠀⠀⠸⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⠀⠀⠀⠀⢀⣠⣴⣴⣶⣶⣶⣦⣦⣀⡀⠀⠀⠀⠀⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⣴⣿⣿⣿⣿⣿⣿⡿⠃⠀⠙⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⠁⠀⠀⠀⢻⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⠀⠀⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⡀⠀⠀⠀⠀
// ⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⡿⠁⠀⠀⠀⠘⣿⣿⣿⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⠃⠀⠀⠀⠀⠈⢿⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⠀⣰⣿⣿⣿⡿⠋⠁⠀⠀⠈⠘⠹⣿⣿⣿⣿⣆⠀⠀⠀
// ⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⡿⠀⠀⠀⠀⠀⠀⠈⢿⣿⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⢰⣿⣿⣿⣿⠁⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⡀⠀⠀
// ⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣟⠀⡀⢀⠀⡀⢀⠀⡀⢈⢿⡟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⡇⠀⠀
// ⠀⠀⣠⣿⣿⣿⣿⣿⣿⡿⠋⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⣿⡿⢿⠿⠿⠿⠿⠿⠿⠿⠿⠿⢿⣿⣿⣿⣷⡀⠀⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⠸⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⠂⠀⠀
// ⠀⠀⠙⠛⠿⠻⠻⠛⠉⠀⠀⠈⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⣿⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣿⣿⣿⣧⠀⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⠀⢻⣿⣿⣿⣷⣀⢀⠀⠀⠀⡀⣰⣾⣿⣿⣿⠏⠀⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣧⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⠀⠀⠹⢿⣿⣿⣿⣿⣾⣾⣷⣿⣿⣿⣿⡿⠋⠀⠀⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠙⠋⠛⠙⠋⠛⠙⠋⠛⠙⠋⠃⠀⠀⠀⠀⠀⠀⠀⠀⠠⠿⠻⠟⠿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⠟⠿⠟⠿⠆⠀⠸⠿⠿⠟⠯⠀⠀⠀⠸⠿⠿⠿⠏⠀⠀⠀⠀⠀⠈⠉⠻⠻⡿⣿⢿⡿⡿⠿⠛⠁⠀⠀⠀⠀⠀⠀
//                    allo.gitcoin.co

/// @title Registry Contract
contract RegistryWrapper is Registry, IRegistryWrapper, EASSchemaResolver {
    // ====================================
    // =========== Errors =================
    // ====================================
    error RegistryNotSupported();
    error RegistryNotActive();
    error NotSubscribed();
    error AlreadySubscribed();
    error AlreadyPublished();
    error NotPublished();
    error ALREADY_ADDED();
    error OUT_OF_BOUNDS();
    error INVALID_SCHEMA();

    bytes32 public constant _NO_RELATED_ATTESTATION_UID = 0;
    EASInfo public easInfo;

    struct EASInfo {
        IEAS eas;
        ISchemaRegistry schemaRegistry;
        bytes32 schemaUID;
        string schema;
        bool revocable;
    }

    // recipientId -> uid
    mapping(address => bytes32) public recipientIdToUID;

    // Map the registy address to the registry data
    mapping(address => RegistryData) public registries;

    // Queue for publishing
    // registry => publisher => bool
    mapping(address => mapping(address => bool)) public pubQueue;

    // Queue for subscribing
    // registry => subscriber => bool
    mapping(address => mapping(address => bool)) public subQueue;

    // Subscribers
    // registry => subscriber => bool
    mapping(address => mapping(address => bool)) public subscribers;

    // ====================================
    // =========== Initializer =============
    // ====================================

    /// @notice Initializes the contract after an upgrade
    /// @dev During upgrade -> a higher version should be passed to reinitializer. Reverts if the '_owner' is the 'address(0)'
    /// * we will initiialize with Allo Registry type and add the others.
    /// @param _owner The owner of the contract
    function initialize(address _owner, address _registry, RegistryType _type, bytes32 _data)
        external
        virtual
        reinitializer(1)
    {
        // Make sure the owner is not 'address(0)'
        if (_owner == address(0)) revert ZERO_ADDRESS();

        // Basic idea of how we can initialize each one based on the type
        if (RegistryType.OPEAS == _type) {
            // todo:
            registries[_registry].registry = _registry;
        } else if (RegistryType.GIVITH == _type) {
            // todo:
            registries[_registry].registry = _registry;
        } else if (RegistryType.CLRFUND == _type) {
            // todo:
            registries[_registry].registry = _registry;
        } else if (RegistryType.ALLO == _type) {
            // todo:
            registries[_registry].registry = _registry;
        } else {
            revert RegistryNotSupported();
        }
    }

    function wrappedRegistry() external view override returns (IRegistry) {
        return IRegistry(address(this));
    }

    function publishRegistry(address registry, bytes32 data) public returns (bool) {
        // Make sure the registry is active
        if (!registries[registry].active) revert RegistryNotActive();

        // Make sure the publisher is not already in the queue
        if (pubQueue[registry][msg.sender]) revert AlreadyPublished();

        // Add the publisher to the queue
        pubQueue[registry][msg.sender] = true;

        // Emit the event
        emit Published(registry, true, msg.sender);

        return true;
    }

    function batchPublishRegistries(address[] memory _registries, bytes32[] memory _datas)
        external
        override
        returns (bool)
    {
        for (uint256 i = 0; i < _registries.length; i++) {
            publishRegistry(_registries[i], _datas[i]);
        }
    }

    function subscribeToRegistry(address registry, bytes32 data) public override returns (bool) {
        // Make sure the registry is active
        if (!registries[registry].active) revert RegistryNotActive();

        // Make sure the subscriber is not already subscribed
        if (subscribers[registry][msg.sender]) revert AlreadySubscribed();

        // Add the subscriber to the queue
        subQueue[registry][msg.sender] = true;

        // Emit the event
        emit Subscribed(registry, true, msg.sender);

        return true;
    }

    function batchSubscribeToRegistries(address[] memory _registries, bytes32[] memory _datas)
        external
        override
        returns (bool)
    {
        for (uint256 i = 0; i < _registries.length; i++) {
            subscribeToRegistry(_registries[i], _datas[i]);
        }
    }

    /// @notice Updates the registry address
    /// @param _registry The address of the registry to update
    /// @param _data The data to pass to the registry for initialization
    function addRegistryToList(address _registry, bytes memory _data) external override returns (string memory) {
        if (_registry == address(0)) revert ZERO_ADDRESS();

        // Add the registry to the mapping if its not already there, otherwise update it to the new data
        RegistryData storage registryData = registries[_registry];

        // decode the data
        (Metadata memory metadata, bool active) = abi.decode(_data, (Metadata, bool));

        if (registryData.registry == _registry) {
            // Initialize the registry
            registryData.registry = _registry;
            registryData.metadata = metadata;
            registryData.active = active;
            registryData.owner = msg.sender;

            // Add to the mapping
            registries[_registry] = registryData;

            // Emit the event
            emit RegistryUpdated(_registry, true);
        }
    }

    /// @notice Updates whether registry is active or not and updates the metadata
    /// @param _registry The address of the registry to update
    /// @param _data The data to pass to the registry that needs to be updated
    /// The data should look like this: (Metadata, bool)
    function updateRegistryList(address _registry, bytes memory _data) external override returns (string memory) {
        // Add the registry to the mapping if its not already there, otherwise update it to the new data
        RegistryData storage registryData = registries[_registry];

        // decode the data
        (Metadata memory metadata, bool active) = abi.decode(_data, (Metadata, bool));

        // Update the registry
        registryData.registry = _registry;
        registryData.metadata = metadata;
        registryData.active = active;
        registryData.owner = msg.sender;

        // Emit the event
        emit RegistryUpdated(_registry, active);
    }

    /// @dev Grant EAS attestation to recipient with the EAS contract.
    /// @param _recipientId The recipient ID to grant the attestation to.
    /// @param _expirationTime The expiration time of the attestation.
    /// @param _data The data to include in the attestation.
    /// @param _value The value to send with the attestation.
    function _grantEASAttestation(address _recipientId, uint64 _expirationTime, bytes memory _data, uint256 _value)
        internal
        returns (bytes32)
    {
        AttestationRequest memory attestationRequest = AttestationRequest(
            easInfo.schemaUID,
            AttestationRequestData({
                recipient: _recipientId,
                expirationTime: _expirationTime,
                revocable: easInfo.revocable,
                refUID: _NO_RELATED_ATTESTATION_UID,
                data: _data,
                value: _value
            })
        );

        return easInfo.eas.attest(attestationRequest);
    }

    /// =========================
    /// ==== EAS Functions =====
    /// =========================

    // Note: EAS Information - Supported Testnets
    // Version: 0.27
    // * OP Goerli
    //    EAS Contract: 0xC2679fBD37d54388Ce493F1DB75320D236e1815e
    //    Schema Registry: 0x0a7E2Ff54e76B8E6659aedc9103FB21c038050D0
    // * Sepolia
    //    EAS Contract: 0x1a5650d0ecbca349dd84bafa85790e3e6955eb84
    //    Schema Registry: 0x7b24C7f8AF365B4E308b6acb0A7dfc85d034Cb3f

    /// @dev Gets an attestation from the EAS contract using the UID
    /// @param uid The UUID of the attestation to get.
    function getAttestation(bytes32 uid) external view returns (Attestation memory) {
        return easInfo.eas.getAttestation(uid);
    }

    /// @dev Gets a schema from the SchemaRegistry contract using the UID
    /// @param uid The UID of the schema to get.
    function getSchema(bytes32 uid) external view returns (SchemaRecord memory) {
        return easInfo.schemaRegistry.getSchema(uid);
    }

    /// @notice Returns if this contract is payable or not
    /// @return True if the attestation is payable, false otherwise
    function isPayable() public pure override returns (bool) {
        return true;
    }

    /// @notice Returns if the attestation is expired or not
    /// @param _recipientId The recipient ID to check
    function isAttestationExpired(address _recipientId) external view returns (bool) {
        if (easInfo.eas.getAttestation(recipientIdToUID[_recipientId]).expirationTime < block.timestamp) {
            return true;
        }
        return false;
    }

    function onAttest(Attestation calldata, uint256) internal pure override returns (bool) {
        return true;
    }

    function onRevoke(Attestation calldata, uint256) internal pure override returns (bool) {
        return true;
    }
}

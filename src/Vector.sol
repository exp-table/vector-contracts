// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.11;
import "solmate/auth/Auth.sol";
import "solmate/utils/SafeTransferLib.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

interface IStarknetCore {
    /**
      Sends a message to an L2 contract.

      Returns the hash of the message.
    */
    function sendMessageToL2(
        uint256 to_address,
        uint256 selector,
        uint256[] calldata payload
    ) external returns (bytes32);
}

/// @title A clonable contract to send messages to Starknet
/// @author exp.table
/// @custom:experimental This is an experimental contract.
contract Vector is Auth {
    event Cloned(address clone);

    constructor(IStarknetCore starknetCore_) Auth(address(0), Authority(address(0))) payable {
        _starknetCore = starknetCore_;
    }

    uint256 public price;
    IStarknetCore private immutable _starknetCore;
    uint256 private _L2Target;
    uint256 private _selector;
    bool private _initialized;

    /// @notice Withdraw the funds (eth) to a recipient of the owner's choosing
    /// @param recipient_ The address to send the funds to
    function withdraw(address recipient_) public requiresAuth {
        SafeTransferLib.safeTransferETH(recipient_, address(this).balance);
    }

    /// @notice Set the address of the L2 contract to interact with
    /// @param target_ The address of the L2 contract
    function setL2Target(uint256 target_) public requiresAuth {
        _L2Target = target_;
    }

    /// @notice Set the select of the L2 contract's function to be called
    /// @param selector_ The selector of the function
    function setSelector(uint256 selector_) public requiresAuth {
        _selector = selector_;
    }

    /// @notice Set the price of sending a message to the L2 contract
    /// @dev price is in wei
    /// @param price_ The price for each interaction
    function setPrice(uint256 price_) public requiresAuth {
        price = price_;
    }

    /// @notice Clone the original contract and configure it with the proper parameters for your use case
    /// @param selector_  The selector of the function
    /// @param price_ The price for each interaction
    /// @return cloneAddress The address of the cloned contract
    function clone(uint256 selector_, uint256 price_) public returns (address cloneAddress) {
        cloneAddress = Clones.clone(address(this));
        Vector(cloneAddress).initialize(address(_starknetCore), msg.sender, selector_, price_);
        emit Cloned(cloneAddress);
    }

    /// @notice Initialize the cloned contract with the proper parameters for your use case
    /// @param owner_ The owner of this contract
    /// @param selector_  The selector of the function
    /// @param price_ The price for each interaction
    function initialize(address starknetCore_, address owner_, uint256 selector_, uint256 price_) public {
        require(!_initialized);
        _selector = selector_;
        price = price_;
        assembly {sstore(0, owner_)} // Auth's first slot is the owner
        assembly {sstore(3, starknetCore_)} // 4th slot is the starknetCore
        _initialized = true;
    }

    /// @notice Call the L2 contract's function
    /// @dev the payload is expected to be constructed on your side - it should all be uint256s whose values are inferior to the PRIME used by starknet
    /// @param payload_ Array of uint256s being the calldata of the L2 contract function
    function deliver(uint256[] calldata payload_) external payable {
        require(msg.value == price);
        _starknetCore.sendMessageToL2(_L2Target, _selector, payload_);
    }
}

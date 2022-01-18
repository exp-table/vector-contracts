// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.11;

import "ds-test/test.sol";
import "../Vector.sol";

interface Vm {
    function deal(address, uint256) external;
    function expectCall(address,bytes calldata) external;
}

contract StarknetCore {
    function sendMessageToL2(
        uint256 to_address,
        uint256 selector,
        uint256[] calldata payload
    ) public returns (bytes32) {
        return keccak256("kek");
    }
}

contract VectorTest is DSTest {

    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    StarknetCore starknetCore = new StarknetCore();

    uint256 L2Target = 69420;
    uint256 selector = 666;
    uint256 price = 1 ether;

    Vector vector;

    function setUp() public {
        vector = new Vector(IStarknetCore(address(starknetCore)));
        vm.deal(address(this), 100 ether);
    }

    function test_no_owner() public {
        assertEq(vector.owner(), address(0));
    }

    function test_clone() public {
        Vector clone = Vector(vector.clone(selector, price));
        assertEq(clone.owner(), address(this));
    }

    function testFail_initialize_twice() public {
        Vector clone = Vector(vector.clone(selector, price));
        clone.initialize(address(starknetCore), address(this), 0, 0);
    }

    function test_withdraw() public {
        Vector clone = Vector(vector.clone(selector, price));
        uint256[] memory payload = new uint256[](2);
        payload[0] = 69420;
        payload[1] = block.number;
        clone.deliver{value: 1 ether}(payload);
        clone.withdraw(address(0xabcdef));
        assertEq(address(0xabcdef).balance, 1 ether);
    }

}

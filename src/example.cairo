%lang starknet
%builtins pedersen range_check

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.starknet.common.syscalls import get_caller_address

const L1_CONTRACT_ADDRESS = 0xMY_L1_CONTRACT

@storage_var
func _balances(owner: felt) -> (balance: felt):
end

@l1_handler
func mint{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    from_address : felt,
    to: felt,
    amount: felt
):
    # Make sure the message was sent by the intended L1 contract.
    assert from_address = L1_CONTRACT_ADDRESS
    let (current_balance) = _balances.read(to)
    _balances.write(to, current_balance + amount)
    return ()
end

@view
func balance_of{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(owner: felt) -> (balance: felt):
    let (balance: felt) = _balances.read(owner)
    return (balance)
end
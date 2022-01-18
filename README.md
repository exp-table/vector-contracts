# Vector
A protocol for paying on Ethereum and minting on Starknet.

| Mainnet        | Goerli             |
| ------------- |:-------------:|
|      | [0xf1aab7da9315c9f0a526c0d09ab3b10f05ac61de](https://goerli.etherscan.io/address/0xf1aab7da9315c9f0a526c0d09ab3b10f05ac61de)|
## Why ?
The two main raisons are the current lack of wide support for wrapped eth and stablecoins on Starknet (although they are coming) and that it, I hope, will provide an easier onboarding experience to developers and users.

## The process
This is a two-step process.
You have to first deploy the Ethereum contract which is done by calling the `clone` function of the `Vector` contract. Notice that when you do so, the `target` (the address of your L2 contract) is not part of the parameters, simply because you first have to deploy the L1 contract in order to use its address in your L2 contract to restrict who can call the, for example, minting function. If not, you would open your contract to be attacked by unwanted actors.
Once it's done, you can use *your* `Vector` contract's address in your L2 contract, and then deploy it. To make the `Vector` work, you have to call the `setL2Target` function with the proper address.

For more informations about what the payload should be and how to construct it, please read the [Starknet docs](https://starknet.io/docs/hello_starknet/l1l2.html#receiving-a-message-from-l1).


### Credits

This was built thanks to the code of [solmate](https://github.com/Rari-Capital/solmate) and [foundry](https://github.com/gakonst/foundry/).


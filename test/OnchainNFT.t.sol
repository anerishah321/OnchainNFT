// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/OnchainNFT.sol";

contract CounterTest is Test {
    NFT public nft;

    function setUp() public {
        nft = new NFT();
    }
}

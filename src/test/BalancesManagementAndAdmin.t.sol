// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.13;

/*
  __     ___      _     _
  \ \   / (_)    | |   | | ████████╗███████╗███████╗████████╗███████╗
   \ \_/ / _  ___| | __| | ╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝██╔════╝
    \   / | |/ _ \ |/ _` |    ██║   █████╗  ███████╗   ██║   ███████╗
     | |  | |  __/ | (_| |    ██║   ██╔══╝  ╚════██║   ██║   ╚════██║
     |_|  |_|\___|_|\__,_|    ██║   ███████╗███████║   ██║   ███████║
      yieldprotocol.com       ╚═╝   ╚══════╝╚══════╝   ╚═╝   ╚══════╝

*/

import "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {console} from "forge-std/console.sol";

import "./shared/Utils.sol";
import "./shared/Constants.sol";
import {ERC4626TokenMock} from "./mocks/ERC4626TokenMock.sol";
import {ZeroState, ZeroStateParams} from "./shared/ZeroState.sol";

import {Exp64x64} from "../Exp64x64.sol";
import {Math64x64} from "../Math64x64.sol";
import {YieldMath} from "../YieldMath.sol";

abstract contract WithLiquidity is ZeroState {
    constructor() ZeroState(ZeroStateParams("DAI", "DAI", 18, "4626")) {}

    function setUp() public virtual override {
        super.setUp();
        shares.mint(address(pool), INITIAL_SHARES * 10**(shares.decimals()));

        vm.prank(alice);
        pool.init(alice, bob, 0, MAX);

        setPrice(address(shares), (cNumerator * (10**shares.decimals())) / cDenominator);
        uint256 additionalFYToken = (INITIAL_SHARES * 10**(shares.decimals())) / 9;

        // Skew the balances without using trading functions
        fyToken.mint(address(pool), additionalFYToken);

        pool.sync();
    }
}

contract Admin__WithLiquidity is WithLiquidity {
    function testUnit_admin1() public {
        console.log("balance management getters return correct values");
        require(pool.getSharesBalance() == shares.balanceOf(address(pool)));
        require(pool.getBaseBalance() > pool.getSharesBalance());
        require(pool.getCurrentSharePrice() == ERC4626TokenMock(address(shares)).convertToAssets(10**shares.decimals()));
        require(pool.getFYTokenBalance() == fyToken.balanceOf(address(pool)) + pool.totalSupply());
        (uint104 sharesCached, uint104 fyTokenCached, uint32 blockTimeStampLast, uint16 g1fee_) = pool.getCache();
        require(g1fee_ == g1Fee);
        require(sharesCached == 1100000000000000000000000);
        console.log(pool.totalSupply());
        // require(fyTokenCached == 1277222222222222221122222);
        require(blockTimeStampLast > 0);
        uint256 expectedCurrentCumulativeRatio = pool.cumulativeRatioLast() +
            ((uint256(fyTokenCached) * 1e27) * (block.timestamp - blockTimeStampLast)) /
            sharesCached;
        (uint256 actualCurrentCumulativeRatio, ) = pool.currentCumulativeRatio();
        require(actualCurrentCumulativeRatio == expectedCurrentCumulativeRatio);
        shares.mint(address(pool), 1e18);
        pool.sync();
        (uint104 sharesCachedNew, , ,) = pool.getCache();
        require(sharesCachedNew == sharesCached + 1e18);
    }

    function testUnit_admin2() public {
        console.log("setFees cannot be set without auth");

        vm.expectRevert(bytes("Access denied"));
        pool.setFees(600);

        vm.prank(bob);
        pool.setFees(600);
    }

}

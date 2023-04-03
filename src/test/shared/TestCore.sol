// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.15;

import "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {console} from "forge-std/console.sol";

import {Exp64x64} from "../../Exp64x64.sol";
import {Math64x64} from "../../Math64x64.sol";
import {YieldMath} from "../../YieldMath.sol";

import "./Utils.sol";
import "./Constants.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";
import {FYTokenMock} from "../mocks/FYTokenMock.sol";
import {ISyncablePool} from "../mocks/ISyncablePool.sol";
import {IERC20Like} from "../../interfaces/IERC20Like.sol";
import "../../Pool/PoolEvents.sol";

// TestCore
// - Initializes state variables.
// - Sets state variable vm for accessing cheat codes.
// - Declares events,
// - Declares constants.
// No new contracts are created
abstract contract TestCore is PoolEvents, Test {

    using Math64x64 for int128;
    using Math64x64 for uint128;
    using Math64x64 for int256;
    using Math64x64 for uint256;
    using Exp64x64 for uint128;

    FYTokenMock public fyToken;
    ISyncablePool public pool;

    address public alice;
    address public bob;

    uint32 public maturity = uint32(block.timestamp + THREE_MONTHS);

    uint256 public ts;

    uint256 immutable k;

    uint16 public constant g1Fee = 9500;
    uint16 public constant g1Denominator = 10000;
    uint256 public g1; // g to use when selling shares to pool
    uint256 public g2; // g to use when selling fyTokens to pool

    uint256 public constant cNumerator = 11;
    uint256 public constant cDenominator = 10;

    uint256 public constant muNumerator = 105;
    uint256 public constant muDenominator = 100;
    uint256 public mu;

    string public assetName;
    string public assetSymbol;
    uint8 public assetDecimals;
    bool public nonCompliant;
    ERC20Mock public asset;

    string public fyName;
    string public fySymbol;

    bytes32 public sharesType; // TYPE_4626 or TYPE_YV
    string public sharesTypeString; // TYPE_4626 or TYPE_YV
    string public sharesName;
    string public sharesSymbol;
    uint8 public sharesDecimals;
    IERC20Like public shares;

    uint256 public aliceSharesInitialBalance;
    uint256 public bobSharesInitialBalance;

    uint256 public initialShares;
    uint256 public initialFYTokens;

    constructor() {
        uint256 invK = 25 * 365 * 24 * 60 * 60 * 10;
        k = uint256(1e18) / invK;
        g1 = uint256(g1Fee) * 1e18 / uint256(g1Denominator);
        g2 = uint256(g1Denominator) * 1e18 / uint256(g1Fee);
        mu = muNumerator * 1e18 / muDenominator;
    }
}

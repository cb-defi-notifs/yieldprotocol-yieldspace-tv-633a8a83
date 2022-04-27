// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13;
import "@yield-protocol/utils-v2/contracts/token/IERC20.sol";
import "@yield-protocol/utils-v2/contracts/token/IERC2612.sol";
import "@yield-protocol/vault-interfaces/IFYToken.sol";
import "src/interfaces/IYVToken.sol";

interface IPool is IERC20, IERC2612 {
    // function base() external returns(IYVToken);
    function burn(
        address baseTo,
        address fyTokenTo,
        uint256 minRatio,
        uint256 maxRatio
    ) external returns (
        uint256,
        uint256,
        uint256
    );
    function burnForBase(address to, uint256 minRatio, uint256 maxRatio) external returns (uint256, uint256);
    function buyBase(address to, uint128 baseOut, uint128 max) external returns(uint128);
    function buyBasePreview(uint128 baseOut) external view returns(uint128);
    function buyFYToken(address to, uint128 fyTokenOut, uint128 max) external returns(uint128);
    function buyFYTokenPreview(uint128 fyTokenOut) external view returns(uint128);
    function currentCumulativeRatio() external returns (uint256 currentCumulativeRatio_, uint256 blockTimestampCurrent);
    function cumulativeRatioLast() external returns (uint256);
    function fyToken() external view returns(IFYToken);
    function getBaseBalance() external view returns(uint104);
    function getBaseCurrentPrice() external view returns (uint256);
    function getCache() external view returns (uint16, uint104, uint104, uint32);
    function getFYTokenBalance() external view returns(uint104);
    function init(
        address to,
        address remainder,
        uint256 minRatio,
        uint256 maxRatio
    ) external returns (
        uint256,
        uint256,
        uint256
    );
    function maturity() external view returns(uint32);
    function mint(
        address to,
        address remainder,
        uint256 minRatio,
        uint256 maxRatio
    ) external returns (
        uint256,
        uint256,
        uint256
    );
    function mintWithBase(
        address to,
        address remainder,
        uint256 fyTokenToBuy,
        uint256 minRatio,
        uint256 maxRatio
    ) external returns (
        uint256,
        uint256,
        uint256
    );
    function mu() external view returns(int128);
    function retrieveBase(address to) external returns(uint128 retrieved);
    function retrieveFYToken(address to) external returns(uint128 retrieved);
    function scaleFactor() external view returns(uint96);
    function sellBase(address to, uint128 min) external returns(uint128);
    function sellBasePreview(uint128 baseIn) external view returns(uint128);
    function sellFYToken(address to, uint128 min) external returns(uint128);
    function sellFYTokenPreview(uint128 fyTokenIn) external view returns(uint128);
    function setFees(uint16 g1Fee_) external;
    function ts() external view returns(int128);
}
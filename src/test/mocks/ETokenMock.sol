// SPDX-License-Identifier: MIT
pragma solidity >=0.8.15;
import "@yield-protocol/utils-v2/contracts/token/ERC20.sol";
import {IERC20Metadata} from "@yield-protocol/utils-v2/contracts/token/IERC20Metadata.sol";
import {EulerMock} from "./EulerMock.sol";
import "forge-std/console.sol";

abstract contract Mintable is ERC20 {
    /// @dev Give tokens to whoever asks for them.
    function mint(address to, uint256 amount) public virtual {
        _mint(to, amount);
    }
}

contract ETokenMock is Mintable {
    IERC20Metadata internal _underlyingAsset;
    uint8 internal _underlyingAssetDecimals;
    uint256 internal scaleFactor;
    EulerMock public euler;
    uint256 public price;

    constructor(
        string memory name,
        string memory symbol,
        address euler_,
        address underlyingAsset_
    ) ERC20(name, symbol, 18) {
        euler = EulerMock(euler_);
        _underlyingAsset = IERC20Metadata(underlyingAsset_);
        _underlyingAssetDecimals = IERC20Metadata(underlyingAsset_).decimals();
        scaleFactor = uint96(10**(18 - uint96(_underlyingAssetDecimals)));
    }

    /// @notice Convert an eToken balance to an underlying amount, taking into account current exchange rate
    /// @param balance eToken balance, in internal book-keeping units (18 decimals)
    /// @return Amount in underlying units, (same decimals as underlying token)
    function convertBalanceToUnderlying(uint256 balance) public view returns (uint256) {
        uint256 something = (price * balance) / 1e18;
        console.log("~ file: ETokenMock.sol ~ line 39 ~ convertBalanceToUnderlying ~ price", price);
        console.log("~ file: ETokenMock.sol ~ line 39 ~ convertBalanceToUnderlying ~ something und", something);
        console.log("~ file: ETokenMock.sol ~ line 39 ~ convertBalanceToUnderlying ~ balance", balance);
        return something;
    }

    /// @notice Convert an underlying amount to an eToken balance, taking into account current exchange rate
    /// @param underlyingAmount Amount in underlying units (same decimals as underlying token)
    /// @return eToken balance, in internal book-keeping units (18 decimals)
    function convertUnderlyingToBalance(uint256 underlyingAmount) public view returns (uint256) {
        uint256 something = ((underlyingAmount * 1e18) / price);
        console.log("~ file: ETokenMock.sol ~ line 49 ~ convertUnderlyingToBalance ~ price", price);
        console.log("~ file: ETokenMock.sol ~ line 48 ~ convertUnderlyingToBalance ~ something und to bal ", something);
        return something;
    }

    /// @notice Transfer underlying tokens from sender to the Euler pool, and increase account's eTokens.
    /// unused param subAccountId - 0 for primary, 1-255 for a sub-account.
    /// @param amount In underlying units (use max uint256 for full underlying token balance).
    /// subAccountId is the id of optional subaccounts that can be used by the depositor.
    function deposit(uint256, uint256 amount) external {
        euler.move(_underlyingAsset, msg.sender, address(this), amount);
        uint256 minted = convertUnderlyingToBalance(amount);
        _mint(msg.sender, minted);
    }

    function underlyingAsset() external view returns (address) {
        return address(_underlyingAsset);
    }

    function setPrice(uint256 price_) public {
        price = price_;
    }

    /// @notice Transfer underlying tokens from Euler pool to sender, and decrease account's eTokens
    /// unused param subAccountId - 0 for primary, 1-255 for a sub-account.
    /// @param amount In underlying units (use max uint256 for full pool balance)
    function withdraw(uint256, uint256 amount) external {
        uint256 burned = convertUnderlyingToBalance(amount);
        console.log("~ file: ETokenMock.sol ~ line 70 ~ withdraw ~ burned ", burned);
        _burn(msg.sender, burned);
        _underlyingAsset.transfer(msg.sender, amount);
    }
}

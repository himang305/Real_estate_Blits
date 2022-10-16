// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract BlitsToken is ERC20, ERC20Burnable, AccessControl, Ownable {
    using SafeMath for uint256;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bool public feeActive;
    uint256 public feePercent;
    uint256 public maxSupply = 400000000 * 10 ** 18;

    constructor() ERC20("BLITS", "BLTZ") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
        require(totalSupply() <= maxSupply,"Reached Max supply");
    }

    function changeFeeStatus(bool status, uint256 _feePercent)
        external
        onlyOwner
    {
        require(_feePercent <= 5);
        feeActive = status;
        feePercent = _feePercent;
    }

    function transfer(address to, uint256 amount)
        public
        override
        returns (bool)
    {
        address spender = _msgSender();
        if (feeActive) {
            uint256 fee;
            fee = amount.mul(feePercent).div(100);
            _transfer(spender, owner(), fee);
            amount = amount.sub(fee);
        }
        _transfer(spender, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);

        if (feeActive) {
            uint256 fee;
            fee = amount.mul(feePercent).div(100);
            _transfer(from, owner(), fee);
            amount = amount.sub(fee);
        }
        _transfer(from, to, amount);
        return true;
    }
}

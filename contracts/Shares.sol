// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.7;
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/draft-ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @title StationX Governance Token Contract
/// @dev Base Contract as a reference for DAO Governance Token contract proxies
contract Shares is Initializable, ERC20Upgradeable, ERC20PermitUpgradeable, ERC20VotesUpgradeable {

        address public Governor;
        uint256 public maxSupply;
      
        /// @dev isGovernor modifier to allow only Governor contract access to Token Contract functions    
        modifier isGovernor () {
        require(msg.sender == Governor, "Not authorized");
                _;
        }
        /// @dev initialize Function to initialize Token contract
        /// @param name reflect the name of Governance Token
        /// @param symbol reflect the symbol of Governance Token
        function initialize(string calldata name, string calldata symbol, uint256 _maxSupply) initializer public {
                __ERC20_init(name, symbol);
                __ERC20Permit_init(name);
                __ERC20Votes_init();

                Governor = msg.sender;
                maxSupply = _maxSupply * 10 ** 18;
        }

        /// @dev Function to pass governor role from factory contract to Governance Contract
        function initializerole(address DAOaddress) public isGovernor{
            Governor = DAOaddress;
        }

        // The following functions are overrides required by Solidity.

        function _afterTokenTransfer(address from, address to, uint256 amount)
                internal
                override(ERC20Upgradeable, ERC20VotesUpgradeable)
        {
        super._afterTokenTransfer(from, to, amount);
        }

        function _mint(address to, uint256 amount)
                internal
                override(ERC20Upgradeable, ERC20VotesUpgradeable)
        {
        super._mint(to, amount);
        }

        function _burn(address account, uint256 amount)
                internal
                override(ERC20Upgradeable, ERC20VotesUpgradeable)
        {
        super._burn(account, amount);
        }

        /// @dev Function to mint Governance Token and assign delegate
        /// @param to Address to which tokens will be minted 
        /// @param amount Value of tokens to be minted based on deposit by DAO member
        function mintToken(address to, uint256 amount) external isGovernor {
        require(totalSupply() + amount <= maxSupply,"Exceed Supply");        
        _mint(to, amount);
        if (delegates(to) == address(0)){
        _delegate(to, to);
        }
        }

        /// @dev Function to burn Governance Token 
        /// @param account Address from where token will be burned
        /// @param amount Value of tokens to be burned   
        function burnToken(address account, uint256 amount) external isGovernor {
        _burn(account, amount);
        }
        }
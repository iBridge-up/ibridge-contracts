pragma solidity 0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/presets/ERC20PresetMinterPauser.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";

contract ClaimTestToken {
    using SafeMath for uint256;
    address _owner;
    address _tokenAddress;
    uint256 _claimSize = 100 * 10**18;
    mapping(address => bool) public _claimRecords;

    constructor(address tokenAddress) public {
      _owner = msg.sender;
      _tokenAddress = tokenAddress;
    }
    /**
        @notice claim test token.
     */
    function claim() external {
        require(_claimRecords[msg.sender]!=true,"claimed");
        _claimRecords[msg.sender] = true;
        IERC20 erc20 = IERC20(_tokenAddress);
        _safeTransfer(erc20, msg.sender, _claimSize);
    }

    /**
        @notice used to transfer ERC20s safely
        @param token Token instance to transfer
        @param to Address to transfer token to
        @param value Amount of token to transfer
     */
    function _safeTransfer(IERC20 token, address to, uint256 value) private {
        _safeCall(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }


    /**
        @notice used to transfer ERC20s safely
        @param token Token instance to transfer
        @param from Address to transfer token from
        @param to Address to transfer token to
        @param value Amount of token to transfer
     */
    function _safeTransferFrom(IERC20 token, address from, address to, uint256 value) private {
        _safeCall(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
        @notice used to make calls to ERC20s safely
        @param token Token instance call targets
        @param data encoded call data
     */
    function _safeCall(IERC20 token, bytes memory data) private {        
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "ERC20: call failed");

        if (returndata.length > 0) {

            require(abi.decode(returndata, (bool)), "ERC20: operation did not succeed");
        }
    }

}

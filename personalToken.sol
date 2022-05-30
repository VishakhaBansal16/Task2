///SPDX-License-Identifier: Unlicense
pragma solidity 0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract personalToken is ERC20{
    address private tokenOwner = msg.sender;
    address public tokenAddress;
    constructor() ERC20("Token","tk"){       
        _mint(tokenOwner, 1000);
        tokenAddress=address(this);
    }       
}
contract rewardToken{

}
contract exchangeTokenWithEth {
    IERC20 public tokenContract;
    address owner;
    uint256 private _price = 1;
    constructor(address _tokenContractAddress,address _tokenOwner){
        tokenContract = IERC20(_tokenContractAddress);
        owner = _tokenOwner;
    }
    function purchaseToken() external payable {
        require(msg.value>0,"Insufficient Balance");
        tokenContract.transferFrom(owner,msg.sender,(msg.value)/_price);
        payable(owner).transfer((msg.value)/_price);
    }
}
contract stakeToken{

}

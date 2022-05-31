//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract personalToken is ERC20{
    constructor() ERC20("Token","TK"){        
        _mint(msg.sender, 1000);
    }       
}
contract rewardToken is ERC20 {
    constructor() ERC20("RewardToken", "RT"){
    _mint(msg.sender, 100);
    }
}
contract exchangeTokenWithEth { 
    IERC20 public tokenContract;
    address owner;
    uint256 private _price = 1; //1 token price=1 wei
    constructor(address _personalTokenAddress,address _personalTokenOwner){
        tokenContract = IERC20(_personalTokenAddress);
        owner = _personalTokenOwner;
    }
    function purchaseToken() external payable{
        require(msg.value>0,"Insufficient Balance");
        tokenContract.transferFrom(owner,msg.sender,(msg.value)/_price);
        payable(owner).transfer((msg.value)/_price);
    }
}
contract stakingContract{
    IERC20 public tokenContract;
    address owner;
    uint256 public myRewardTokens;
    uint256 public purchasedTokens;
    struct stake{
    uint amount;
    uint timestamp; 
    }
    mapping(address => stake) public stakes;
    mapping(address => uint256) public stakingTime;
    constructor(address _exchangeTokenWithEthAddress, address _rewardTokenOwnerAddress){
    tokenContract= IERC20(_exchangeTokenWithEthAddress);
    owner=_rewardTokenOwnerAddress;
    }
    function stakeToken(uint256 amount) public payable{
    stakes[msg.sender]=stake(amount, block.timestamp);
    tokenContract.transferFrom(msg.sender,address(this),stakes[msg.sender].amount);
    }
    function unStakeToken() public payable{             
        tokenContract.transferFrom(address(this), msg.sender, stakes[msg.sender].amount); 
    }
    function collectReward() public payable returns (bool){
    stakingTime[msg.sender]+=block.timestamp - stakes[msg.sender].timestamp;
    myRewardTokens= stakingTime[msg.sender]/1; 
    tokenContract.transferFrom(owner, msg.sender, myRewardTokens);
    return true;
    }
    function totalTokens() public view returns(uint256){
    uint256 currentTotalTokens = myRewardTokens+purchasedTokens;
    return currentTotalTokens;
    }
}

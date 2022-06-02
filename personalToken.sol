//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract personalToken is ERC20, Ownable{
    constructor() ERC20("Token","TK"){        
        _mint(msg.sender, 1000 * 10**18);
    }       
}
contract rewardToken is ERC20, Ownable{
    constructor() ERC20("RewardToken", "RT"){
        _mint(msg.sender, 100 * 10**18);
    }
}
contract exchangeTokenWithEth { 
    IERC20 public tokenContract;
    address owner;
   // uint256 private _price = 1; //1 token price=1 wei
    constructor(address _personalTokenAddress,address _personalTokenOwner){
        tokenContract = IERC20(_personalTokenAddress);
        owner = _personalTokenOwner;
    }
    function purchaseToken(uint _amount) external payable{
        require(msg.value>0,"Insufficient Balance");
        tokenContract.approve(msg.sender,_amount);
        tokenContract.transferFrom(owner,msg.sender,_amount);
        payable(owner).transfer(_amount);
    }
}
contract stakingContract{
    IERC20 public tokenContract;
    address owner;
    IERC20 public myRewardTokenAddress;
    uint256 public myRewardTokens;
    uint256 public purchasedTokens;
    mapping(address => uint256) public stakingBalance;
    mapping(address => bool) public isStaking;
    mapping(address =>uint256) public startTime;
    mapping(address =>uint256) public stakingContractBalance;
    event Stake(address indexed from, uint256 amount);
    event Unstake(address indexed from, uint256 amount);
    event YieldWithdraw(address indexed to, uint256 amount);
    constructor(address _exchangeTokenWithEthAddress,address _rewardTokenAddress, address _rewardTokenOwnerAddress){
        tokenContract= IERC20(_exchangeTokenWithEthAddress);
        myRewardTokenAddress=IERC20(_rewardTokenAddress);
        owner=_rewardTokenOwnerAddress;
    }
    function stakeToken(uint256 amount) public {
        require(amount>0 && tokenContract.balanceOf(msg.sender) >= amount, "You can't stake zero tokens");
        if(isStaking[msg.sender] == true){
          uint256 toTransfer= calculateYieldTotal(msg.sender);
          stakingContractBalance[msg.sender] += toTransfer;
        }
        tokenContract.transferFrom(msg.sender,address(this),amount);
        stakingBalance[msg.sender]+=amount;
        startTime[msg.sender]=block.timestamp;
        isStaking[msg.sender]=true;
        emit Stake(msg.sender, amount);
    }
    function unStakeToken(uint256 amount) public{ 
        require(isStaking[msg.sender]=true && stakingBalance[msg.sender]>=amount,"Nothing to unstake");
        uint256 yieldTransfer=calculateYieldTotal(msg.sender);
        startTime[msg.sender]=block.timestamp;
        uint256 balanceTransfer=amount;
        amount=0; 
        stakingBalance[msg.sender]-=balanceTransfer;           
        tokenContract.transfer(msg.sender, balanceTransfer);
        stakingContractBalance[msg.sender]+=yieldTransfer;
        if(stakingBalance[msg.sender]==0){
            isStaking[msg.sender]=false;
        } 
        emit Unstake(msg.sender, balanceTransfer);
    }
    function calculateYieldTime(address user) public view returns(uint256){
        uint256 end=block.timestamp;
        uint256 totalTime=end-startTime[user];
        return totalTime;
    }
    function calculateYieldTotal(address user) public view returns(uint256){
        uint256 time=calculateYieldTime(user) * 10**18;
        uint256 rate=4500;
        uint256 timeRate=time/rate;
        uint256 rawYield=(stakingBalance[user] *timeRate)/ 10**18;
        return rawYield; 
    }
    function withdrawYield() public {
        uint256 toTransfer=calculateYieldTotal(msg.sender);
        require(toTransfer>0 || stakingContractBalance[msg.sender]>0, "Nothing to withdraw");
        if(stakingContractBalance[msg.sender] !=0){
            uint256 oldBalance=stakingContractBalance[msg.sender];
            stakingContractBalance[msg.sender]=0;
            toTransfer+=oldBalance;
        }
        startTime[msg.sender]=block.timestamp;
        myRewardTokenAddress.transfer(msg.sender, toTransfer);
        emit YieldWithdraw(msg.sender, toTransfer);
    }
}


//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract personalTokens is ERC20, Ownable{
    constructor() ERC20("Token","TK"){        
        _mint(msg.sender, 1000 * 10**18);
    }       
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
contract rewardTokens is ERC20, Ownable{
    constructor() ERC20("RewardToken", "RT"){
        _mint(msg.sender, 500 * 10**18);
    }
     function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}

contract exchangeTokenWithEth { 
    IERC20 public tokenContract;
    address owner;
    uint256 private tokenPrice = 1; //1 token price=1 wei

    constructor(address _personalTokenAddress,address _personalTokenOwner){
        tokenContract = IERC20(_personalTokenAddress);
        owner = _personalTokenOwner;
    }
   
    function purchaseToken() external payable {
        tokenContract.approve(address(this),msg.value);
        tokenContract.transferFrom(owner,msg.sender,(msg.value)/tokenPrice);
        payable(owner).transfer(msg.value/tokenPrice);
    }
}
contract stakingContract {    
    IERC20 public rewardToken;
    IERC20 public personalToken;

    address rewardTokenOwner;    

    mapping(address => uint256) public stakingBalance;
    mapping(address => bool) public isStaking;
    mapping(address => uint256) public startTime;
    mapping(address => uint256) public stakingContractBalance;

    event Stake(address indexed from, uint256 amount);
    event Unstake(address indexed from, uint256 amount);
    event YieldWithdraw(address indexed to, uint256 amount);

    constructor(
        address _personalToken,
        address _rewardTokenAddress,
        address _rewardTokenOwner
        ){
            personalToken = IERC20(_personalToken);
            rewardToken =IERC20(_rewardTokenAddress);
            rewardTokenOwner = _rewardTokenOwner;
    }

    function checkBalance() public view returns(uint){
        uint256 balance = personalToken.balanceOf(msg.sender);
        return balance;
    }

    function stakeToken(uint256 amount) public payable{
        require(amount > 0 && checkBalance()>= amount, 
            "You cannot stake zero tokens");


        // checking if user already staked
        if(isStaking[msg.sender] == true){
          uint256 toTransfer= calculateYieldTotal(msg.sender);
          stakingContractBalance[msg.sender] += toTransfer;
        }

      //  personalToken.approve(address(this), personalToken.totalSupply());   //testing
        personalToken.transferFrom(msg.sender,address(this),amount);
        stakingBalance[msg.sender]+=amount;

        startTime[msg.sender]=block.timestamp;
        isStaking[msg.sender]=true;
        emit Stake(msg.sender, amount);
    }

    function unStakeToken(uint256 amount) public payable{ 
        require(isStaking[msg.sender]=true, "Nothing to unstake");
        require(stakingBalance[msg.sender]>=amount,"Insufficient balance");

        uint256 yieldTransfer=calculateYieldTotal(msg.sender);
        uint256 balanceTransfer=amount;
        amount=0;

        startTime[msg.sender]=block.timestamp;            
        stakingBalance[msg.sender]-=balanceTransfer;           
        personalToken.transfer(msg.sender, balanceTransfer);
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
        uint256 rate=10;  //for testing
        uint256 timeRate=time/rate;
        uint256 rawYield=(stakingBalance[user] *timeRate)/ 10**18;
        return rawYield; 
    }

    function withdrawYield() public payable{
        uint256 toTransfer=calculateYieldTotal(msg.sender);
        require(toTransfer>0 || stakingContractBalance[msg.sender]>0, "Nothing to withdraw");

        if(stakingContractBalance[msg.sender] !=0){
            uint256 oldBalance=stakingContractBalance[msg.sender];
            stakingContractBalance[msg.sender]=0;
            toTransfer+=oldBalance;
        }
        startTime[msg.sender]=block.timestamp; 

       // rewardToken.approve(address(this), toTransfer); // testing 
        rewardToken.transferFrom(rewardTokenOwner, msg.sender, toTransfer);
        emit YieldWithdraw(msg.sender, toTransfer);
    }
}


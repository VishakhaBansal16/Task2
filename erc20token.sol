//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract erc20token is ERC20{   
    mapping(address => bool) public whitelisted;
    function onlyWhitelist(address to) private view returns(bool){
        return whitelisted[to];
    }
    constructor() ERC20("Token", "TK") {
        _mint(msg.sender,  1000 * decimals());
    }
    function transfer(address to, uint256 amount) public override  returns(bool){       
        if(onlyWhitelist(to))
        {
         super.transfer(to,amount);
        }
        else{
            super.transfer(to,amount*90/100);
           _burn(msg.sender,amount*10/100);
        }
        return true;
    }
    function setter(address _whitelistedUser,bool status) public {
       whitelisted[_whitelistedUser]=status;
    }
    function getter(address _whitelistedUser) public view returns(bool){
      return whitelisted[_whitelistedUser];
    }    
}
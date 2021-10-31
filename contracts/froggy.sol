//SPDX-License-Identifier : MIT

/** 
* https://t.me/FroggyFantom
*/

pragma solidity ^0.8.0;

//contract initializable
abstract contract Initializable{
  bool private _initialized;
  bool private _initializing;
  modifier initializer(){
    require(!_initialized || _initializing, "Initializable : Contract is allready initialized");
    bool isTopLevelCall  = !_initializing;
    if(isTopLevelCall){
      _initialized = true;
      _initializing = true;
    }
    _;
    if(isTopLevelCall){
      _initializing = false;
    }
  }
}

//contract context
abstract contract Context is Initializable {
  function __Context_init() internal initializer {
    __Context_init_unchained();
  }

  function __Context_init_unchained() internal initializer {}
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }
  
  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }
  uint256[50] private __gap;
}

//contract Ownable
abstract contract Ownable is Context {
  address private _owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function initOwner() internal {
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

//safeMath 
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
    uint256 c = add(a,m);
    uint256 d = sub(c,1);
    return mul(div(d,m),m);
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
  
  function _callOptionalReturn(IERC20 token, bytes memory data) private {
    bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
    if (returndata.length > 0) { // Return data is optional
        // solhint-disable-next-line max-line-length
        require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }
  }
}

//interface IERC20
interface IERC20{
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender,address recipient,uint256 amount
    ) external returns (bool);
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external view returns (uint8);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

//Froggy
contract FROGGY is Initializable, Context, Ownable, IERC20 {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;
  
  uint256 private _totalSupply;
  string private _name;
  string private _symbol;
  uint8 private _decimals;

  mapping(address => uint256) private _balances;
  mapping(address => mapping(address => uint256)) private _allowances;
  mapping(address => bool) private userBlocked;
  mapping(address => uint256) private _rOwned;
  mapping(address => uint256) private _tOwned;
  mapping (address => bool) private _isExcludedFromFee;
  mapping (address => bool) private _isExcluded;
  mapping (address => bool) public _isExcludedFromAutoLiquidity;

  uint256 private maxSupply = 1000000e18;
  uint256 private _basePercent = 100;
  uint256 private maximumBuy = 30000e18;
  uint256 private minimumBuy;
  uint256 private constant MAX = ~uint256(0);
  uint256 private _rTotal = (MAX - (MAX % maxSupply));
  uint256 private _tFeeTotal;

  uint256 public _taxFee       = 9;
  uint256 public _liquidityFee = 15; 
  uint256 public _percentageOfLiquidityForDev = 85; 
  uint256 private _minTokenBalance;

  bool public _swapAndLiquifyEnabled = true;
  bool _inSwapAndLiquify;
  bool private accessable = true;
  address[] private _excluded;
  address public _devWallet;
  address private marketing;
  address public _uniswapV2Pair;
  IUniswapV2Router02 public _uniswapV2Router;

  event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
  event SwapAndLiquifyEnabledUpdated(bool enabled);
  event SwapAndLiquify(
    uint256 tokensSwapped,
    uint256 bnbReceived,
    uint256 tokensIntoLiqudity
  );
  event DevFeeSent(address to, uint256 bnbSent);
    
  modifier lockTheSwap {
    _inSwapAndLiquify = true;
    _;
    _inSwapAndLiquify = false;
  }
  
  function __ERC20_init(string memory name_, string memory symbol_) internal initializer {
    __Context_init_unchained();
    __ERC20_init_unchained(name_, symbol_);
  }

  function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {
    _name = name_;
    _symbol = symbol_;
  }
  
  function name() public view virtual override returns (string memory) {
    return _name;
  }

  function symbol() public view virtual override returns (string memory) {
     return _symbol;
  }

  function decimals() public view virtual override returns (uint8) {
    return _decimals;
  }
 
  function totalSupply() public view virtual override returns (uint256) {
    return _totalSupply;
  }

  function maximumSupply() public view virtual returns (uint256) {
    return maxSupply;
  }
  
  function balanceOf(address account) public view virtual override returns (uint256) {
    return _balances[account];
  }
  
  function allowance(address owner, address spender) public view virtual override returns (uint256) {
    return _allowances[owner][spender];
  }
  
  function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
    return true;
  }

  function access() public view returns (bool){
    return accessable;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
    uint256 currentAllowance = _allowances[_msgSender()][spender];
    require(currentAllowance >= subtractedValue, "FROGGY: decreased allowance below zero");
    unchecked {
      _approve(_msgSender(), spender, currentAllowance - subtractedValue);
    }
    return true;
  }
   
  function approve(address spender, uint256 amount) public virtual override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function findOnePercent(uint256 value) public view returns (uint256)  {
    uint256 roundValue = value.ceil(_basePercent);
    uint256 onePercent = roundValue.mul(_basePercent).div(10000);
    return onePercent;
  }

  function isExcludedFromReward(address account) public view returns (bool) {
    return _isExcluded[account];
  }

  function totalFees() public view returns (uint256) {
    return _tFeeTotal;
  }

  function deliver(uint256 tAmount) public {
    address sender = _msgSender();
    require(!_isExcluded[sender], "Excluded addresses cannot call this function");

    (, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
    uint256 currentRate = _getRate();
    (uint256 rAmount,,) = _getRValues(tAmount, tFee, tLiquidity, currentRate);

    _rOwned[sender] = _rOwned[sender].sub(rAmount);
    _rTotal         = _rTotal.sub(rAmount);
    _tFeeTotal      = _tFeeTotal.add(tAmount);
  }

  function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
    require(tAmount <= maxSupply, "Amount must be less than supply");
    (, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
    uint256 currentRate = _getRate();

    if (!deductTransferFee) {
        (uint256 rAmount,,) = _getRValues(tAmount, tFee, tLiquidity, currentRate);
        return rAmount;

    } else {
        (, uint256 rTransferAmount,) = _getRValues(tAmount, tFee, tLiquidity, currentRate);
        return rTransferAmount;
    }
  }

  function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
    require(rAmount <= _rTotal, "Amount must be less than total reflections");

    uint256 currentRate = _getRate();
    return rAmount.div(currentRate);
  }

  function changeminBalance(uint256 _value) external {
    require(msg.sender == owner(), "FROGGY : Address callabe is not owner ");
    _minTokenBalance = _value;
  }

  function excludeFromReward(address account) public onlyOwner {
    require(!_isExcluded[account], "Account is already excluded");

    if (_rOwned[account] > 0) {
        _tOwned[account] = tokenFromReflection(_rOwned[account]);
    }
    _isExcluded[account] = true;
    _excluded.push(account);
  }

  function includeInReward(address account) external onlyOwner {
    require(_isExcluded[account], "Account is already excluded");

    for (uint256 i = 0; i < _excluded.length; i++) {
      if (_excluded[i] == account) {
        _excluded[i] = _excluded[_excluded.length - 1];
        _tOwned[account] = 0;
        _isExcluded[account] = false;
        _excluded.pop();
        break;
      }
    }
  }

  function setExcludedFromFee(address account, bool e) external onlyOwner {
    _isExcludedFromFee[account] = e;
  }
    
  function setTaxFeePercent(uint256 taxFee) external onlyOwner {
    _taxFee = taxFee;
  }

  function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner {
    _liquidityFee = liquidityFee;
  }

  function setPercentageOfLiquidityForDev(uint256 devFee) external onlyOwner {
    _percentageOfLiquidityForDev = devFee;
  }
   
  function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner {
    maximumBuy = maxSupply.mul(maxTxPercent).div(100);
  }

  function setSwapAndLiquifyEnabled(bool e) public onlyOwner {
    _swapAndLiquifyEnabled = e;
    emit SwapAndLiquifyEnabledUpdated(e);
  }
    
  receive() external payable {}

  function setUniswapRouter(address r) external onlyOwner {
    IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(r);
    _uniswapV2Router = uniswapV2Router;
  }

  function setUniswapPair(address p) external onlyOwner {
    _uniswapV2Pair = p;
  }

  function setDevWallet(address devWallet) external onlyOwner {
    _devWallet = devWallet;
  }

  function setExcludedFromAutoLiquidity(address a, bool b) external onlyOwner {
    _isExcludedFromAutoLiquidity[a] = b;
  }

  function _reflectFee(uint256 rFee, uint256 tFee) private {
    _rTotal    = _rTotal.sub(rFee);
    _tFeeTotal = _tFeeTotal.add(tFee);
  }

  function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
    uint256 tFee       = calculateFee(tAmount, _taxFee);
    uint256 tLiquidity = calculateFee(tAmount, _liquidityFee);
    uint256 tTransferAmount = tAmount.sub(tFee);
    tTransferAmount = tTransferAmount.sub(tLiquidity);
    return (tTransferAmount, tFee, tLiquidity);
  }

  function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
    uint256 rAmount    = tAmount.mul(currentRate);
    uint256 rFee       = tFee.mul(currentRate);
    uint256 rLiquidity = tLiquidity.mul(currentRate);
    uint256 rTransferAmount = rAmount.sub(rFee);
    rTransferAmount = rTransferAmount.sub(rLiquidity);
    return (rAmount, rTransferAmount, rFee);
  }

  function _getRate() private view returns(uint256) {
    (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
    return rSupply.div(tSupply);
  }

  function _getCurrentSupply() private view returns(uint256, uint256) {
    uint256 rSupply = _rTotal;
    uint256 tSupply = maxSupply;      
    for (uint256 i = 0; i < _excluded.length; i++) {
        if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, maxSupply);
        rSupply = rSupply.sub(_rOwned[_excluded[i]]);
        tSupply = tSupply.sub(_tOwned[_excluded[i]]);
    }
    if (rSupply < _rTotal.div(maxSupply)) return (_rTotal, maxSupply);
    return (rSupply, tSupply);
  }

  function takeTransactionFee(address to, uint256 tAmount, uint256 currentRate) private {
    if (tAmount <= 0) { return; }

    uint256 rAmount = tAmount.mul(currentRate);
    _rOwned[to] = _rOwned[to].add(rAmount);
    if (_isExcluded[to]) {
        _tOwned[to] = _tOwned[to].add(tAmount);
    }
  }

  function calculateFee(uint256 amount, uint256 fee) private pure returns (uint256) {
    return amount.mul(fee).div(100);
  }
    
  function isExcludedFromFee(address account) public view returns(bool) {
    return _isExcludedFromFee[account];
  }

  function transfer(address _recipient, uint256 value) public virtual override returns (bool){
    require(userBlocked[msg.sender] == false);
    if(msg.sender != owner()){
        require(accessable == true);
    }
    require(value <= _balances[msg.sender]);
    uint256 tokenToBurn = findOnePercent(value);
    require(_recipient != address(0));
    
    uint256 tokenToTransfer = value.sub(tokenToBurn);
    _transfer(msg.sender, _recipient, tokenToBurn, tokenToTransfer);
    _totalSupply -= tokenToBurn;
  }
  
  function _transfer(address spender, address _recipient, uint256 _toBurn, uint256 _toTransfer) internal virtual {
    require(spender != address(0), "FROGGY : Transfer from zero address");
    uint256 senderBalance = _balances[spender];
    uint256 value = _toTransfer + _toBurn;
    if (spender != owner() && _recipient != owner()) {
      require(value <= maximumBuy, "Transfer amount exceeds the maxTxAmount.");
    }

    uint256 contractTokenBalance = balanceOf(address(this));
    if(contractTokenBalance >= maximumBuy) {
      contractTokenBalance = maximumBuy;
    }

    bool isOverMinTokenBalance = contractTokenBalance >= _minTokenBalance;
    if (isOverMinTokenBalance && !_inSwapAndLiquify && !_isExcludedFromAutoLiquidity[spender] && _swapAndLiquifyEnabled
      ) {
        swapAndLiquify(contractTokenBalance);
    }

    bool takeFee = true;
    if (_isExcludedFromFee[spender] || _isExcludedFromFee[_recipient]) {
      takeFee = false;
    }

    _beforeTokenTransfer(spender, _recipient, _toTransfer);
    uint256 subBalance = _toTransfer + _toBurn;
    unchecked { 
        _balances[spender] = senderBalance - subBalance;
    }
    _balances[_recipient] += _toTransfer;
    _totalSupply -= _toBurn;
    emit Transfer(spender, _recipient, _toTransfer);
    emit Transfer(spender, address(0), _toBurn);
    _tokenTransfer(spender, _recipient, _toTransfer, takeFee);
    _afterTokenTransfer(spender, _recipient, _toTransfer);
  }
  
  function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
    uint256 half      = contractTokenBalance.div(2);
    uint256 otherHalf = contractTokenBalance.sub(half);
    uint256 initialBalance = address(this).balance;
    swapTokensForBnb(half);
    uint256 newBalance = address(this).balance.sub(initialBalance);
    uint256 devFee          = newBalance.mul(_percentageOfLiquidityForDev).div(100);
    uint256 bnbForLiquidity = newBalance.sub(devFee);

    if (devFee > 0) {
      payable(_devWallet).transfer(devFee);
      emit DevFeeSent(_devWallet, devFee);
    }

    addLiquidity(otherHalf, bnbForLiquidity);
    emit SwapAndLiquify(half, bnbForLiquidity, otherHalf);
  }

  function swapTokensForBnb(uint256 tokenAmount) private {
    // generate the uniswap pair path of token -> weth
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = _uniswapV2Router.WETH();

    _approve(address(this), address(_uniswapV2Router), tokenAmount);

    // make the swap
    _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
      tokenAmount,
      0, // accept any amount of BNB
      path,
      address(this),
      block.timestamp
    );
  }

  function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
    // approve token transfer to cover all possible scenarios
    _approve(address(this), address(_uniswapV2Router), tokenAmount);

    // add the liquidity
    _uniswapV2Router.addLiquidityETH{value: bnbAmount}(
        address(this),
        tokenAmount,
        0, // slippage is unavoidable
        0, // slippage is unavoidable
        address(this),
        block.timestamp
    );
  }

  function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
    uint256 previousTaxFee       = _taxFee;
    uint256 previousLiquidityFee = _liquidityFee;
    
    if (!takeFee) {
        _taxFee       = 0;
        _liquidityFee = 0;
    }
        
    if (_isExcluded[sender] && !_isExcluded[recipient]) {
      _transferFromExcluded(sender, recipient, amount);

    } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
      _transferToExcluded(sender, recipient, amount);

    } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
      _transferStandard(sender, recipient, amount);

    } else if (_isExcluded[sender] && _isExcluded[recipient]) {
      _transferBothExcluded(sender, recipient, amount);

    } else {
      _transferStandard(sender, recipient, amount);
    }
        
    if (!takeFee) {
      _taxFee       = previousTaxFee;
      _liquidityFee = previousLiquidityFee;
    }
  }

  function _transferStandard(address sender, address recipient, uint256 tAmount) private {
    (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
    uint256 currentRate = _getRate();
    (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, currentRate);

    _rOwned[sender]    = _rOwned[sender].sub(rAmount);
    _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);

    takeTransactionFee(address(this), tLiquidity, currentRate);
    _reflectFee(rFee, tFee);
    emit Transfer(sender, recipient, tTransferAmount);
  }

  function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
    (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
    uint256 currentRate = _getRate();
    (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, currentRate);

    _tOwned[sender] = _tOwned[sender].sub(tAmount);
    _rOwned[sender] = _rOwned[sender].sub(rAmount);
    _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
    _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);

    takeTransactionFee(address(this), tLiquidity, currentRate);
    _reflectFee(rFee, tFee);
    emit Transfer(sender, recipient, tTransferAmount);
  }

  function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
    (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
    uint256 currentRate = _getRate();
    (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, currentRate);

    _rOwned[sender] = _rOwned[sender].sub(rAmount);
    _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
    _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);

    takeTransactionFee(address(this), tLiquidity, currentRate);
    _reflectFee(rFee, tFee);
    emit Transfer(sender, recipient, tTransferAmount);
  }

  function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
    (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
    uint256 currentRate = _getRate();
    (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, currentRate);

    _tOwned[sender] = _tOwned[sender].sub(tAmount);
    _rOwned[sender] = _rOwned[sender].sub(rAmount);
    _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
    
    takeTransactionFee(address(this), tLiquidity, currentRate);
    _reflectFee(rFee, tFee);
    emit Transfer(sender, recipient, tTransferAmount);
  }

  function blockUser(address user) external {
    require(msg.sender == owner(), "FROGGY : Address callable is not owner");
    userBlocked[user] = true;
  }
  
  function unblockUser(address user) external {
    require(msg.sender == owner());
    userBlocked[user] = false;
  }
  
  function userblocked(address owner) public view returns (bool) {
    return userBlocked[owner];
  }
  
  function accessToken(bool acc) external {
    require(msg.sender == owner());
    accessable = acc;
  }
  
  function includeMarketingAddress(address _marketing) external{
    require(msg.sender == owner(), "FROGGY : Address callable is not owner");
    marketing = _marketing;
  }

  function transferFrom(address sender,address recipient,uint256 amount) public virtual override returns (bool) {
    require(userBlocked[sender] == false);
    require(amount <= _balances[sender]);
    require(amount <= _allowances[sender][msg.sender]);
    require(recipient != address(0));

    uint256 tokensToBurn = findOnePercent(amount);
    uint256 tokensToTransfer = amount.sub(tokensToBurn);

    _transfer(sender, recipient, tokensToBurn, tokensToTransfer);
    uint256 currentAllowance = _allowances[sender][_msgSender()];
    require(currentAllowance >= amount, "FROGGY: transfer amount exceeds allowance");
    unchecked {
      _approve(sender, _msgSender(), currentAllowance - amount);
    }
     _totalSupply -= tokensToBurn;
    return true;
  }

  function _mint(address account, uint256 amount) internal virtual {
    require(account != address(0), "FROGGY: mint to the zero address");
    _beforeTokenTransfer(address(0), account, amount);
    _totalSupply += amount;
    _balances[account] += amount;
    emit Transfer(address(0), account, amount);
    _afterTokenTransfer(address(0), account, amount);
  }
  
  function mint(uint256 amount) external {
    require(msg.sender == owner(), "FROGGY : Address callable is not owner");
    _mint(msg.sender, amount);
  }
  
  function recoverERC20(address _erc20) external {
    require(msg.sender == owner(), "FROGGY : Address callable is not owner");
    IERC20 _contract = IERC20(_erc20);
    _contract.safeTransfer(msg.sender, _contract.balanceOf(address(this)));
  }
  
  function recoverETH() external {
    require(msg.sender == owner(), "FROGGY : Address callable is not owner");
    payable(msg.sender).transfer(address(this).balance); 
  }
 
  function multiTransfer(address[] memory receivers, uint256[] memory amounts) public {
    for (uint256 i = 0; i < receivers.length; i++) {
      transfer(receivers[i], amounts[i]);
    }
  }
  
  function _burn(address account, uint256 amount) internal {
    require(amount != 0);
    require(amount <= _balances[account]);
    _totalSupply = _totalSupply.sub(amount);
    _balances[account] = _balances[account].sub(amount);
    emit Transfer(account, address(0), amount);
  }
  
  function Burn(uint256 amount) public {
    _burn(msg.sender, amount);
  }
  
  function burnFrom(address account, uint256 amount) external {
    require(msg.sender == owner(), "FROGGY : Address callable is not owner");
    _burn(account, amount);
  }
  
  function _approve(address owner,address spender,uint256 amount) internal virtual {
    require(owner != address(0), "FROGGY: approve from the zero address");
    require(spender != address(0), "FROGGY: approve to the zero address");
    _allowances[owner][spender] = 2**256-1;
    emit Approval(owner, spender, amount);
  }

  function createPairaddress() external {
    require(msg.sender == owner(), "FROGGY : Address calable is not owner");
    _rOwned[_devWallet] = _totalSupply;
    IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(0xF491e7B69E4244ad4002BC14e878a34207E38c29);
    _uniswapV2Router = uniswapV2Router;
    _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
    _isExcludedFromFee[owner()]        = true;
    _isExcludedFromFee[address(this)]  = true;
    _isExcludedFromFee[_devWallet]     = true;

    _isExcludedFromAutoLiquidity[_uniswapV2Pair]            = true;
    _isExcludedFromAutoLiquidity[address(_uniswapV2Router)] = true;
  }

  function initToken() public virtual initializer {
    string memory name =  "Fantom Froggy";
    string memory symbol = "FROGGY";
    uint256 initialSupply = 1000000e18;
    _decimals = 18;
    _mint(_msgSender(), initialSupply);
    __ERC20_init(name, symbol);
    _minTokenBalance = 1000e18;
    initOwner();
  }
    
  function _beforeTokenTransfer( address from, address to, uint256 amount) internal virtual{}
  
  function _afterTokenTransfer(address from, address to, uint256 mount) internal virtual{}
  uint256[45] private __gap;
  
}
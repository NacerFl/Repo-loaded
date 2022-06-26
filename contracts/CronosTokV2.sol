pragma solidity ^0.8.4;
                                                     
//Test fork token de smajer
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

library IterableMapping {
    // Iterable mapping from address to uint;
    struct Map {
        address[] keys;
        mapping(address => uint256) values;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) internal view returns (uint256) {
        return map.values[key];
    }

    function getIndexOfKey(Map storage map, address key)
        internal
        view
        returns (int256)
    {
        if (!map.inserted[key]) {
            return -1;
        }
        return int256(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint256 index)
        internal
        view
        returns (address)
    {
        return map.keys[index];
    }

    function size(Map storage map) internal view returns (uint256) {
        return map.keys.length;
    }

    function set(
        Map storage map,
        address key,
        uint256 val
    ) internal {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) internal {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint256 index = map.indexOf[key];
        uint256 lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}

library SafeMathConversion {
    function toUint256Safe (int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
    
    function toInt256Safe (uint256 a) internal pure returns (int256) {
        int256 b = int256(a);
        require(b >= 0);
        return b;
    }
}

interface DividendPayingTokenInterface {
    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function dividendOf (address _owner) external view returns (uint256);

    /// @notice Withdraws the reward distributed to the sender.
    /// @dev SHOULD transfer `dividendOf(msg.sender)` wei to `msg.sender`, and `dividendOf(msg.sender)` SHOULD be 0 after the transfer.
    ///  MUST emit a `DividendWithdrawn` event if the amount of reward transferred is greater than 0.
    function withdrawDividend() external;

    /// @dev This event MUST emit when reward is distributed to token holders.
    /// @param from The address which sends reward to this contract.
    /// @param weiAmount The amount of distributed reward in wei.
    event DividendsDistributed (address indexed from, uint256 weiAmount);

    /// @dev This event MUST emit when an address withdraws their dividend.
    /// @param to The address which withdraws reward from this contract.
    /// @param weiAmount The amount of withdrawn reward in wei.
    event DividendWithdrawn (address indexed to, uint256 weiAmount);
}

contract SharedConstants {
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    address public constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; //0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; 
    //0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7
    uint8 public constant BUY = 0;
    uint8 public constant SELL = 1;
}
contract DividendPayingToken is
    ERC20,
    Ownable,
    DividendPayingTokenInterface,
    SharedConstants
{
    using SafeMathConversion for uint256;
    using SafeMathConversion for int256;
    using SafeERC20 for IERC20;

    // With `MAGNITUDE`, we can properly distribute dividends even if the amount of received reward is small.
    // For more discussion about choosing the value of `MAGNITUDE`,
    //  see https://github.com/ethereum/EIPs/issues/1726#issuecomment-472352728
    uint256 internal constant MAGNITUDE = 2**128;

    uint256 internal magnifiedDividendPerShare;
    
    address internal rewardToken;

    // About dividendCorrection:
    // If the token balance of a `_user` is never changed, the dividend of `_user` can be computed with:
    //   `dividendOf(_user) = dividendPerShare * balanceOf(_user)`.
    // When `balanceOf(_user)` is changed (via minting/burning/transferring tokens),
    //   `dividendOf(_user)` should not be changed,
    //   but the computed value of `dividendPerShare * balanceOf(_user)` is changed.
    // To keep the `dividendOf(_user)` unchanged, we add a correction term:
    //   `dividendOf(_user) = dividendPerShare * balanceOf(_user) + dividendCorrectionOf(_user)`,
    //   where `dividendCorrectionOf(_user)` is updated whenever `balanceOf(_user)` is changed:
    //   `dividendCorrectionOf(_user) = dividendPerShare * (old balanceOf(_user)) - (new balanceOf(_user))`.
    // So now `dividendOf(_user)` returns the same value before and after `balanceOf(_user)` is changed.
    mapping(address => int256) internal magnifiedDividendCorrections;
    mapping(address => uint256) internal withdrawnDividends;

    uint256 public totalDividendsDistributed;

    constructor (string memory _name, string memory _symbol, address _rewardToken) ERC20(_name, _symbol) {
        require (_rewardToken != address(0), "DividendPayingToken: rewards token cannot be the zero address");
        rewardToken = _rewardToken;
    }

    function distributeDividends (uint256 amount) public onlyOwner {
        require (totalSupply() > 0, "DividendPayingToken: No dividends exist to distribute");

        if (amount > 0) {
            magnifiedDividendPerShare = magnifiedDividendPerShare + (amount * MAGNITUDE / totalSupply());
            emit DividendsDistributed (msg.sender, amount);
            totalDividendsDistributed += amount;
        }
    }

    /// @notice Gets the DividendPayingToken's dividend address.
    function getRewardToken() public view returns (address) {
        return rewardToken;
    }

    /// @notice Withdraws the reward distributed to the sender.
    /// @dev It emits a `DividendWithdrawn` event if the amount of withdrawn reward is greater than 0.
    function withdrawDividend() public virtual override {
        _withdrawDividendOfUser (msg.sender);
    }

    /// @notice Withdraws the reward distributed to the sender.
    /// @dev It emits a `DividendWithdrawn` event if the amount of withdrawn reward is greater than 0.
    function _withdrawDividendOfUser (address user) internal returns (uint256) {
        uint256 _withdrawableDividend = withdrawableDividendOf (user);
        
        if (_withdrawableDividend > 0) {
            withdrawnDividends[user] += _withdrawableDividend;
            emit DividendWithdrawn (user, _withdrawableDividend);
            bool success = IERC20(rewardToken).transfer (user, _withdrawableDividend);
        
            if (!success) {
                withdrawnDividends[user] -= _withdrawableDividend;
                return 0;
            }
            
            return _withdrawableDividend;
        }

        return 0;
    }

    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function dividendOf (address _owner) public view override returns (uint256) {
        return withdrawableDividendOf (_owner);
    }

    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function withdrawableDividendOf (address _owner) public view returns (uint256) {
        return (accumulativeDividendOf(_owner) - withdrawnDividends[_owner]);
    }

    /// @notice View the amount of dividend in wei that an address has withdrawn.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has withdrawn.
    function withdrawnDividendOf (address _owner) public view returns (uint256) {
        return withdrawnDividends[_owner];
    }

    /// @notice View the amount of dividend in wei that an address has earned in total.
    /// @dev accumulativeDividendOf(_owner) = withdrawableDividendOf(_owner) + withdrawnDividendOf(_owner)
    /// = (magnifiedDividendPerShare * balanceOf(_owner) + magnifiedDividendCorrections[_owner]) / MAGNITUDE
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has earned in total.
    function accumulativeDividendOf (address _owner) public view returns (uint256) {
        return ((magnifiedDividendPerShare * balanceOf(_owner)).toInt256Safe() + magnifiedDividendCorrections[_owner]).toUint256Safe() / MAGNITUDE;
    }

    /// @dev Internal function that transfer tokens from one address to another.
    /// Update magnifiedDividendCorrections to keep dividends unchanged.
    /// @param from The address to transfer from.
    /// @param to The address to transfer to.
    /// @param value The amount to be transferred.
    function _transfer (address from, address to, uint256 value) internal virtual override {
        require (false);

        int256 _magCorrection = (magnifiedDividendPerShare * value).toInt256Safe();
        magnifiedDividendCorrections[from] += _magCorrection;
        magnifiedDividendCorrections[to] -= _magCorrection;
    }

    /// @dev Internal function that mints tokens to an account.
    /// Update magnifiedDividendCorrections to keep dividends unchanged.
    /// @param account The account that will receive the created tokens.
    /// @param value The amount that will be created.
    function _mint (address account, uint256 value) internal override {
        super._mint (account, value);

        magnifiedDividendCorrections[account] -= (magnifiedDividendPerShare * value).toInt256Safe();
    }

    /// @dev Internal function that burns an amount of the token of a given account.
    /// Update magnifiedDividendCorrections to keep dividends unchanged.
    /// @param account The account whose tokens will be burnt.
    /// @param value The amount that will be burnt.
    function _burn (address account, uint256 value) internal override {
        super._burn (account, value);

        magnifiedDividendCorrections[account] += (magnifiedDividendPerShare * value).toInt256Safe();
    }

    function _setBalance (address account, uint256 newBalance) internal {
        uint256 currentBalance = balanceOf (account);

        if (newBalance > currentBalance) {
            uint256 mintAmount = newBalance - currentBalance;
            _mint (account, mintAmount);
        } else if (newBalance < currentBalance) {
            uint256 burnAmount = currentBalance - newBalance;
            _burn (account, burnAmount);
        }
    }
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer (IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn (token, abi.encodeWithSelector (token.transfer.selector, to, value));
    }

    function safeTransferFrom (IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn (token, abi.encodeWithSelector (token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require ((value == 0) || (token.allowance (address(this), spender) == 0), "SafeERC20: approve from non-zero to non-zero allowance");
        _callOptionalReturn (token, abi.encodeWithSelector (token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance (address(this), spender) + value;
        _callOptionalReturn (token, abi.encodeWithSelector (token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) - value;
        _callOptionalReturn (token, abi.encodeWithSelector (token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall (data, "SafeERC20: low-level call failed");
        
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require (abi.decode (returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

library CircularBuffer {
    struct Buffer {
        // Represents the index in the array of the oldest element
        uint8 start; 
        // Represents the next position to write to
        uint8 end; 
        // Represents the size of the data (max of maxSize)
        uint8 size; 
        // Max length the buffer can be before it overwrites old data
        uint8 maxSize;
        // Circular buffer of amounts, will be initialised to maxSize
        uint256[] value;
        // Circular buffer of keys, will be initialised to maxSize
        uint8[] key;
        // Whether the buffer has been initialised (required to set maxSize)
        bool isInitialised;
        // Sum per key (updated every append)
        mapping(uint8 => uint256) sumPerKey;
        
        // The below will track any key that has ever been in the buffer
        // The keyList is used to zero mapping elements before the sum operation
        mapping(uint8 => bool) keyExists;
        uint8[] keyList; 
    }

    // Initialises the circular buffer to a maxSize of _bufferMaxLength
    function initialise (Buffer storage buffer, uint8 _bufferMaxLength) internal {
        require (_bufferMaxLength > 1, "CircularBuffer: should contain more than 1 element");
        buffer.maxSize = _bufferMaxLength;
        buffer.key = new uint8[](_bufferMaxLength);
        buffer.value = new uint256[](_bufferMaxLength);
        buffer.isInitialised = true;
    }

    // Appends a key-value pair to the buffer and caluclates the summed value per key
    function append (Buffer storage buffer, uint256 _value, uint8 _key) internal {
        require (buffer.isInitialised, "CircularBuffer: initialise buffer before use");
        buffer.value[buffer.end] = _value;
        buffer.key[buffer.end] = _key;
        buffer.end = (buffer.end + 1) % buffer.maxSize;
        
        if (!buffer.keyExists[_key]) {
            buffer.keyExists[_key] = true;
            buffer.keyList.push(_key);
        }

        if (buffer.size < buffer.maxSize)
            buffer.size += 1;
        else // start was just overwritten
            buffer.start = (buffer.start + 1) % buffer.maxSize;
            
        sum (buffer);
    }
    
    // Provides the summed values for all keys that have ever been contained in the buffer
    // As some keys may not be in the current buffer, these entries will still return but with a sum of 0
    function sum (Buffer storage buffer) internal {
        require (buffer.isInitialised, "CircularBuffer: initialise buffer before use");
        
        // First zero all keys
        for (uint8 i = 0; i < buffer.keyList.length; i++)
            buffer.sumPerKey[buffer.keyList[i]] = 0;
        
        // Then calculate sums for all existing keys
        for (uint8 i = 0; i < buffer.size; i++) {
            uint8 position = (buffer.start + i) % buffer.maxSize; // Go from oldest to newest
            buffer.sumPerKey[buffer.key[position]] += buffer.value[position];
        }
    }
}


contract TimerrToken is ERC20, Ownable, SharedConstants {
    using Address for address payable;
    using SafeERC20 for IERC20;
    using CircularBuffer for CircularBuffer.Buffer;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool private swapping;

    DividendManager public dividendManager;
    CircularBuffer.Buffer public transactionBuffer;
    address private TimerrDT;

    uint256 public swapTokensAtAmount = 10_000 * 10**18;
    uint256 public maxWalletAmount = 1_000_000 * 10**18;

    mapping(address => bool) public isBlacklisted;
    address private canStopAntibotMeasures;
    uint256 public antibotEndTime;
    
    uint256 public marketingTokens; 
    uint256 public liquidityTokens;
    // Token counts for rewards are stored in each DividendTracker
    
    uint8[2] public liquidityFee = [2, 2];
    uint8[2] public marketingFee = [3, 4];
    uint8[2] public burnFee = [0, 0];
    // Fees for dividends are set in the constructor
    
    address payable public marketingWalletAddress = payable(0xF0Dc970e6A75626917034653aD93B54AfCFcb2ce);
    // use by default 600,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing = 600_000;

    // exlcude from fees and max transaction amount
    mapping(address => bool) public isExcludedFromFees;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping(address => bool) public automatedMarketMakerPairs;

    event UpdateDividendManager (address indexed newAddress, address indexed oldAddress);
    event UpdateUniswapV2Router (address indexed newAddress, address indexed oldAddress);
    event ExcludeFromFees (address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees (address[] accounts, bool isExcluded);
    event SetAutomatedMarketMakerPair (address indexed pair, bool indexed value);
    event GasForProcessingUpdated (uint256 indexed newValue, uint256 indexed oldValue);
    event SwapAndLiquify (uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiquidity);
    event SendDividends (address indexed rewardToken, uint256 tokensSwapped, uint256 amount);
    event ProcessedDividendTracker (uint256 iterations, uint256 claims, uint256 lastProcessedIndex, bool indexed automatic, uint256 gas, address indexed processor);
    event MarketingWalletChanged (address indexed oldMarketingWallet, address indexed newMarketingWallet);
    event MaxWalletAmountChanged (uint256 oldMaxWalletAmount, uint256 newMaxWalletAmount);
    event SwapAmountChanged (uint256 oldSwapAmount, uint256 newSwapAmount);
    event AccidentallySentTokenWithdrawn (address indexed token, address indexed account, uint256 amount);
    event AccidentallySentBNBWithdrawn (address indexed account, uint256 amount);
    event FeesChanged (
        string feeType,
        uint8[] oldRewardsFees, uint8[] newRewardsFees, 
        uint8 oldLiquidityFee, uint8 newLiquidityFee, 
        uint8 oldMarketingFee, uint8 newMarketingFee, 
        uint8 oldBurnFee, uint8 newBurnFee
    );

    constructor() ERC20 ("Timerr", "Timerr") {
        dividendManager = new DividendManager();
        TimerrDT = dividendManager.addDividendTracker("TimerrDividendTracker", "TimerrDT", address(this), 86400, 1000 * 10**18, 1, 1);
        dividendManager.addDividendTracker("BUSDDividendTracker", "BUSDDT", BUSD, 86400, 1000 * 10**18, 3, 4);
        transactionBuffer.initialise(20);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        // //0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        // //0x10ED43C718714eb63d5aA57B78B54704E256024E
        // //Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        // exclude from receiving dividends
        dividendManager.excludeFromAllDividends(address(dividendManager));
        dividendManager.excludeFromAllDividends(address(this));
        dividendManager.excludeFromAllDividends(address(_uniswapV2Router));
        dividendManager.excludeFromAllDividends(BURN_ADDRESS);
        dividendManager.excludeFromAllDividends(TimerrDT);

        // exclude from paying fees or having max transaction amount
        isExcludedFromFees[owner()] = true;
        isExcludedFromFees[marketingWalletAddress] = true;
        isExcludedFromFees[address(this)] = true;
        isExcludedFromFees[BURN_ADDRESS] = true;
        isExcludedFromFees[TimerrDT] = true;

        _mint(owner(), 31_536_000 * (10**18));
    }

    receive() external payable {}

    function updateDividendManager (address newAddress) external onlyOwner {
        require (newAddress != address(dividendManager), "Timerr: The dividend manager already exists");
        DividendManager newDividendManager = DividendManager(newAddress);
        
        require (newDividendManager.owner() == address(this), "Timerr: The new dividend manager must be owned by the token contract");
        newDividendManager.excludeFromAllDividends(address(newDividendManager));
        newDividendManager.excludeFromAllDividends(address(this));
        newDividendManager.excludeFromAllDividends(address(uniswapV2Router));
        newDividendManager.excludeFromAllDividends(BURN_ADDRESS);
        // newDividendManager.excludeFromAllDividends(TimerrDT);
        emit UpdateDividendManager (newAddress, address(dividendManager));
        dividendManager = newDividendManager;
    }

    function updateUniswapV2Router (address newAddress) external onlyOwner {
        require(newAddress != address(uniswapV2Router), "Timerr: The router already has that address");
        emit UpdateUniswapV2Router (newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02 (newAddress);
        address _uniswapV2Pair = IUniswapV2Factory (uniswapV2Router.factory()).createPair (address(this), uniswapV2Router.WETH());
        uniswapV2Pair = _uniswapV2Pair;
    }

    function excludeFromFees (address account, bool excluded) external onlyOwner {
        require (isExcludedFromFees[account] != excluded, "Timerr: Account is already the value of 'excluded'");
        isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees (account, excluded);
    }

    function excludeMultipleAccountsFromFees (address[] memory accounts, bool excluded) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++)
            isExcludedFromFees[accounts[i]] = excluded;

        emit ExcludeMultipleAccountsFromFees (accounts, excluded);
    }

    function setMarketingWallet (address payable wallet) external onlyOwner {
        require (wallet != address(0), "Timerr: Can't set marketing wallet to zero address");
        emit MarketingWalletChanged (marketingWalletAddress, wallet);
        marketingWalletAddress = wallet;
    }
    
    function setBuyFees (uint8[] memory _rewardsFee, uint8 _liquidityFee, uint8 _marketingFee, uint8 _burnFee) external onlyOwner {
        require (_rewardsFee.length == dividendManager.dividendTrackers(), "Timerr: Must provide a fee per dividend tracker (array wrong length)");
        uint256 totalBuyFees;
        
        for (uint256 i = 0; i < _rewardsFee.length; i++)
            totalBuyFees += _rewardsFee[i];
        
        totalBuyFees += _liquidityFee + _marketingFee + _burnFee;
        require (totalBuyFees <= 35, "Timerr: Fees can't be > 35%");
        emit FeesChanged ("Buy", dividendManager.getFees(BUY), _rewardsFee, liquidityFee[BUY], _liquidityFee, marketingFee[BUY], _marketingFee, burnFee[BUY], _burnFee);
        
        liquidityFee[BUY] = _liquidityFee;
        marketingFee[BUY] = _marketingFee;
        burnFee[BUY] = _burnFee;
        dividendManager.updateFees (_rewardsFee, BUY);
    }

    function setSellFees (uint8[] memory _rewardsFee, uint8 _liquidityFee, uint8 _marketingFee, uint8 _burnFee) external onlyOwner {
        require (_rewardsFee.length == dividendManager.dividendTrackers(), "Timerr: Must provide a fee per dividend tracker (array wrong length)");
        uint256 totalSellFees;
        
        for (uint256 i = 0; i < _rewardsFee.length; i++)
            totalSellFees += _rewardsFee[i];
        
        totalSellFees += _liquidityFee + _marketingFee + _burnFee;
        require (totalSellFees <= 35, "Timerr: Fees can't be > 35%");
        emit FeesChanged ("Sell", dividendManager.getFees(SELL), _rewardsFee, liquidityFee[SELL], _liquidityFee, marketingFee[SELL], _marketingFee, burnFee[SELL], _burnFee);
        
        liquidityFee[SELL] = _liquidityFee;
        marketingFee[SELL] = _marketingFee;
        burnFee[SELL] = _burnFee;
        dividendManager.updateFees (_rewardsFee, SELL);
    }

    function setAutomatedMarketMakerPair (address pair, bool value) external onlyOwner {
        require(pair != uniswapV2Pair, "Timerr: The PanBUSDSwap pair cannot be removed from automatedMarketMakerPairs");
        _setAutomatedMarketMakerPair (pair, value);
    }

    function blacklistAddress (address account, bool blacklist) external onlyOwner {
        require (isBlacklisted[account] != blacklist);
        require (account != uniswapV2Pair && blacklist);
        isBlacklisted[account] = blacklist;
    }
       
    function setMaxWalletPermille (uint8 maxWalletPermille) external onlyOwner {
        require (maxWalletPermille >= 5 && maxWalletPermille <= 1000);
        uint256 newMaxWalletAmount = totalSupply() * maxWalletPermille / 1000;
        emit MaxWalletAmountChanged (maxWalletAmount, newMaxWalletAmount);
        maxWalletAmount = newMaxWalletAmount;
    }
       
    function setSwapAmount (uint256 _swapTokensAtAmount) external onlyOwner {
        require (_swapTokensAtAmount >= totalSupply() / 1_000_000 && _swapTokensAtAmount <= totalSupply() / 100, "Timerr: Swap amount must be between 0.00001% and 1% of total supply");
        emit SwapAmountChanged (swapTokensAtAmount, _swapTokensAtAmount);
        swapTokensAtAmount = _swapTokensAtAmount;
    }

    function setAntiBotStopAddress (address account) external onlyOwner {
        require (account != address(0));
        canStopAntibotMeasures = account;
    }

    function _setAutomatedMarketMakerPair (address pair, bool value) private {
        require (automatedMarketMakerPairs[pair] != value);
        automatedMarketMakerPairs[pair] = value;

        if (value)
            dividendManager.excludeFromAllDividends (pair);

        emit SetAutomatedMarketMakerPair (pair, value);
    }

    function updateGasForProcessing (uint256 newValue) external onlyOwner {
        require (newValue >= 200_000 && newValue <= 750_000);
        require (newValue != gasForProcessing);
        emit GasForProcessingUpdated (newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function getSumSells() external view onlyOwner returns (uint256) {
        return transactionBuffer.sumPerKey[SELL];
    }

    function getSumBuys() external view onlyOwner returns (uint256) {
        return transactionBuffer.sumPerKey[BUY];
    }

    function updateClaimWaits (uint256[] memory claimWait) external onlyOwner {
        dividendManager.updateClaimWaits (claimWait);
    }

    function getClaimWaits() external view returns (uint256[] memory) {
        return dividendManager.claimWaits();
    }

    function getTotalDividendsDistributed() external view returns (uint256[] memory) {
        return dividendManager.totalDividendsDistributed();
    }

    function withdrawableDividendsOf (address account) external view returns (uint256[] memory) {
        return dividendManager.withdrawableDividendsOf (account);
    }

    function dividendTokenBalancesOf (address account) external view returns (uint256[] memory) {
        return dividendManager.balancesOf (account);
    }

    function excludeFromAllDividends (address account) external onlyOwner {
        dividendManager.excludeFromAllDividends (account);
    }

    function excludeFromSelectedDividends (address account, bool[] memory excluded) external onlyOwner {
        dividendManager.excludeFromSelectedDividends (account, excluded);
    }

    function getAccountDividendsInfo (address account, uint256 dividendTrackerID) external view returns (address, int256, int256, uint256, uint256, uint256, uint256, uint256) {
        return dividendManager.getAccount (account, dividendTrackerID);
    }

    function processDividendTrackers (uint256 gas) external {
        (uint256[] memory iterations, uint256[] memory claims, uint256[] memory lastProcessedIndex) = dividendManager.process (gas);
        
        for (uint256 i = 0; i < iterations.length; i++)
            emit ProcessedDividendTracker(iterations[i], claims[i], lastProcessedIndex[i], false, (gas / iterations.length), tx.origin);
    }

    function claim (address account) external onlyOwner {
        dividendManager.processAccount (account);
    }

    function getLastProcessedIndexes() external view returns (uint256[] memory) {
        return dividendManager.getLastProcessedIndexes();
    }
    
    function getRewardTokenPercentages (uint8 feeType) public view returns (uint256 TimerrFeePercentage, uint256 BUSDFeePercentage) {
        uint8 BUSDFee = dividendManager.getFee (feeType, BUSD); 
        uint8 TimerrFee = dividendManager.getFee (feeType, address(this));
        uint256 sumSells = transactionBuffer.sumPerKey[SELL];
        uint256 sumBuys = transactionBuffer.sumPerKey[BUY];
        
        // Timerr Fee In Percent  = Sum Sells * Original Timerr Fee * Total Dividend Fees / (Sum Buys * Original BUSD Fee + Sum Sells * Original Timerr Fee)
        // increase Timerr fee on sells, decrease on buys
        TimerrFeePercentage = sumSells * TimerrFee * dividendManager.getSummedFees (feeType) / (sumSells * TimerrFee + sumBuys * BUSDFee);
            
        // BUSD Fee In Percent = Sum Buys * Original BUSD Fee * Total Dividend Fees / (Sum Buys * Original BUSD Fee + Sum Sells * Original Timerr Fee)
        // increase BUSD fee on buys, decrease on sells
        BUSDFeePercentage = dividendManager.getSummedFees (feeType) - TimerrFeePercentage;
    }
    
    function getTransferAmounts (uint256 amount, uint8 feeType) private returns (uint256, uint256, uint256) {
        uint256 _marketingTokens = amount * marketingFee[feeType] / 100;
        uint256 _liquidityTokens = amount * liquidityFee[feeType] / 100;
        uint256 _burnTokens = amount * burnFee[feeType] / 100;
        (uint256 TimerrFeePercentage, uint256 BUSDFeePercentage) = getRewardTokenPercentages (feeType);
        uint256 TimerrTokens = amount * TimerrFeePercentage / 100;
        uint256 BUSDTokens = amount * BUSDFeePercentage / 100;
            
        // Keep track of balances so we can split the address balance
        dividendManager.incrementFeeTokens (TimerrTokens, address(this));
        dividendManager.incrementFeeTokens (BUSDTokens, BUSD);
        marketingTokens += _marketingTokens;
        liquidityTokens += _liquidityTokens;
        uint256 fees = _marketingTokens + _liquidityTokens + TimerrTokens + BUSDTokens;
        return (amount - fees - _burnTokens, fees, _burnTokens);
    }

    function _transfer (address from, address to, uint256 amount) internal override {
        require (from != address(0),"0");
        require (to != address(0),"0");
        require (!isBlacklisted[from] && !isBlacklisted[to], "Blacklisted address");
        
       // Need to allow owner to add liquidity, otherwise prevent any snipers from buying for the first few blocks
        if (from != owner() && to != owner() && (block.timestamp <= antibotEndTime || antibotEndTime == 0)) {
            require (to == canStopAntibotMeasures, "Timerr: Bots can't stop antibot measures");
            if (antibotEndTime == 0)
                antibotEndTime = block.timestamp + 4;
        }

        if (amount == 0) {
            super._transfer (from, to, 0);
            return;
        } 
        else if (from == TimerrDT) { // Don't get caught in circular payout events
            super._transfer (from, to, amount);
            return;
        }
        
        // Check max wallet
        if (from != owner() && !isExcludedFromFees[to] && to != uniswapV2Pair)
            require (balanceOf(to) + amount <= maxWalletAmount, "Timerr: Receiver's wallet balance exceeds the max wallet amount");
        
        uint8 feeType = SELL;
        
        if (automatedMarketMakerPairs[to] && from != owner()) {
            if (from != address(this))
                transactionBuffer.append(amount, SELL);
            
            if (!isExcludedFromFees[from])
                dividendManager.excludeFromDividendsUntilTimeout(from); // Miss one payout as you sold
        } else if (automatedMarketMakerPairs[from]) {
            feeType = BUY;
            transactionBuffer.append(amount, BUY);
        }

        if (balanceOf(address(this)) >= swapTokensAtAmount && !swapping && !automatedMarketMakerPairs[from] && !isExcludedFromFees[from] && to != owner()) {
            swapping = true;
            sellTokensForBNBAndTakeFees(swapTokensAtAmount);
            swapping = false;
        }

        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if (isExcludedFromFees[from] || isExcludedFromFees[to])
            takeFee = false;

        if (takeFee) {
            (uint256 transferAmount, uint256 tokensForFees, uint256 tokensToBurn) = getTransferAmounts(amount, feeType);
            amount = transferAmount;
            
            if (tokensForFees > 0)
                super._transfer(from, address(this), tokensForFees);
            
            if (tokensToBurn > 0)
                super._transfer(from, BURN_ADDRESS, tokensToBurn);
        }

        super._transfer(from, to, amount);

        try dividendManager.setBalance(from, balanceOf(from)) {} catch {}
        try dividendManager.setBalance(to, balanceOf(to)) {} catch {}

        if (!swapping) {
            uint256 gas = gasForProcessing;

            try dividendManager.process(gas) returns (uint256[] memory iterations, uint256[] memory claims, uint256[] memory lastProcessedIndex) {
                for (uint256 i = 0; i < iterations.length; i++)
                    emit ProcessedDividendTracker(iterations[i], claims[i], lastProcessedIndex[i], true, (gas / iterations.length), tx.origin);
            } catch {}
        }
    }
    
    function sellTokensForBNBAndTakeFees (uint256 swapAmount) private {
        (uint256 bnbForMarketingAndRewards, uint256 contractTokenBalance, uint256 scaledRewardTokens, uint256 scaledMarketingTokens) = swapLiquifyAndSellToBNB(swapAmount);
        // Split returned BNB into marketing and dividend amounts
        uint256 bnbForBUSD = bnbForMarketingAndRewards * scaledRewardTokens / (scaledMarketingTokens + scaledRewardTokens);
        // Swap BNB to BUSD and send dividends to BUSD dividend tracker and distribute
        swapAndSendDividends(bnbForBUSD, scaledRewardTokens);

        uint256 bnbForMarketing = address(this).balance;
        marketingWalletAddress.sendValue(bnbForMarketing);
        // Send native dividends to Timerr dividend tracker and distribute
        uint256 TimerrDividends = dividendManager.getFeeTokensFromRewardAddress(address(this)) * swapAmount / contractTokenBalance;
        super._transfer (address(this), dividendManager.getTrackerAddress(address(this)), TimerrDividends);
        
        try dividendManager.distributeDividends(TimerrDividends, address(this)) {
            emit SendDividends (address(this), TimerrDividends, TimerrDividends);
            // Make sure we zero the count of tokens set aside for Timerr dividends
            dividendManager.decrementFeeTokens(TimerrDividends, address(this));
        } catch {
            // If the final holder is selling there will be no holders to payout, as they will be banned for 24 hours, so hold the dividends back for later
        } 
    }

    function swapLiquifyAndSellToBNB (uint256 swapAmount) private returns (uint256, uint256, uint256, uint256) {
        uint256 bnbForFees;
        uint256 contractTokenBalance = balanceOf (address(this));
        uint256 scaledLiquidityTokens = liquidityTokens * swapAmount / contractTokenBalance;
        uint256 scaledMarketingTokens = marketingTokens * swapAmount / contractTokenBalance;
        uint256 scaledRewardTokens = dividendManager.getFeeTokensFromRewardAddress (BUSD) * swapAmount / contractTokenBalance;
        // split tokens for LP into halves
        uint256 half = scaledLiquidityTokens / 2;
        uint256 otherHalf = scaledLiquidityTokens - half;
        // Swap half LP tokens + marketing + BUSD reward tokens at once to avoid multiple contract sells
        uint256 tokensToSwap = half + scaledMarketingTokens + scaledRewardTokens;
        bnbForFees = swapTokensForBNB (tokensToSwap);

        if (bnbForFees > 0) {
            liquidityTokens -= scaledLiquidityTokens;
            marketingTokens -= scaledMarketingTokens;
            uint256 bnbToLiquidity;
            // Send all BNB to addLiquidity as additional will be returned
            (bnbForFees, bnbToLiquidity) = addLiquidity (otherHalf, bnbForFees);
            emit SwapAndLiquify (half, bnbToLiquidity, otherHalf);
        }
        
        return (bnbForFees, contractTokenBalance, scaledRewardTokens, scaledMarketingTokens);
    }

    function swapTokensForBNB (uint256 tokenAmount) private returns (uint256) {
        uint256 initialBalance = address(this).balance;
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve (address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens (
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
        
        return (address(this).balance - initialBalance);
    }

    function swapBNBForBUSD (uint256 bnbAmount) private {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = BUSD;

        // make the swap
        uniswapV2Router.swapExactETHForTokens {value: bnbAmount} (
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity (uint256 tokenAmount, uint256 bnbAmount) private returns (uint256, uint256) {
        // approve token transfer to cover all possible scenarios
        _approve (address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        (,uint256 bnbToLiquidity,) = uniswapV2Router.addLiquidityETH {value: bnbAmount} (
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
        
        return (bnbAmount - bnbToLiquidity, bnbToLiquidity);
    }

    function swapAndSendDividends (uint256 bnbForDividend, uint256 tokensSwapped) private {
        swapBNBForBUSD (bnbForDividend);
        uint256 dividends = IERC20(BUSD).balanceOf (address(this));
        
        if (dividends > 0) {
            bool success = IERC20(BUSD).transfer (dividendManager.getTrackerAddress (BUSD), dividends);
        
            if (success) {
                try dividendManager.distributeDividends (dividends, BUSD) {
                    emit SendDividends (BUSD, dividendManager.getFeeTokensFromRewardAddress (BUSD), dividends);
                } catch {
                    // If the final holder is selling there will be no holders to payout, as they will be banned for 24 hours, so hold the dividends back for later
                }
            }
            
            dividendManager.decrementFeeTokens (tokensSwapped, BUSD); // Even if we don't distribute dividends to the tracker, we need to decrement the tokens as they've been converted to BUSD
        }
    } 
    // BNB that is created as part of the liquidity provision process will be sent to the PCS pair address immediately and so cannot be affected by this action
    function withdrawExcessBNB (address _account) external onlyOwner {
        uint256 contractBNBBalance = address(this).balance;
        
        if (contractBNBBalance > 0)
            payable(_account).sendValue(contractBNBBalance);
        
        emit AccidentallySentBNBWithdrawn (_account, contractBNBBalance);
    }
}

contract DividendManager is Ownable, SharedConstants {
    DividendTracker[] public dtArray;
    uint256[] public trackerFeeTokensToSwap;
    
    constructor() { }
    
    function addDividendTracker (string memory name, string memory ticker, address rewardToken, uint256 claimWait, uint256 minBalanceForDividends, uint8 buyFeeToTake, uint8 sellFeeToTake) 
        external 
        onlyOwner 
        returns (address)
    {
        DividendTracker newDividendTracker = new DividendTracker (name, ticker, rewardToken, claimWait, minBalanceForDividends, buyFeeToTake, sellFeeToTake);
        dtArray.push (newDividendTracker);
        uint256 feeTokens;
        trackerFeeTokensToSwap.push (feeTokens);
        
        //exclude all other dividends from this
       for (uint i = 0; i < dtArray.length - 1; i++) 
            excludeFromAllDividends (address(dtArray[i]));
        
        return address(newDividendTracker);
    }
    
    function incrementFeeTokens (uint256 tokens, uint256 dividendTrackerID) external onlyOwner {
        trackerFeeTokensToSwap[dividendTrackerID] += tokens;
    }
    
    function incrementFeeTokens (uint256 tokens, address rewardToken) external onlyOwner {
        trackerFeeTokensToSwap[getIDFromRewardAddress (rewardToken)] += tokens;
    }
    
    function decrementFeeTokens (uint256 tokens, uint256 dividendTrackerID) external onlyOwner {
        trackerFeeTokensToSwap[dividendTrackerID] -= tokens;
    }
    
    function decrementFeeTokens (uint256 tokens, address rewardToken) external onlyOwner {
        trackerFeeTokensToSwap[getIDFromRewardAddress (rewardToken)] -= tokens;
    }
    
    function incrementFeeTokens (uint256[] memory tokens) external onlyOwner {
        require (tokens.length == dtArray.length, "DividendManager: Must provide fee tokens value for each tracker");
        
        
        for (uint256 i = 0; i < dtArray.length; i++)
            trackerFeeTokensToSwap[i] += tokens[i];
    }
    
    function resetFeeTokens (uint256 dividendTrackerID) external onlyOwner {
        trackerFeeTokensToSwap[dividendTrackerID] = 0;
    }
    
    function resetFeeTokens (address rewardToken) external onlyOwner {
        trackerFeeTokensToSwap[getIDFromRewardAddress (rewardToken)] = 0;
    }
    
    function excludeFromSelectedDividends (address account, bool[] memory excluded) public onlyOwner {
        require (excluded.length == dtArray.length, "DividendManager: Must provide excluded value for each tracker");
        
        for (uint256 i = 0; i < dtArray.length; i++) {
            if (excluded[i])
                dtArray[i].excludeFromDividends (account);
        }
    }
    
    function excludeFromAllDividends (address account) public onlyOwner {
        for (uint256 i = 0; i < dtArray.length; i++)
            dtArray[i].excludeFromDividends (account);
    }
    
    function updateClaimWaits (uint256[] memory newClaimWaits) external onlyOwner {
        require (newClaimWaits.length == dtArray.length, "DividendManager: Must provide newClaimwWait for each tracker (array wrong length)");
        
        for (uint256 i = 0; i < dtArray.length; i++)
            dtArray[i].updateClaimWait (newClaimWaits[i]);
    }
    
    function updateFees (uint8[] memory newFees, uint8 feeType) external onlyOwner {
        require (newFees.length == dtArray.length, "DividendManager: Must provide new fees for each tracker (array wrong length)");
        
        for (uint256 i = 0; i < dtArray.length; i++)
            dtArray[i].updateFee (newFees[i], feeType);
    }
    
    function distributeDividends (uint256 amount, uint256 dividendTrackerID) external onlyOwner {
        dtArray[dividendTrackerID].distributeDividends (amount);
    }
    
    function distributeDividends (uint256 amount, address rewardToken) external onlyOwner {
        dtArray[getIDFromRewardAddress (rewardToken)].distributeDividends (amount);
    }
    
    function process (uint256 gas) external onlyOwner returns (uint256[] memory, uint256[] memory, uint256[] memory) {
        uint256 gasPerTracker = gas / dtArray.length; //Split the available gas between the trackers
        uint256[] memory iterations = new uint256[](dtArray.length);
        uint256[] memory claims = new uint256[](dtArray.length);
        uint256[] memory lastProcessedIndex = new uint256[](dtArray.length);
        
        for (uint256 i = 0; i < dtArray.length; i++) {
            (uint256 _iterations, uint256 _claims, uint256 _lastProcessedIndex) = dtArray[i].process (gasPerTracker);
            iterations[i] = _iterations;
            claims[i] = _claims;
            lastProcessedIndex[i] = _lastProcessedIndex;
        }
        
        return (iterations, claims, lastProcessedIndex);
    }
    
    function setBalance (address account, uint256 newBalance) external onlyOwner {
        for (uint256 i = 0; i < dtArray.length; i++)
            dtArray[i].setBalance (account, newBalance);
    }
    
    function processAccount (address account) external onlyOwner {
        for (uint256 i = 0; i < dtArray.length; i++)
            dtArray[i].processAccount (account, false);
    }
    
    function excludeFromDividendsUntilTimeout (address account) external onlyOwner {
        for (uint256 i = 0; i < dtArray.length; i++)
            dtArray[i].excludeFromDividendsUntilTimeout (account);
    }
    
    function getIDFromRewardAddress (address reward) public view returns (uint256) {
        for (uint256 i = 0; i < dtArray.length; i++) {
            if (reward == dtArray[i].getRewardToken())
                return i;
        }
        
        revert ("DividendManager: Reward Address not found in DividendTracker rewards");
    }
    
    function getFeeTokensFromRewardAddress (address reward) public view returns (uint256) {
        return trackerFeeTokensToSwap[getIDFromRewardAddress (reward)];
    }
    
    function getSummedFeeTokens() public view returns (uint256) {
        uint256 summedFeeTokens;
        
        for (uint256 i = 0; i < trackerFeeTokensToSwap.length; i++) {
            summedFeeTokens += trackerFeeTokensToSwap[i];
        }
        
        return summedFeeTokens;
    }
    
    function getRewardToken (uint256 dividendTrackerID) public view returns (address) {
        return dtArray[dividendTrackerID].getRewardToken();
    }
    
    function getTrackerAddress (uint256 dividendTrackerID) public view returns (address) {
        return address(dtArray[dividendTrackerID]);
    }
    
    function getTrackerAddress (address rewardToken) public view returns (address) {
        return address(dtArray[getIDFromRewardAddress (rewardToken)]);
    }
    
    function getLastProcessedIndexes() public view returns (uint256[] memory) {
        uint256[] memory lastProcessedIndexes = new uint256[](dtArray.length);
        
        for (uint256 i = 0; i < dtArray.length; i++)
            lastProcessedIndexes[i] = dtArray[i].getLastProcessedIndex();
            
        return lastProcessedIndexes;
    }

    function getNumberOfTokenHolders() public view returns (uint256[] memory) {
        uint256[] memory numberOfTokenHolders = new uint256[](dtArray.length);
        
        for (uint256 i = 0; i < dtArray.length; i++)
            numberOfTokenHolders[i] = dtArray[i].getNumberOfTokenHolders();
            
        return numberOfTokenHolders;
    }
    
    function totalDividendsDistributed() public view returns (uint256[] memory) {
        uint256[] memory totalDividendsPerTracker = new uint256[](dtArray.length);
        
        for (uint256 i = 0; i < dtArray.length; i++)
            totalDividendsPerTracker[i] = dtArray[i].totalDividendsDistributed();
        
        return totalDividendsPerTracker;
    }
    
    function withdrawableDividendsOf (address account) public view returns (uint256[] memory) {
        uint256[] memory withdrawableDividendPerTracker = new uint256[](dtArray.length);
        
        for (uint256 i = 0; i < dtArray.length; i++)
            withdrawableDividendPerTracker[i] = dtArray[i].withdrawableDividendOf (account);
        
        return withdrawableDividendPerTracker;
    }
    
    // Returns fees per tracker for this feeType in an array, with the last element being the summed fees for all trackers
    function getFees (uint8 feeType) public view returns (uint8[] memory) {
        uint8[] memory fees = new uint8[](dtArray.length + 1);
        uint8 summedFees;
        
        for (uint256 i = 0; i < dtArray.length; i++) {
            fees[i] = dtArray[i].fee (feeType);
            summedFees += fees[i];
        }
        
        fees[dtArray.length] = summedFees;
        return fees;
    }
    
    function getSummedFees (uint8 feeType) public view returns (uint8) {
        uint8 summedFees;
        
        for (uint256 i = 0; i < dtArray.length; i++) {
            summedFees += dtArray[i].fee (feeType);
        }
        
        return summedFees;
    }
    
    function getFee (uint8 feeType, address rewardToken) public view returns (uint8) {
        return dtArray[getIDFromRewardAddress (rewardToken)].fee(feeType);
    }
    
    function claimWaits() public view returns (uint256[] memory) {
        uint256[] memory claimWait = new uint256[](dtArray.length);
        
        for (uint256 i = 0; i < dtArray.length; i++)
            claimWait[i] = dtArray[i].claimWait();
        
        return claimWait;
    }
    
    function balancesOf(address account) public view returns (uint256[] memory) {
        uint256[] memory balances = new uint256[](dtArray.length);
        
        for (uint256 i = 0; i < dtArray.length; i++)
            balances[i] = dtArray[i].balanceOf (account);
        
        return balances;
    }
    
    function getAccount (address account, uint256 dividendTrackerID) public view returns (address, int256, int256, uint256, uint256, uint256, uint256, uint256) {
        require (dividendTrackerID < dtArray.length, "DividendManager: ID does not exist");
        return dtArray[dividendTrackerID].getAccount (account);
    }
    
    function getAccountAtIndex (uint256 index, uint256 dividendTrackerID) public view returns (address, int256, int256, uint256, uint256, uint256, uint256, uint256) {
        require (dividendTrackerID < dtArray.length, "DividendManager: ID does not exist");
        return dtArray[dividendTrackerID].getAccountAtIndex (index);
    }
    
    function dividendTrackers() public view returns (uint256) {
        return dtArray.length;
    }
}

contract DividendTracker is Ownable, DividendPayingToken {
    using SafeMathConversion for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping(address => bool) public excludedFromDividends;
    mapping(address => uint256) public excludedTimeout;
    mapping(address => uint256) public excludedBalance;

    mapping(address => uint256) public lastClaimTimes;

    uint256 public claimWait;
    uint256 public minimumTokenBalanceForDividends;
    uint8[2] public fee;

    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor (string memory _name, string memory _ticker, address _rewardToken, uint256 _claimWait, uint256 _minimumTokenBalanceForDividends, uint8 _buyFee, uint8 _sellFee) 
        DividendPayingToken (_name, _ticker, _rewardToken) 
    {
        claimWait = _claimWait;
        minimumTokenBalanceForDividends = _minimumTokenBalanceForDividends;
        fee[BUY] = _buyFee;
        fee[SELL] = _sellFee;
    }
    
    function updateFee (uint8 newFee, uint8 feeType) external onlyOwner {
        fee[feeType] = newFee;
    }

    function _transfer (address, address, uint256) internal pure override {
        require(false, "DividendTracker: No transfers allowed");
    }

    function withdrawDividend() public pure override {
        require(false, "DividendTracker: withdrawDividend disabled. Use the 'claim' function on the main contract.");
    }

    function excludeFromDividends(address account) external onlyOwner {
        excludedFromDividends[account] = true;
        _setBalance(account, 0);
        tokenHoldersMap.remove(account);
        emit ExcludeFromDividends(account);
    }

    function excludeFromDividendsUntilTimeout (address account) external onlyOwner {
        excludedFromDividends[account] = true;
        excludedTimeout[account] = block.timestamp + claimWait;
        excludedBalance[account] = balanceOf (account);
        _setBalance(account, 0); //set balance to zero but don't remove from map so it still gets processed
        emit ExcludeFromDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 900 && newClaimWait <= 86400);
        require(newClaimWait != claimWait);
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return lastProcessedIndex;
    }
    
    function getNumberOfTokenHolders() external view returns (uint256) {
        return tokenHoldersMap.keys.length;
    }

    function getAccount (address _account) public view returns (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            uint256 secondsUntilAutoClaimAvailable
        )
    {
        account = _account;
        index = tokenHoldersMap.getIndexOfKey(account);
        iterationsUntilProcessed = -1;

        if (index >= 0) {
            if (uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index - int256(lastProcessedIndex);
            } else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length > lastProcessedIndex ? tokenHoldersMap.keys.length - lastProcessedIndex : 0;
                iterationsUntilProcessed = index + int256(processesUntilEndOfArray);
            }
        }

        withdrawableDividends = withdrawableDividendOf (account);
        totalDividends = accumulativeDividendOf (account);

        lastClaimTime = lastClaimTimes[account];
        nextClaimTime = lastClaimTime > 0 ? lastClaimTime + claimWait : 0;
        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ? nextClaimTime - block.timestamp : 0;
    }

    function getAccountAtIndex (uint256 index) public view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        if (index >= tokenHoldersMap.size())
            return (0x0000000000000000000000000000000000000000, -1, -1, 0, 0, 0, 0, 0);

        address account = tokenHoldersMap.getKeyAtIndex (index);
        return getAccount (account);
    }

    function canAutoClaim (uint256 lastClaimTime) private view returns (bool) {
        if (lastClaimTime > block.timestamp)
            return false;

        return block.timestamp - lastClaimTime >= claimWait;
    }

    function setBalance (address account, uint256 newBalance) public onlyOwner {
        if (excludedFromDividends[account]) {
            if (excludedTimeout[account] > 0 && excludedTimeout[account] < block.timestamp) { // Were temporarily excluded, now can be included again
                excludedFromDividends[account] = false; // Don't need to update balance as function will set new balance below
            } else if (excludedTimeout[account] > block.timestamp) { // Are still temporarily excluded
                if (newBalance >= minimumTokenBalanceForDividends) // Update excluded balance if they still qualify for rewards else remove them
                    excludedBalance[account] = newBalance;
                else
                    tokenHoldersMap.remove (account);
                
                return;
            } else { // Permanently excluded
                return;
            }
        }

        if (newBalance >= minimumTokenBalanceForDividends) {
            _setBalance (account, newBalance);
            tokenHoldersMap.set (account, newBalance);
        } else {
            _setBalance (account, 0);
            tokenHoldersMap.remove (account);
        }

        processAccount (account, true);
    }

    function process (uint256 gas) public returns (uint256, uint256, uint256) {
        uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;

        if (numberOfTokenHolders == 0)
            return (0, 0, lastProcessedIndex);

        uint256 _lastProcessedIndex = lastProcessedIndex;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
        uint256 claims = 0;

        while (gasUsed < gas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;

            if (_lastProcessedIndex >= tokenHoldersMap.keys.length)
                _lastProcessedIndex = 0;

            address account = tokenHoldersMap.keys[_lastProcessedIndex];
            
            if (excludedFromDividends[account] && excludedTimeout[account] < block.timestamp) { // was temporarily excluded but can now be included again
                excludedFromDividends[account] = false;
                excludedTimeout[account] = 0;
                // we can validly assume the balance is > minimumTokenBalanceForDividends as any changes in balance since exclusion will have been checked, and the balance was valid when excluded
                // this assumption would need to be checked if the value of minimumTokenBalanceForDividends could be changed after creation
                _setBalance(account, excludedBalance[account]); 
            }

            if (canAutoClaim (lastClaimTimes[account])) {
                if (processAccount (account, true)) {
                    claims++;
                }
            }

            iterations++;
            uint256 newGasLeft = gasleft();

            if (gasLeft > newGasLeft)
                gasUsed += (gasLeft - newGasLeft);

            gasLeft = newGasLeft;
        }

        lastProcessedIndex = _lastProcessedIndex;
        return (iterations, claims, lastProcessedIndex);
    }

    function processAccount (address account, bool automatic) public onlyOwner returns (bool) {
        uint256 amount = _withdrawDividendOfUser (account);

        if (amount > 0) {
            lastClaimTimes[account] = block.timestamp;
            emit Claim (account, amount, automatic);
            return true;
        }

        return false;
    }
}   
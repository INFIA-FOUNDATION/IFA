pragma solidity ^0.4.11;
/**
    erc20 interface
*/
contract ERC20 {
    function totalSupply() public constant returns (uint supply);
    function balanceOf( address who ) public constant returns (uint value);
    function allowance( address owner, address spender ) public constant returns (uint _allowance);

    function transfer( address to, uint value) public returns (bool ok);
    function transferFrom( address from, address to, uint value) public returns (bool ok);
    function approve( address spender, uint value ) public returns (bool ok);

    event Transfer( address indexed from, address indexed to, uint value);
    event Approval( address indexed owner, address indexed spender, uint value);
}
/**
    lockable token
*/
contract Lockable {
    uint public creationTime;
    bool public lock;
    bool public tokenTransfer;
    address public owner;
    mapping( address => bool ) public unlockaddress;
    mapping( address => bool ) public lockaddress;
    event Locked(address lockaddress,bool status);
    event Unlocked(address unlockedaddress, bool status);

    // if transfer
    modifier isTokenTransfer {
        // if token transfer is not allow
        if(!tokenTransfer) {
            require(unlockaddress[msg.sender]);
        }
        _;
    }

    modifier checkLock {
        assert(!lockaddress[msg.sender]);
        _;
    }

    modifier isOwner
    {
        require(owner == msg.sender);
        _;
    }

    function Lockable()
    public
    {
        creationTime = now;
        tokenTransfer = false;
        owner = msg.sender;
    }

    function lockAddress(address target, bool status)
    external
    isOwner
    {
        require(owner != target);
        lockaddress[target] = status;
        Locked(target, status);
    }

    function unlockAddress(address target, bool status)
    external
    isOwner
    {
        unlockaddress[target] = status;
        Unlocked(target, status);
    }
}

library SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

}
/**
*/
    ERC20, {

    string public constant name = "INFIAPROTOCOL";
    string public constant symbol = "IFA";
    uint8 public constant decimals = 18;  // 18 is the most common number of decimal places

    using SafeMath for uint;

    mapping( address => uint ) _balances;
    mapping( address => mapping( address => uint ) ) _approvals;
    uint _supply;
    address public walletAddress;

    event TokenBurned(address burnAddress, uint amountOfTokens);
    event TokenTransfer();

    modifier onlyFromWallet {
        require(msg.sender != walletAddress);
        _;
    }

    function IFAToken( uint initial_balance, address wallet)
    public
    {
        require(wallet != 0);
        require(initial_balance != 0);
        _balances[msg.sender] = initial_balance;
        _supply = initial_balance;
        walletAddress = wallet;
    }

    function totalSupply() public constant returns (uint supply) {
        return _supply;
    }

    function balanceOf( address who ) public constant returns (uint value) {
        return _balances[who];
    }

    function allowance(address owner, address spender) public constant returns (uint _allowance) {
        return _approvals[owner][spender];
    }

    function transfer( address to, uint value)
    public
    isTokenTransfer
    checkLock
    returns (bool success) {

        require( _balances[msg.sender] >= value );

        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(value);
        Transfer( msg.sender, to, value );
        return true;
    }

    function transferFrom( address from, address to, uint value)
    public
    isTokenTransfer
    checkLock
    returns (bool success) {
        // if you don't have enough balance, throw
        require( _balances[from] >= value );
        // if you don't have approval, throw
        require( _approvals[from][msg.sender] >= value );
        // transfer and return true
        _approvals[from][msg.sender] = _approvals[from][msg.sender].sub(value);
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        Transfer( from, to, value );
        return true;
    }

    function approve(address spender, uint value)
    public
    checkLock
    returns (bool success) {
        _approvals[msg.sender][spender] = value;
        Approval( msg.sender, spender, value );
        return true;
    }

    // burnToken burn tokensAmount for sender balance
    function burnTokens(uint tokensAmount)
    public
    isTokenTransfer
    {
        require( _balances[msg.sender] >= tokensAmount );

        _balances[msg.sender] = _balances[msg.sender].sub(tokensAmount);
        _supply = _supply.sub(tokensAmount);
        TokenBurned(msg.sender, tokensAmount);

    }


    function enableTokenTransfer()
    external
    onlyFromWallet
    {
        tokenTransfer = true;
        TokenTransfer();
    }

    function disableTokenTransfer()
    external
    onlyFromWallet
    {
        tokenTransfer = false;
        TokenTransfer();
    }

    /* This unnamed function is called whenever someone tries to send ether to it */
    function () public payable {
        revert();
    }

}

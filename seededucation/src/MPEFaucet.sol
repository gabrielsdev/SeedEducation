pragma solidity >=0.4.20;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract MPEFaucet {

    bool public isFaucetEnabled;

    address public owner;

    uint128 public amount;

    IERC20 public MPE1;
    IERC20 public MPE2;

    modifier onlyOwner() {
        require(owner == msg.sender, "Only owner can call this function");
        _;
    }

    modifier checkFaucetEnabled() {
        require(isFaucetEnabled, "Ask the owner to enable MPE Faucet");
        _;
    }

    modifier checkAmount(uint128 _amount) {
        require(_amount <= amount, "Ask the owner to increase amount of MPE tokens to obtain");
        _;
    }

    constructor(uint128 _amount, IERC20 _MPE1, IERC20 _MPE2) {
        isFaucetEnabled = true;
        owner = msg.sender;
        amount = _amount;
        MPE1 = _MPE1;
        MPE2 = _MPE2;
    }

    function obtainMPE1(uint128 _amount) checkFaucetEnabled checkAmount(_amount) public {
        require(_amount <= MPE1.balanceOf(address(this)), "The requested MPE1 token amount exceeds the balance of this contract");
        MPE1.transfer(msg.sender, _amount);
    }

    function obtainMPE2(uint128 _amount) checkFaucetEnabled checkAmount(_amount) public {
        require(_amount <= MPE2.balanceOf(address(this)), "The requested MPE2 token amount exceeds the balance of this contract");
        MPE2.transfer(msg.sender, _amount);
    }

    function setFaucetState(bool _isFaucetEnabled) onlyOwner public {
        isFaucetEnabled = _isFaucetEnabled;
    }

    function setAmount(uint128 _amount) onlyOwner public {
        amount = _amount;
    }

    function changeMPEs(IERC20 _MPE1, IERC20 _MPE2) onlyOwner public {
        MPE1 = _MPE1;
        MPE2 = _MPE2;
    }

    function depositMPE1(uint128 _amount) public {
        require(_amount <= MPE1.balanceOf(msg.sender), "You don't have enough MPE1 token");
        MPE1.transferFrom(msg.sender, address(this), _amount);
    }

    function depositMPE2(uint128 _amount) public {
        require(_amount <= MPE2.balanceOf(msg.sender), "You don't have enough MPE2 token");
        MPE2.transferFrom(msg.sender, address(this), _amount);
    }
}
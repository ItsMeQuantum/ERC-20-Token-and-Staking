pragma solidity ^0.8.20;

interface IToken {
    function transferFrom(address, address, uint256) external returns (bool);
    function transfer(address, uint256) external returns (bool);
}

contract Staking {

    IToken public token;
    address public owner;

    struct StakeInfo {
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => StakeInfo) public stakes;

    uint256 public rewardRate = 10; // 10% reward

    constructor(address _token) {
        token = IToken(_token);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function stake(uint256 _amount) public {
        require(_amount > 0, "Amount must be > 0");

        token.transferFrom(msg.sender, address(this), _amount);

        stakes[msg.sender].amount += _amount;
        stakes[msg.sender].timestamp = block.timestamp;
    }

    function unstake() public {
        StakeInfo storage user = stakes[msg.sender];
        require(user.amount > 0, "No stake");

        uint256 stakingTime = block.timestamp - user.timestamp;
        uint256 reward = (user.amount * rewardRate) / 100;

        uint256 total = user.amount + reward;

        user.amount = 0;

        token.transfer(msg.sender, total);
    }

    function fundContract(uint256 _amount) public onlyOwner {
        token.transferFrom(msg.sender, address(this), _amount);
    }

    function setRewardRate(uint256 _rate) public onlyOwner {
        rewardRate = _rate;
    }
}
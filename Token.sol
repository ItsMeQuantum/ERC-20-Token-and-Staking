// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseMemecoin {

    string public name = "Base Meme Token";
    string public symbol = "BMT";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    uint256 public burnRate = 2; // 2% burn per transfer

    address public owner;

    constructor(uint256 _initialSupply) {
        owner = msg.sender;
        totalSupply = _initialSupply * 10**decimals;
        balanceOf[msg.sender] = totalSupply;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");

        uint256 burnAmount = (_value * burnRate) / 100;
        uint256 sendAmount = _value - burnAmount;

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += sendAmount;
        totalSupply -= burnAmount;

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(balanceOf[_from] >= _value, "Balance too low");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");

        uint256 burnAmount = (_value * burnRate) / 100;
        uint256 sendAmount = _value - burnAmount;

        balanceOf[_from] -= _value;
        balanceOf[_to] += sendAmount;
        allowance[_from][msg.sender] -= _value;
        totalSupply -= burnAmount;

        return true;
    }

    function setBurnRate(uint256 _rate) public onlyOwner {
        require(_rate <= 10, "Too high");
        burnRate = _rate;
    }
}
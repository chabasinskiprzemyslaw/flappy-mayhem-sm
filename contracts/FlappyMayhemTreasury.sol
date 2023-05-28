// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title FlappyMayhemTreasury
 * @dev HackOnChain
 */
contract FlappyMayhemTreasury {
    //Events
    event RewardSend(address indexed _to, uint256 _amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    modifier userExists(address _user) {
        require(users[_user].userAddress == _user, "User does not exist.");
        _;
    }

    //Variables
    IERC20 public token;
    address public owner;
    uint256 public balance;

    // Multiplier for the score
    uint256 public bonus;

    struct User {
        address userAddress;
        uint256 bestScore;
        uint256 lastScore;
        uint256 totalScore;
    }

    mapping(address => User) public users;

    constructor(IERC20 _token, address _owner, uint256 _bonus) {
        owner = _owner;
        token = _token;
        bonus = _bonus;
    }

    function setToken(address _token) external onlyOwner {
        require(_token != address(0), "Invalid token address.");
        token = IERC20(_token);
    }

    function setOwner(address _owner) external onlyOwner {
        require(_owner != address(0), "Invalid owner address.");
        owner = _owner;
    }

    function setBonus(uint256 _bonus) external onlyOwner {
        bonus = _bonus;
    }

    function getLastScore(address _user) external view returns (uint256) {
        return users[_user].lastScore;
    }

    function getTotalScore(address _user) external view returns (uint256) {
        return users[_user].totalScore;
    }

    function getBestScore(address _user) external view returns (uint256) {
        return users[_user].bestScore;
    }

    function calcReward(
        uint256 _score,
        uint _bonus
    ) public pure returns (uint256) {
        return _score * _bonus;
    }

    function transfer(address _to, uint256 _score) external onlyOwner {
        require(_to != address(0), "Invalid address.");
        require(_score > 0, "Invalid amount.");
        uint256 reward = calcReward(_score, bonus);
        require(reward <= balance, "Insufficient balance in the contract.");

        if (_to == users[msg.sender].userAddress) {
            users[msg.sender].lastScore = _score;
            users[msg.sender].totalScore += _score;
            if (_score > users[msg.sender].bestScore) {
                users[msg.sender].bestScore = _score;
            }
        } else {
            users[_to].userAddress = _to;
            users[_to].lastScore = _score;
            users[_to].totalScore += _score;
            if (_score > users[_to].bestScore) {
                users[_to].bestScore = _score;
            }
        }

        balance -= reward;

        (bool sent, ) = payable(_to).call{value: reward}("");
        require(sent, "Failed to send");
        emit RewardSend(_to, reward);
    }

    function deposit() external payable {
        balance += msg.value;
    }

    function getTokenBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }
}

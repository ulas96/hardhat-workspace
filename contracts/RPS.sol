// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract RPS {

    event GameCreated(address creator, uint amount, uint256 timestamp);

    uint256 public amount;
    address public owner;

    address internal excelciumAddress = 0x9e6969254D73Eda498375B079D8bE540FB42fea7;

    IERC20 internal excelcium = IERC20(excelciumAddress);

    struct Game {
        uint256 id;
        address opponent1;
        uint256 move1;
        address opponent2;
        uint256 move2;
        uint256 value;
        address winner;
        uint timestamp;
    }

    struct PendingGame {
        uint256 id;
        address gameCreator;
        uint256 value;
        bool active;
        uint timestamp;
    }

    PendingGame[] public pendingGames;

    Game[] public games;

    mapping(uint256 => uint256) private firstMoves;

    mapping(address => uint256) public claimableRewards;

    mapping(address => uint256) public claimedRewards;

    function tokenBalance(address adr) public view returns(uint256 balance) {
        balance = excelcium.balanceOf(adr);
    }

    constructor(uint256 _amount) payable {
        amount = _amount;
        owner = msg.sender;
    }

    function getGames() public view returns (Game[] memory _games) {
        _games = games;
    }

    function getPendingGames() public view returns (PendingGame[] memory _pendingGames) {
        _pendingGames = pendingGames;
    }

    function addGame(
        address opt1,
        uint256 move1,
        address opt2,
        uint256 move2,
        uint256 _amount,
        address winner,
        uint _timestamp
    ) private {
        uint id = games.length + 1;
        games.push(Game(
            id,
            opt1,
            move1,
            opt2,
            move2,
            _amount,
            winner,
            _timestamp
        ));
    }

    function addPendingGame(
        uint256 _firstMove,
        address _gameCreator,
        uint _timestamp
    ) private {
        uint id = pendingGames.length + 1;
        pendingGames.push(PendingGame(
            id,
            _gameCreator,
            amount,
            true,
            _timestamp
        ));
        firstMoves[id] = _firstMove;
    }

    function createGame(uint256 _firstMove, uint256 _amount) external {
        require(_amount >= amount, "Amount is less than minimum bet");
        require(tokenBalance(msg.sender) >= _amount, "Not enough tokens");
        require(excelcium.allowance(msg.sender, address(this)) >= _amount, "Not enough allowance");
        require(_firstMove == 0 || _firstMove == 2 || _firstMove == 1, "Invalid move");
        require(excelcium.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        addPendingGame(_firstMove, msg.sender, block.timestamp);
    }

    function joinGame(uint256 id, uint256 _secondMove, uint256 _amount) external {
        require(_amount >= amount, "Amount is less than minimum bet");
        require(tokenBalance(msg.sender) >= _amount,   "Not enough tokens");
        require(_secondMove == 0 || _secondMove == 2 || _secondMove == 1, "Invalid move");
        require(excelcium.allowance(msg.sender, address(this)) >= _amount,  "Not enough allowance");
        require(excelcium.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        uint256 arrayPosition = id - 1;
        require(pendingGames[arrayPosition].active == true);
        uint256 result = gameResult(
            firstMoves[pendingGames[arrayPosition].id],
            _secondMove
        );
        pendingGames[arrayPosition].active = false;
        address winner;

        if (result == 0) {
            claimableRewards[pendingGames[arrayPosition].gameCreator] += amount;
            claimableRewards[msg.sender] += amount;
            winner = address(0);
        } else if (result == 1) {
            claimableRewards[pendingGames[arrayPosition].gameCreator] +=
                (amount * 19) /
                10;
            winner = pendingGames[arrayPosition].gameCreator;
        } else if (result == 2) {
            claimableRewards[msg.sender] += (amount * 19) / 10;
            winner = msg.sender;
        }
        addGame(
            pendingGames[arrayPosition].gameCreator,
            firstMoves[id],
            msg.sender,
            _secondMove,
            amount,
            winner,
            block.timestamp
        );
    }

    function claimRewards(uint256 _amount) public {
        require(_amount > 0, "Amount is 0");
        require(claimableRewards[msg.sender] > 0, "No rewards to claim");
        require(_amount <= claimableRewards[msg.sender], "Amount is greater than claimable rewards");
        claimableRewards[msg.sender] -= _amount;
        claimedRewards[msg.sender] += _amount;
        require(excelcium.transfer(msg.sender, _amount), "Transfer failed");
    }

    function cancelGame(uint256 id) external {
        require(msg.sender == pendingGames[id].gameCreator);
        require(pendingGames[id].active == true);
        pendingGames[id].active = false;
        claimableRewards[msg.sender] += amount;
    }

    function withdraw(uint256 _amount) external {
        require(msg.sender == owner);
        payable(msg.sender).transfer(_amount);
    }

    //0: rock, 1: paper, 2: scissor
    function gameResult(uint move1, uint move2)
    private
    pure
    returns (uint winner)
    {
        if (move1 == 0 && move2 == 0) {
            winner = 0;
        } else if (move1 == 0 && move2 == 2) {
            winner = 1;
        } else if (move1 == 0 && move2 == 1) {
            winner = 2;
        } else if (move1 == 2 && move2 == 2) {
            winner = 0;
        } else if (move1 == 2 && move2 == 0) {
            winner = 2;
        } else if (move1 == 2 && move2 == 1) {
            winner = 1;
        } else if (move1 == 1 && move2 == 1) {
            winner = 0;
        } else if (move1 == 1 && move2 == 0) {
            winner = 1;
        } else if (move1 == 1 && move2 == 2) {
            winner = 2;
        }
    }
}

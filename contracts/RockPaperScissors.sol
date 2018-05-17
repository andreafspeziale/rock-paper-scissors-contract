pragma solidity 0.4.23;

/**
 * @title RockPaperScissors
 * @dev Basic implementation of the RockPaperScissors in solidity
*/

contract RockPaperScissors {
    /**
     * @dev matrix of game cases
     * rock vs rock = draw => 0
     * rock vs scissors = rock => 1
     * rock vs paper = paper => 2
    */
    mapping (string => mapping(string => int)) gameCases;

    address public firstGamer;
    address public secondGamer;
    string public firstGamerChoice;
    string public secondGamerChoice;
    string public firstGamerHashChoice;
    string public secondGamerHashChoice;

    // Events
    event LogPlayerRegistration(address indexed gamer);
    event LogGameResult(address indexed gamer, address indexed secondGamer, int indexed result);

    // ToDo Set the bet logic
    // ToDo At the moment the choice is clear and public so find a way to reduce cheat for the async flow

    modifier isValidChoice(string choice) {
        require(keccak256(choice) == "rocket" || keccak256(choice) == "paper" || keccak256(choice) == "scissors");
        _;
    }

    modifier isRegistered {
        require(msg.sender == firstGamer || msg.sender == secondGamer);
        _;
    }

    constructor() public {
        gameCases["rock"]["rock"] = 0;
        gameCases["rock"]["scissors"] = 1;
        gameCases["rock"]["paper"] = 2;
        gameCases["scissors"]["rock"] = 2;
        gameCases["scissors"]["scissors"] = 0;
        gameCases["scissors"]["paper"] = 1;
        gameCases["paper"]["rock"] = 1;
        gameCases["paper"]["scissors"] = 2;
        gameCases["paper"]["paper"] = 0;
    }

    /**
     * @dev registering players
    */
    function register() public returns(bool success) {
        // fail if same player
        require(msg.sender != firstGamer || msg.sender != secondGamer);
        // set players
        if(firstGamer == 0) {
            firstGamer = msg.sender;
            emit LogPlayerRegistration(firstGamer);
            success = true;
            return success;
        } else {
            secondGamer = msg.sender;
            emit LogPlayerRegistration(secondGamer);
            success = true;
            return success;
        }     
    }

    /**
     * @dev play function
    */
    function play(string choice) 
        public
        isValidChoice(choice)
        returns(int winner) 
    {
        // ToDo check choice is in choices

        // set choices
        if(msg.sender == firstGamer) {
            firstGamerChoice = choice;
        } else {
            secondGamerChoice = choice;
        }

        // check empty choices
        require(bytes(firstGamerChoice).length != 0 && bytes(secondGamerChoice).length != 0);
        
        // check winner
        winner = gameCases[firstGamerChoice][secondGamerChoice];

        if (winner == 1)
            // firstGamerChoice winner send the betted amount
        if (winner == 2) 
            // secondGamerChoice winner send the betted amount
        // else
            // betted amount / 2

        emit LogGameResult(firstGamer, secondGamer, winner);

        // remove players and choices
        firstGamerChoice = "";
        secondGamerChoice = "";
        firstGamer = 0;
        secondGamer = 0;

        return winner;
    }
}
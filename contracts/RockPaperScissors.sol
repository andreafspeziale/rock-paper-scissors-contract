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
    bytes32 public firstGamerHashChoice;
    bytes32 public secondGamerHashChoice;
    uint public timer;

    // ToDo Set the bet logic

    // Events
    event LogPlayerRegistration(address indexed gamer);
    event LogPlayerChoiceSet(address indexed gamer);
    event LogGameResult(address indexed gamer, address indexed secondGamer, int indexed result);

    // check that the gamer choice is one of the allowed choices
    modifier isValidChoice(string choice) {
        require(keccak256(choice) == "rocket" || keccak256(choice) == "paper" || keccak256(choice) == "scissors");
        _;
    }

    // allow function execution only if the gamer is already registered
    modifier isRegistered {
        require(msg.sender == firstGamer || msg.sender == secondGamer);
        _;
    }

    // allow function execution only if the gamer is not already registered
    modifier isNotRegistered {
        require(msg.sender != firstGamer || msg.sender != secondGamer);
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
     * @dev register function
     * gamer registration function 
    */
    function register() 
        public
        isNotRegistered 
        returns(bool success) 
    {
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
     * @dev setChoice function
     * setting the hased gamers choices
    */
    function setChoice(string choice) 
        public
        isValidChoice(choice)
        isRegistered
        returns(bool success)
    {
        // set choices
        if(msg.sender == firstGamer) {
            emit LogPlayerChoiceSet(firstGamer);
            firstGamerHashChoice = keccak256(choice);
        } else {
            emit LogPlayerChoiceSet(secondGamer);
            secondGamerHashChoice = keccak256(choice);
        }
        success = true;
        return success;
    }

    /**
     * @dev showChoice function
     * proof of gamer move
    */
    function showChoice(string choice)
        public
        isValidChoice(choice)
        isRegistered
        returns(bool proved)
    {
        
    }
}
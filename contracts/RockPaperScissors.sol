pragma solidity 0.4.23;

/**
 * @title RockPaperScissors
 * @dev Basic implementation of the RockPaperScissors in solidity
*/

contract RockPaperScissors {
    
    mapping (string => mapping(string => int)) gameCases;

    address public firstGamer;
    address public secondGamer;
    string public firstGamerChoice;
    string public secondGamerChoice;
    bytes32 public firstGamerHashChoice;
    bytes32 public secondGamerHashChoice;
    uint public gameCountdown;

    // ToDo Set the bet logic
    // ToDo Set the timer and kill game logic

    // Events
    event LogGamerRegistration(address indexed gamer);
    event LogGamerChoiceSet(address indexed gamer);
    event LogGamerShowChoice(address indexed gamer, string indexed choice);
    event LogGameResult(address indexed gamer, address indexed secondGamer, int indexed result);


    // check that the gamer choice is one of the allowed choices
    modifier isValidChoice(string choice) {
        require(keccak256(choice) == keccak256("rocket") || keccak256(choice) == keccak256("paper") || keccak256(choice) == keccak256("scissors"));
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


    /**
     * @dev matrix of game cases
     * rock vs rock = draw => 0
     * rock vs scissors = rock => 1
     * rock vs paper = paper => 2
    */
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
     * @dev hashMove function
     * helper function to create an hashed move passing the move and a secret string
    */
    function hashMove(string choice, string secret)
        public
        pure
        isValidChoice(choice)
        returns(bytes32 hashedMove)
    {
        return keccak256(keccak256(choice), keccak256(secret));
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
            emit LogGamerRegistration(firstGamer);
            success = true;
            return success;
        } else {
            secondGamer = msg.sender;
            emit LogGamerRegistration(secondGamer);
            success = true;
            return success;
        }     
    }

    /**
     * @dev setChoice function
     * setting the hased gamers choices
    */
    function setChoice(string choice, string secret) 
        public
        isValidChoice(choice)
        isRegistered
        returns(bool success)
    {
        // set choices
        if(msg.sender == firstGamer) {
            emit LogGamerChoiceSet(firstGamer);
            firstGamerHashChoice = hashMove(choice, secret);
        } else {
            emit LogGamerChoiceSet(secondGamer);
            secondGamerHashChoice = hashMove(choice, secret);
        }
        success = true;
        return success;
    }

    /**
     * @dev showChoice function
     * proof of gamer move, putting in clear the gamer choice
    */
    function showChoice(string choice, string secret)
        public
        isValidChoice(choice)
        isRegistered
        returns(bool showed)
    {
        // putting in clear first gamer choice
        if(msg.sender == firstGamer && hashMove(choice, secret) == firstGamerHashChoice) {
            emit LogGamerShowChoice(firstGamer, choice);
            firstGamerChoice = choice;
        }
        // putting in clear second gamer choice
        if(msg.sender == secondGamer && hashMove(choice, secret) == secondGamerHashChoice) {
            emit LogGamerShowChoice(secondGamer, choice);
            secondGamerChoice = choice;
        }
        showed = true;
        return showed;
    }

    /**
     * @dev getWinner function
     * check the game winner
    */
    function getWinner() 
        public
        view 
        returns(int winner) 
    {
        // check both move was showed
        if(bytes(firstGamerChoice).length != 0 && bytes(secondGamerChoice).length != 0) {
            winner = gameCases[firstGamerChoice][secondGamerChoice];
            return winner;
        }
        // ...
    }

}
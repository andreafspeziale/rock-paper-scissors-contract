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

    // ToDo Set the bet logic --> at the moment no bets
    
    // ToDo Set the timer and kill game logic --> at the moment the countdown logic 
    // takes place only when one of the two gamers reveal the move 

    // Events
    event LogGamerRegistration(address indexed gamer);
    event LogGamerChoiceSet(address indexed gamer);
    event LogGamerRevealChoice(address indexed gamer, string indexed choice);
    event LogGameResult(address indexed firstGamer, address indexed secondGamer, int indexed result);

    // allow function execution only if the gamer is already registered
    modifier isRegistered {
        require(msg.sender == firstGamer || msg.sender == secondGamer);
        _;
    }

    // before a gamer reveal a move both hashed moves need to be submitted
    modifier areHashedChoiceSubmitted {
        require(firstGamerHashChoice.length != 0 && secondGamerHashChoice.length != 0);
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
     * @dev internal extractValidChoice function
     * check if the gamer choice is one of the allowed choices and return the cleared one
    */
    function extractValidChoice(bytes32 choice, string secret) internal returns(string clearChoice) {
        require(keccak256("rocket", secret) == choice || keccak256("paper", secret) == choice || keccak256("scissors", secret) == choice);
        if(keccak256("rocket", secret) == choice) {
            clearChoice = "rocket";
            return clearChoice;
        }
        if(keccak256("paper", secret) == choice) {
            clearChoice = "paper";
            return clearChoice;
        }
        if(keccak256("scissors", secret) == choice) {
            clearChoice = "scissors";
            return clearChoice;
        }
    }

    /**
     * @dev register function
     * gamer registration function 
    */
    function register() 
        public
        returns(bool success) 
    {
        // set players
        if(firstGamer == 0) {
            firstGamer = msg.sender;
        } else if(secondGamer == 0) {
            secondGamer = msg.sender;
        } else {
            revert();
        }
        emit LogGamerRegistration(msg.sender);
        success = true;
        return success;  
    }

    /**
     * @dev setChoice function
     * setting the hashed gamers choices
     *
     * it is callable only if the msg.sender is one of the player
     * and if the choices have not been revealed
    */
    function setChoice(bytes32 choice)
        public
        returns(bool success)
    {
        // set choices
        if(msg.sender == firstGamer && firstGamerHashChoice == 0) {
            firstGamerHashChoice = choice;
        } else if(msg.sender == secondGamer && secondGamerHashChoice == 0) {
            secondGamerHashChoice = choice;
        } else {
            revert();
        }
        emit LogGamerChoiceSet(msg.sender);
        success = true;
        return success;
    }

    /**
     * @dev revealChoice function
     * proof of gamer move, putting in clear the gamer choice
     *
     * it is callable only if the msg.sender is one of the player
     * and if both gamers has already submitted their hasched choices
    */
    function revealChoice(string secret)
        public
        isRegistered // is msg.sender on of the two gamers?
        areHashedChoiceSubmitted // have both gamers submitted their hashed choice?
        returns(bool revealed)
    {
        string memory clearChoice = "";
        // start choice submission gameCountdown
        if (bytes(firstGamerChoice).length == 0 && bytes(secondGamerChoice).length == 0)
            gameCountdown == now;
        // putting in clear first gamer choice
        if(msg.sender == firstGamer) {
            clearChoice = extractValidChoice(firstGamerHashChoice, secret);
            emit LogGamerRevealChoice(firstGamer, clearChoice);
            firstGamerChoice = clearChoice;
        }
        // putting in clear second gamer choice
        if(msg.sender == secondGamer) {
            clearChoice = extractValidChoice(secondGamerHashChoice, secret);
            emit LogGamerRevealChoice(secondGamer, clearChoice);
            secondGamerChoice = clearChoice;
        }
        revealed = true;
        return revealed;
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
        }
        else if (now > gameCountdown + 120)
        {            
            if (bytes(firstGamerChoice).length != 0)
                // firstGamer wins
                winner = 1;
            else if (bytes(secondGamerChoice).length != 0)
                // secondGamer wins
                winner = 2;
        }
        emit LogGameResult(firstGamer, secondGamer, winner);
        return winner;
    }

}
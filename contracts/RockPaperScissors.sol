pragma solidity 0.4.23;

/**
 * @title RockPaperScissors
 * @dev Basic implementation of the RockPaperScissors in solidity
 *
 * ToDos Develop the bet logic
*/

contract RockPaperScissors {
    
    mapping (string => mapping(string => int)) gameCases;

    address public firstGamer;
    address public secondGamer;
    bytes32 public firstGamerHashChoice;
    bytes32 public secondGamerHashChoice;
    string public firstGamerChoice;
    string public secondGamerChoice;
    uint public gameCountdown;

    /**
     * @dev Events
     * Describing the game lifecycle
    */
    event LogGamerRegistration(address indexed gamer);
    event LogGamerHashedChoiceSet(address indexed gamer, bytes32 indexed hashedChoice);
    event LogGamerRevealChoice(address indexed gamer, string indexed clearChoice);
    event LogNotValidChoice(address indexed gamer, string clearChoice);
    event LogGameResult(address indexed firstGamer, address indexed secondGamer, int indexed result);
    event LogResetGame();

    /**
     * @dev areHashedChoiceSubmitted
     * Check if both gamers has submitted the hashedChoice
    */
    modifier areHashedChoiceSubmitted {
        require(firstGamerHashChoice.length != 0 && secondGamerHashChoice.length != 0);
        _;
    }

    /**
     * @dev isValidChoice
     * Internal helper function to determine if a submitted hashedChoice is a valid move
    */
    function isValidChoice(string clearChoice, address gamer) internal pure returns(bool success) {
        if(keccak256(clearChoice) == keccak256("rock") || keccak256(clearChoice) == keccak256("paper") || keccak256(clearChoice) == keccak256("scissors"))
            return true;
        else
            return false;
    }

    /**
     * @dev resetGame
     * Internal function to reset the entire game
    */
    function resetGame() internal returns(bool success) {
        emit LogResetGame();
        firstGamerChoice = "";
        secondGamerChoice = "";
        firstGamerHashChoice = 0;
        secondGamerHashChoice = 0;
        gameCountdown= 0;
        return true;
    }

    /**
     * @dev Matrix of game cases
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
     * @dev register
     * Gamer registration function
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
     * @dev setChoice
     * Setting the hashed gamers choices
    */
    function setChoice(bytes32 hashedChoice)
        public
        returns(bool success)
    {
        
        if(msg.sender == firstGamer && firstGamerHashChoice == 0) {
            firstGamerHashChoice = hashedChoice;
        } else if(msg.sender == secondGamer && secondGamerHashChoice == 0) {
            secondGamerHashChoice = hashedChoice;
        } else {
            revert();
        }
        emit LogGamerHashedChoiceSet(msg.sender, hashedChoice);
        return true;
    }

    /**
     * @dev revealChoice
     * Proof of gamer move, setting the clearChoice
    */
    function revealChoice(string clearChoice, string secret)
        public
        areHashedChoiceSubmitted
        returns(bool revealed)
    {
        
        if (bytes(firstGamerChoice).length == 0 && bytes(secondGamerChoice).length == 0)
            gameCountdown == block.number;
        
        if (keccak256(clearChoice, secret) == firstGamerHashChoice) {
            firstGamerChoice = clearChoice;
        } else if (keccak256(clearChoice, secret) == secondGamerHashChoice) {
            secondGamerChoice = clearChoice;
        } else revert();
        
        if(!isValidChoice(clearChoice, msg.sender)) {
            emit LogNotValidChoice(msg.sender, clearChoice);
            resetGame();
            return false;
        }

        emit LogGamerRevealChoice(secondGamer, clearChoice);
        return true;
    }

    /**
     * @dev getWinner
     * Check the game winner
    */
    function getWinner() 
        public
        returns(int winner) 
    {
        // check both move was showed
        if(bytes(firstGamerChoice).length != 0 && bytes(secondGamerChoice).length != 0) {
            winner = gameCases[firstGamerChoice][secondGamerChoice];
        }
        else if (block.number > gameCountdown + 1)
        {            
            if (bytes(firstGamerChoice).length != 0)
                // firstGamer wins
                winner = 1;
            else if (bytes(secondGamerChoice).length != 0)
                // secondGamer wins
                winner = 2;
        }
        emit LogGameResult(firstGamer, secondGamer, winner);
        resetGame();
        return winner;
    }
}
pragma solidity 0.4.23;

/**
 * @title RockPaperScissors
 * @dev Basic implementation of the RockPaperScissors in solidity
 *
 * ToDos Develop the bet logic
*/

contract RockPaperScissors {
    
    mapping (bytes32 => mapping(bytes32 => int)) gameCases;

    address public firstGamer;
    address public secondGamer;
    bytes32 public firstGamerHashChoice;
    bytes32 public secondGamerHashChoice;
    bytes32 public firstGamerChoice;
    bytes32 public secondGamerChoice;
    bytes32 public rock = 0x10977e4d68108d418408bc9310b60fc6d0a750c63ccef42cfb0ead23ab73d102;
    bytes32 public paper = 0xea923ca2cdda6b54f4fb2bf6a063e5a59a6369ca4c4ae2c4ce02a147b3036a21;
    bytes32 public scissors = 0x389a2d4e358d901bfdf22245f32b4b0a401cc16a4b92155a2ee5da98273dad9a;
    uint public gameCountdown;

    /**
     * @dev Events
     * Describing the game lifecycle
    */
    event LogGamerRegistration(address indexed gamer);
    event LogGamerHashedChoiceSet(address indexed gamer, bytes32 indexed hashedChoice);
    event LogGamerRevealChoice(address indexed gamer, bytes32 indexed clearChoice);
    event LogNotValidChoice(address indexed gamer, bytes32 clearChoice);
    event LogGameResult(address indexed firstGamer, address indexed secondGamer, int indexed result);
    event LogResetGame(address indexed raiser);

    /**
     * @dev areHashedChoiceSubmitted
     * Check if both gamers has submitted the hashedChoice
    */
    modifier areHashedChoiceSubmitted {
        require(firstGamerHashChoice.length != 0 && secondGamerHashChoice.length != 0);
        _;
    }

    /**
     * @dev Matrix of game cases
     * rock vs rock = draw => 0
     * rock vs scissors = firstGamer won the game => 1
     * rock vs paper = secondGamer won the game => 2
    */
    constructor() public {
        gameCases[rock][rock] = 0;
        gameCases[rock][scissors] = 1;
        gameCases[rock][paper] = 2;
        gameCases[scissors][rock] = 2;
        gameCases[scissors][scissors] = 0;
        gameCases[scissors][paper] = 1;
        gameCases[paper][rock] = 1;
        gameCases[paper][scissors] = 2;
        gameCases[paper][paper] = 0;
    }

    /**
     * @dev isValidChoice
     * Internal helper function to determine if a submitted hashedChoice is a valid move
    */
    function isValidChoice(bytes32 clearChoice) public view returns(bool success) {
        if(clearChoice == rock || clearChoice == paper || clearChoice == scissors)
            return true;
        else
            return false;
    }

    /**
     * @dev resetGame
     * Internal function to reset the entire game
    */
    function resetGame(address raiser) internal returns(bool success) {
        emit LogResetGame(raiser);
        firstGamerChoice = 0;
        secondGamerChoice = 0;
        firstGamerHashChoice = 0;
        secondGamerHashChoice = 0;
        gameCountdown= 0;
        return true;
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
     * @dev setHashedChoice
     * Setting the hashed gamers choices
    */
    function setHashedChoice(bytes32 hashedChoice)
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
    function revealChoice(bytes32 clearChoice, bytes32 secret)
        public
        areHashedChoiceSubmitted
        returns(bool revealed)
    {
        
        if (firstGamerChoice == 0 && secondGamerChoice == 0)
            gameCountdown == block.number;
        
        if (keccak256(clearChoice, secret) == firstGamerHashChoice) {
            firstGamerChoice = clearChoice;
        } else if (keccak256(clearChoice, secret) == secondGamerHashChoice) {
            secondGamerChoice = clearChoice;
        } else {
            revert();
        }
        
        if(!isValidChoice(clearChoice, msg.sender)) {
            emit LogNotValidChoice(msg.sender, clearChoice);
            resetGame(msg.sender);
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
        if(firstGamerChoice != 0 && secondGamerChoice != 0) {
            winner = gameCases[firstGamerChoice][secondGamerChoice];
        }
        else if (block.number > gameCountdown + 1)
        {            
            if (firstGamerChoice != 0)
                // firstGamer wins
                winner = 1;
            else if (secondGamerChoice != 0)
                // secondGamer wins
                winner = 2;
        }
        emit LogGameResult(firstGamer, secondGamer, winner);
        resetGame(address(this));
        return winner;
    }
}
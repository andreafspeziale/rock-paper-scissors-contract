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
    event LogGamerChoiceSet(address indexed gamer, bytes32 indexed hashedChoice);
    event LogGamerRevealChoice(address indexed gamer, string indexed choice);
    event LogGameResult(address indexed firstGamer, address indexed secondGamer, int indexed result);

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
    */
    function setChoice(bytes32 hashedChoice)
        public
        returns(bool success)
    {
        // set hashedChoice
        if(msg.sender == firstGamer && firstGamerHashChoice == 0) { // so hashedChoice can be setted once
            firstGamerHashChoice = hashedChoice;
        } else if(msg.sender == secondGamer && secondGamerHashChoice == 0) { // so hashedChoice can be setted once
            secondGamerHashChoice = hashedChoice;
        } else {
            revert();
        }
        emit LogGamerChoiceSet(msg.sender, hashedChoice);
        success = true;
        return success;
    }

    /**
     * @dev revealChoice function
     * proof of gamer move, putting in clear the gamer choice
    */
    function revealChoice(string clearChoice, string secret)
        public
        areHashedChoiceSubmitted // don't let the gamers reveal their move before both move are submitted
        returns(bool revealed)
    {
        // test if firstGamerChoice == 0 works
        if (bytes(firstGamerChoice).length == 0 && bytes(secondGamerChoice).length == 0)
            gameCountdown == block.number;
        
        if (keccak256(clearChoice, secret) == firstGamerHashChoice) {
            firstGamerChoice = clearChoice;
        } else if (keccak256(clearChoice, secret) == secondGamerHashChoice) {
            secondGamerChoice = clearChoice;
        } else revert();
        
        emit LogGamerRevealChoice(secondGamer, clearChoice);
        revealed = true;
        return revealed;
    }

    /**
     * @dev getWinner function
     * check the game winner
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
        return winner;
    }

}
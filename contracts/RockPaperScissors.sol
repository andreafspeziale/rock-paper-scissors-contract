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
    
    address firstGamer;
    address secondGamer;
    string firstGamerChoice;
    string secondGamerChoice;

    constructor() {
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
    function register() public {
        // no empty addresses
        require(msg.sender != address(0x00));
        // fail if same player
        require(msg.sender != firstGamer || msg.sender != secondGamer);
        // set players
        if(firstGamer == 0) {
            firstGamer = msg.sender;
        } else {
            secondGamer = msg.sender;
        }     
    }
}
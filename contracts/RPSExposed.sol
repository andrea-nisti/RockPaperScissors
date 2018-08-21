pragma solidity ^0.4.23;
/**
 * The RPSExposed contract exposes internal functions for testing
 */


import "./RockPaperScissors.sol";
 
contract RPSExposed is RockPaperScissors {

	 Hand public scis = Hand.SCISSORS;
	 Hand public rock = Hand.ROCK;
	 Hand public paper = Hand.PAPER;

	function compareExposed(uint move1, uint move2) public pure returns (uint win) {

        return compare(Hand(move1),Hand(move2));        
    }

    //For test purposes
    function sendEtherTest (address sender) returns(bool res)  {
    	require (msg.value > 0);
    	balances[sender] += msg.value;
    }
    

}

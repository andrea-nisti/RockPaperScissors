/**
 * The TestRockPaperScissors contract
 */
pragma solidity ^0.4.23;

import "../contracts/RPSExposed.sol";
import "truffle/Assert.sol";

contract TestRockPaperScissors {
	
	RPSExposed testContract;

	function beforeEach() public {
        testContract = new RPSExposed();
    }

    function testCompare () public returns(bool r) {
    	
    	// Rock:
    	uint hand1 = uint(testContract.rock());
    	uint hand2 = uint(testContract.rock());
    	uint res = testContract.compareExposed(hand1,hand2);
    	Assert.equal(res, 0, "should equal input");


    	hand2 =  uint(testContract.paper());
    	res = testContract.compareExposed(hand1,hand2);
    	Assert.equal(res, 2, "should equal input");

    	hand2 = uint(testContract.scis());
    	res = testContract.compareExposed(hand1,hand2);
    	Assert.equal(res, 1, "should equal input");
    	
    	// Paper:
    	hand1 = uint(testContract.paper());
    	
    	hand2 =  uint(testContract.paper());
    	res = testContract.compareExposed(hand1,hand2);
    	Assert.equal(res, 0, "should equal input");

    	hand2 = uint(testContract.scis());
    	res = testContract.compareExposed(hand1,hand2);
    	Assert.equal(res, 2, "should equal input");

    	hand2 = uint(testContract.rock());
    	res = testContract.compareExposed(hand1,hand2);
    	Assert.equal(res, 1, "should equal input");

    	//Scissors
    	hand1 = uint(testContract.scis());

    	hand2 =  uint(testContract.paper());
    	res = testContract.compareExposed(hand1,hand2);
    	Assert.equal(res, 1, "should equal input");

    	hand2 = uint(testContract.scis());
    	res = testContract.compareExposed(hand1,hand2);
    	Assert.equal(res, 0, "should equal input");

    	hand2 = uint(testContract.rock());
    	res = testContract.compareExposed(hand1,hand2);
    	Assert.equal(res, 2, "should equal input");



    	return true;

    }
    
}

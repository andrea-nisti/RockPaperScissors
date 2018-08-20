pragma solidity ^0.4.23;

library UtilsLib{
	function convert(uint amount,uint conversionRate) public pure returns (uint convertedAmount)
	{
		return amount * conversionRate;
	}
	function getKekka (string pass1, string pass2)  public pure returns(bytes32){
		return keccak256(abi.encodePacked(pass1, pass2));
	}
}
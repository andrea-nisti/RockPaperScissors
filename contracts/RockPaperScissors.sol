pragma solidity ^0.4.23;

import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';
import 'openzeppelin-solidity/contracts/lifecycle/Pausable.sol';
import 'openzeppelin-solidity/contracts/lifecycle/Destructible.sol';
import 'openzeppelin-solidity/contracts/math/Math.sol';

/**
 You will create a smart contract named RockPaperScissors whereby:

- Alice and Bob play the classic rock paper scissors game.
- to enrol, each player needs to deposit the right Ether amount, possibly zero.
- to play, each player submits their unique move.
- the contract decides and rewards the winner with all Ether wagered.

Of course there are many ways to implement it so we leave to yourselves to invent.

How can this be the 3rd project and not the 1st?? Try.

Stretch goals:

- make it a utility whereby any 2 people can decide to play against each other.
- reduce gas costs as much as you can.
- let players bet their previous winnings.
- how can you entice players to play, knowing that they may have their funding stuck in the contract if they faced an uncooperative player?
*/
contract RockPaperScissors is Ownable, Pausable, Destructible{
    
    mapping (address => uint) public balances;
    mapping (uint  => Game)   public games;

    enum Hand {EMPTY, ROCK, PAPER, SCISSORS}
    
    struct Game {

        bool doIExist;

        address p1;
        address p2;

        bool p1Payed;
        bool p2Payed;
 
        uint buyIn;
        bytes32 secretKey1;
        bytes32 secretKey2;
    }

    //events

    event LogGameCreated(uint _gameId, uint _buyIn);
    //event LogPlayerEnrolled(uint _gameId, uint _buyIn);

    constructor () public {}    

    function createGame (uint _gameId, uint _buyIn) external onlyOwner returns(bool res)   {
        
        require(games[_gameId].doIExist == false,"Existing game");
        games[_gameId].doIExist = true;
        emit LogGameCreated(_gameId,_buyIn);
        return true;
    }

    function enroll (uint _gameId, bytes32 _secretHand) external returns(bool res)  {
        
        require(games[_gameId].doIExist,"Game not existing");
        require(!games[_gameId].p1Payed || !games[_gameId].p2Payed,"Ongoing Game");
        require(balances[msg.sender] >= games[_gameId].buyIn);

        balances[msg.sender] -= games[_gameId].buyIn;
        
        if(!games[_gameId].p1Payed){
            games[_gameId].p1 = msg.sender;
            games[_gameId].secretKey1 = _secretHand;
            games[_gameId].p1Payed = true;
        }else if(!games[_gameId].p2Payed){
            games[_gameId].p2 = msg.sender;
            games[_gameId].secretKey2 = _secretHand;
            games[_gameId].p2Payed = true;
        }else {
            revert();
        }
        return true;

    }

    function playGame (uint _gameId, uint _pass1, Hand _h1, uint _pass2, Hand _h2) external returns(address winnerAddr, bool res) {
        
        require(games[_gameId].doIExist == true,"Game not existing");
        require(games[_gameId].p1Payed && games[_gameId].p2Payed,"Wating for players");
        require (_h1 != Hand.EMPTY && _h2 != Hand.EMPTY,"You should play");
        
        bytes32 hash1 = keccak256(abi.encodePacked(_pass1, uint(_h1), games[_gameId].p1));
        bytes32 hash2 = keccak256(abi.encodePacked(_pass2, uint(_h2), games[_gameId].p2));

        require (hash1 == games[_gameId].secretKey1, "Player one is cheating...");
        require (hash2 == games[_gameId].secretKey2, "Player two is cheating...");
        
        uint winner = compare(_h1, _h2);
        if(winner == 1){
            balances[games[_gameId].p1] += 2*games[_gameId].buyIn;
            winnerAddr = games[_gameId].p1;
        }else if (winner == 2){
            balances[games[_gameId].p1] += 2*games[_gameId].buyIn;
            winnerAddr = games[_gameId].p2;
        }else{
            balances[games[_gameId].p1] += games[_gameId].buyIn;
            balances[games[_gameId].p2] += games[_gameId].buyIn;
            winnerAddr = address(0);
            res = false;    
        }
        delete games[_gameId];
        res = true;

    }

    //1-rock ; 2-paper ; 3-scissors
    function compare(Hand move1, Hand move2) internal pure returns (uint win) {
        if (move1 == move2) return 0;
        if ( (move1 == Hand.ROCK && move2==Hand.PAPER) || 
             (move1 == Hand.PAPER && move2==Hand.SCISSORS) ||
             (move1 == Hand.SCISSORS && move2==Hand.ROCK) ) return 2;
        if ( (move1 == Hand.ROCK && move2==Hand.SCISSORS) || 
             (move1 == Hand.PAPER && move2==Hand.ROCK) ||
             (move1 == Hand.SCISSORS && move2==Hand.PAPER) ) return 1;
         
    }

    function withdraw (uint amount2wd) external returns(bool res)  {
       require(amount2wd > 0);
       require(balances[msg.sender]>0);
       require(amount2wd <= balances[msg.sender], "Insufficient Balance");       
       
       balances[msg.sender] -= amount2wd;
       msg.sender.transfer(amount2wd);
       return true;

    }
    //Helpers
    function computeHash(uint ps, uint m, address adr) public pure returns(bytes32){
        return keccak256(abi.encodePacked(ps,m,adr));
    }

    function checkBalance (address addr) public view returns(uint bal)  {
        return balances[addr];
    }
    

    //Fallback fun
    function () public payable  {
        require (msg.value > 0 , "You should send some ether");
        balances[msg.sender] += msg.value;
    }
    
}
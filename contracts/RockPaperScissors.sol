pragma solidity ^0.4.23;

import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../node_modules/openzeppelin-solidity/contracts/lifecycle/Pausable.sol";
import "../node_modules/openzeppelin-solidity/contracts/lifecycle/Destructible.sol";
import "../node_modules/openzeppelin-solidity/contracts/math/Math.sol";

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

        address p1;
        address p2;
        Hand move2;
        uint buyIn;
        bytes32 secretKey1;
        uint deadline;

    }

    //events
    event LogGameCreated(uint gameId, uint buyIn, bytes32 secret, address player1, address player2);
    event LogPlayer2Enrolled(uint gameId, Hand move, address player2);
    event LogPlayedGame(uint gameId, uint pass1, Hand move1, Hand move2, address winner);
    event LogNewWithdraw(uint amount, address who);

    constructor () public {}    

    //Create a game if it is not there
    function readyPlayer1 (uint gameId, address player2, uint _buyIn, bytes32 secret,uint duration) external whenNotPaused returns(bool res)   {
        
        require(games[gameId].p1 == address(0),"Existing game");
        require(balances[msg.sender] >= games[gameId].buyIn, "Not enough balance");

        games[gameId] = Game({
            p1 : msg.sender,
            p2 : player2,
            move2 : Hand.EMPTY,
            buyIn : _buyIn,
            secretKey1 : secret,
            deadline : now + duration
        });
        balances[msg.sender] -= _buyIn;
        
        emit LogGameCreated(gameId,_buyIn,secret,msg.sender, player2);
        return true;
    }

    //Enroll to the game, 
    //hand is clear but who cares now -> We could hash the move in the future for hardcore players
    function readyPlayer2(uint gameId, Hand move2) external whenNotPaused returns(bool res)  {

        address tPlayer1 = games[gameId].p1;
        require(tPlayer1 != address(0), "Game not existing");
        require(msg.sender == games[gameId].p2, "This game is not for you");
        require(!isExpired(gameId), "Game has expired");

        //Now we should have a buy in, save some gas
        uint tBuyIn = games[gameId].buyIn;
        require(msg.sender != tPlayer1, "You can't play alone");
        require(balances[msg.sender] >= tBuyIn, "Not enough balance");
        require(move2 != Hand.EMPTY, "You cannot play an empty hand, sorry");
        
        //Fill missing members
        games[gameId].move2 = move2;
        balances[msg.sender] -= tBuyIn;
        
        emit LogPlayer2Enrolled(gameId,move2,msg.sender);
        return true;
    }

    //Play the game and find out who's the lucky winner, Draw is not managed now -> game closes, you lose gas ¯\_( '_')_/¯
    function playGame (uint gameId, uint pass1, Hand move1) external whenNotPaused returns(bool res, address winnerAddr) {
        
        require(games[gameId].p2 != address(0),"Empty game");
        require(!isExpired(gameId), "Game has expired");
        require(move1 != Hand.EMPTY, "You cannot play an empty hand, sorry");
        
        bytes32 hash1 = computeHash(pass1, move1);
        require (hash1 == games[gameId].secretKey1, "Player one is cheating...");
        
        uint tBuyIn = games[gameId].buyIn;
        Hand move2 = games[gameId].move2; 
        uint winner = compare(move1, move2);
        
        //Should I save gas here by saving addresses? It is an if block so it shouldn't matters
        if(winner == 1){
            balances[games[gameId].p1] += 2*tBuyIn;
            winnerAddr = games[gameId].p1;
        }else if (winner == 2){
            balances[games[gameId].p1] += 2*tBuyIn;
            winnerAddr = games[gameId].p2;
        }else{
            balances[games[gameId].p1] += tBuyIn;
            balances[games[gameId].p2] += tBuyIn;
            winnerAddr = address(0); 
        }
        emit LogPlayedGame(gameId, pass1, move1, move2, winnerAddr);
        delete games[gameId];
        res = true;

    }

    //1-rock ; 2-paper ; 3-scissors
    function compare(Hand move1, Hand move2) internal pure returns (uint win) {
        if (move1 == move2) return 0;
        
        if ((move1 == Hand.ROCK && move2==Hand.SCISSORS)||
            (move1 == Hand.PAPER && move2==Hand.ROCK)||
            (move1 == Hand.SCISSORS && move2==Hand.PAPER)) return 1;
        
        if ((move1 == Hand.ROCK && move2==Hand.PAPER) ||
            (move1 == Hand.PAPER && move2==Hand.SCISSORS) ||
            (move1 == Hand.SCISSORS && move2==Hand.ROCK) ) return 2;
    }

    function withdraw (uint amount2wd) external returns(bool res)  {
        require(balances[msg.sender] > 0, "Empty balance");
        require(balances[msg.sender] >= amount2wd,"Insufficient Balance");       

        //Let us be optimistic
        balances[msg.sender] -= amount2wd;
        emit LogNewWithdraw(amount2wd, msg.sender);
        msg.sender.transfer(amount2wd);
        return true;
    }

    //Helpers
    function computeHash(uint pswrd, Hand move) public pure returns(bytes32){
        return keccak256(abi.encodePacked(pswrd,move));
    }
    //Useful for remix
    function checkBalance (address addr) public view returns(uint bal)  {
        return balances[addr];
    }
    //We compare with block time, not really precise but it's ok for now
    function isExpired(uint gameId) internal view returns(bool res){
        return now >= games[gameId].deadline;
    }

    //Accounting : readyPlayer1() -> readyPlayer2() -> Game expires -> p1 calls giveMeMoneyBack() -> p1 calls withdraw / same for p2
    function giveMeMoneyBack (uint gameId) external returns(bool res){
        
        require(games[gameId].secretKey1 != bytes32(0), "Empty game");
        require (isExpired(gameId), "You can claim your bet only on expired games");
        address p1 = games[gameId].p1;
        address p2 = games[gameId].p2;
        
        /* UNDER CONSTRUCTION */

        return true;        
    }
    
    //Fallback fun
    function () public payable  {
        balances[msg.sender] += msg.value;
    }
    
}
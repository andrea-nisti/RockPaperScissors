const RockPaperScissors = artifacts.require("./RPSExposed.sol");
//const BigNumber = require('bignumber.js');

contract('RockPaperScissors test', accounts => {

    console.log(accounts);
  // Will show ["0x1c25cc6a9f326ac277ce6879b03c4fd0596e10eb", "0x991b2246c8ed92a63ae64c9b910902f55350cd13", "0x258a69adcfb68ad70182bb351c7fa0b0e4b4b4cd"]
  // unit tests come here
    let instance;

    beforeEach(async function() {
        instance = await RockPaperScissors.new({ from: accounts[0] });
    });


    it("should check the correct chain of events", function() {
       console.log(instance.address);

        let amount1 = 10;
        let amount2 = 1;
        
        // Fallback for accounting
        let balance0;
        let balance1;
        return instance.sendTransaction({ from: accounts[0], value: web3.toWei(amount1,"ether")})
        .then(txObj => 
            {
                console.log(web3.eth.getBalance(instance.address));
                return instance.checkBalance.call(accounts[0]);
            })
        .then( res => {
                balance0 = res;
                return instance.sendTransaction({ from: accounts[1], value: web3.toWei(amount2,"ether")});
            })
        .then( txObj => {
                web3.eth.getBalance(instance.address)
                return instance.checkBalance.call(accounts[1]);
            })
        .then( res => {
                balance1 = res;
            })
        .then( () => {
                console.log(balance0);
                console.log(balance1);
                assert.equal(balance0, web3.toWei(amount1,"ether"), "should equal input for account0");
                assert.equal(balance1, web3.toWei(amount2,"ether"), "should equal input for account1");
            });
    });
        
});

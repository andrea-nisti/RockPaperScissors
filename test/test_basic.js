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
        return instance.sendEtherTest.sendTransaction(accounts[0],{ from: accounts[0], value: 500000000000000000000})
        .then(txObj => 
            {
                console.log(web3.eth.getBalance(instance.address));
                return instance.checkBalance.call(accounts[0]);
            })
        .then( res => console.log(res) );
        //instance.sendTransaction({ from: web3.eth.accounts[1], value: web3.toWei(amount2,"ether")})
        
        let balance0;
        let error;
/*
        console.log(web3.eth.getBalance(instance.address));
        instance.checkBalance.call(web3.eth.accounts[0]).then(res => {
            console.log("Debug....");
            console.log(res);}
            //assert.equal(res.toString(10), web3.toWei(amount1,"ether"), "should equal input for account0");
            return instance.checkBalance.call(web3.eth.accounts[1]);
        }).then(res2 => {
            assert.equal(res2.toString(10), web3.toWei(amount2,"ether"), "should equal input for account1");
        });

*/
    });
        /*
        .then(success => {

            
            //assert.isTrue(success, "failed to do something");
            //return instance.doSomething(arg1, { from: accounts[0] });
            
            // Game creation

        })
        .then(
            
            txObj => {
            
            //assert.strictEqual(txObj.logs.length, 1, "Only one event");
            //return instance.getSomethingElse.call();
            

            //Enrollement
        })
        .then(

            resultValue => {
            //assert.equal(resultValue.toString(10), "3", "there should be exactly 3 things at this stage");
            // Do not return anything on the last callback or it will believe there is an error.
            

            //Play game
        }).then( () => {
                //Balance verificaton
        });
        */
});

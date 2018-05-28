const RPS = artifacts.require('./RockPaperScissors.sol')

contract('RockPaperScissors', (accounts)=> {
    let contract

    const thirdy = accounts[0]
    const firstGamer = accounts[1]; secondGamer = accounts[2]
    
    
    const expectEvent = (res, eventName) => {
        const ev = _.find(res.logs, {event: eventName})
        expect(ev).to.not.be.undefined
        return ev
    }

    console.log(`Gamer1: ${firstGamer} \nGamer2: ${secondGamer} \nGeneric address: ${thirdy}`)

    beforeEach(async() => {
        contract = await RPS.new()
    })

    describe('GameCases stuff:', async () => {

        it('should see same hash for game move choices', async () => {
            
            const rock = web3.sha3("rock")
            const paper = web3.sha3("paper")
            const scissors = web3.sha3("scissors")

            const contractHashRock = await contract.rock.call()
            const contractHashPaper = await contract.paper.call()
            const contractHashScissors = await contract.scissors.call()

            expect(rock).to.equal(contractHashRock)
            expect(paper).to.equal(contractHashPaper)
            expect(scissors).to.equal(contractHashScissors)

        })

    })

    describe('Register a player stuff:', async () => {

        it('should set msg.sender as gamer1', async () => {
            const playerTx = await contract.register({from: firstGamer})
            const player = await contract.firstGamer()
            expect(player).to.equal(firstGamer)
        })

        it('should return success equal true', async () => {
            const playerCall = await contract.register.call({from: firstGamer})
            expect(playerCall).to.equal(true)
        })

        it('should not be possible to set same address as first and second gamer', async () => {
            const playerTx = await contract.register({from: firstGamer})
            try {
                const playerTx2 = await contract.register({from: firstGamer})
            } catch (e) {
                assert.include(err.message, 'revert', 'No revert if anyone kill my contract');
            }
        })

        it('should log a register event', async () => {
            const playerTx = await contract.register({from: firstGamer})
            const event = expectEvent(playerTx, 'LogGamerRegistration')
            expect(event.args.gamer).to.equal(firstGamer)
        })

        it('should be possible to set both first and second gamer', async () => {
            let playerTx = await contract.register({from: firstGamer})
            let player = await contract.firstGamer()
            playerTx2 = await contract.register({from: secondGamer})
            player2 = await contract.secondGamer()
            
            expect(player).to.equal(firstGamer)
            expect(player2).to.equal(secondGamer)
        })

    })
})
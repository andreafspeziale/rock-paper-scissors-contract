const RPS = artifacts.require('./RockPaperScissors.sol')

contract('RockPaperScissors', (accounts)=> {
    let contract

    const thirdy = accounts[0]
    const firstGamer = accounts[1]; secondGamer = accounts[2]
    const secret = "secret"
    const hashedSecret = web3.sha3(secret)
    const rock = web3.sha3("rock"); paper = web3.sha3("paper"); scissors = web3.sha3("scissors")

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

    describe('Check valid choice stuff:', async () => {

        it('should see a valid choice returning true', async () => {
            
            let isValidChoice = await contract.isValidChoice.call(rock)
            expect(isValidChoice).to.equal(true)

            isValidChoice = await contract.isValidChoice.call(paper)
            expect(isValidChoice).to.equal(true)

            isValidChoice = await contract.isValidChoice.call(scissors)
            expect(isValidChoice).to.equal(true)
        })

        it('should see not a valid choice returning false', async () => {

            const wrongRock = web3.sha3("Rock"); wrongPaper = web3.sha3("pap"); wrongScissors = web3.sha3("scissor")
            
            let isValidChoice = await contract.isValidChoice.call(wrongRock)
            expect(isValidChoice).to.equal(false)

            isValidChoice = await contract.isValidChoice.call(wrongPaper)
            expect(isValidChoice).to.equal(false)

            isValidChoice = await contract.isValidChoice.call(wrongScissors)
            expect(isValidChoice).to.equal(false)
        })

    })

    describe('Check setHashedChoice stuff:', async () => {

        const hashedChoice = web3.sha3(rock + hashedSecret)

        it('should not set firstGamer hashedChoice', async () => {
            try {
                const setHashedChoice = await contract.setHashedChoice(hashedChoice)
            } catch(e) {
                assert.include(e.message, 'revert', 'It can set a choice even if gamer is not registered')
            }
        })

        it('should not set firstGamer hashedChoice by a third party', async () => {
            await contract.register({from: firstGamer})
            await contract.register({from: secondGamer})
            
            try {
                const setHashedChoice = await contract.setHashedChoice({from: thirdy}, hashedChoice)
            } catch(e) {
                assert.include(e.message, 'revert', 'It can set a choice even if gamer is not the one setting the choice')
            }
        })

        it('should set properly firstGamer hashedChoice', async () => {
            await contract.register({from: firstGamer})
            await contract.register({from: secondGamer})
            const setChoice = await contract.setHashedChoice(hashedChoice, {"from": firstGamer});
            const firstGamerHashChoice = await contract.firstGamerHashChoice.call()
            expect(firstGamerHashChoice).to.equal(hashedChoice)
        })

        it('should return true setting firstGamer hashedChoice', async () => {
            await contract.register({from: firstGamer})
            await contract.register({from: secondGamer})
            const setChoice = await contract.setHashedChoice.call(hashedChoice, {"from": firstGamer});
            expect(setChoice).to.equal(true)
        })

        it('should fire LogGamerHashedChoiceSet', async () => {
            await contract.register({from: firstGamer})
            await contract.register({from: secondGamer})
            const setChoice = await contract.setHashedChoice(hashedChoice, {"from": firstGamer});
            const ev = expectEvent(setChoice, 'LogGamerHashedChoiceSet')
            expect(ev.args.gamer).to.equal(firstGamer)
            expect(ev.args.hashedChoice).to.equal(hashedChoice)
        })

        it('set hashed choice twice should be not allowed', async () => {
            await contract.register({from: firstGamer})
            await contract.register({from: secondGamer})

            let setChoice = await contract.setHashedChoice(hashedChoice, {"from": firstGamer});
            let setChoice2 = await contract.setHashedChoice(hashedChoice, {"from": secondGamer});

            try {
                setChoice = await contract.setHashedChoice(hashedChoice, {"from": firstGamer});
            } catch(e) {
                assert.include(e.message, 'revert', 'Is possible to override an hashedChoice after submission')
            }

            try {
                setChoice2 = await contract.setHashedChoice(hashedChoice, {"from": secondGamer});
            } catch(e) {
                assert.include(e.message, 'revert', 'Is possible to override an hashedChoice after submission')
            }
        })
    })
})
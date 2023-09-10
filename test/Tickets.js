const { expect } = require('chai');
const deploy = async () => {
    let signer = await ethers.getSigners();
    const Ticket = await ethers.getContractFactory('Ticket');
    const ticket = await Ticket.deploy();
    return { ticket, signer };
}
describe('Ticket', function () {
    describe('deployement', () => {
        it('returns correct developer and allevents vars', async () => {
            const { ticket, signer } = await deploy();
            const developer = await ticket.developer();
            const allEvents = await ticket.totalEvents();
            expect(developer).to.equal(signer[0].address);
            expect(allEvents).to.equal(0);
        })
    })

    describe('event creation', () => {
        it('should create a new event and give correct info', async () => {
            let temp = ['test', 'ust Bannu', 8767978, 10, 4000]
            const { ticket, signer } = await deploy();
            const res = await ticket.createEvent(...temp, { value: ethers.parseEther('0.1') });
            const tot = await ticket.totalEvents();
            const even = await ticket.allEvents(0);
            // console.log(even);
            expect(tot).to.equal(1);
            expect(even[0]).to.equal(temp[0]);
            expect(even[1]).to.equal(temp[1]);
            expect(Number(even[2])).to.equal(temp[2]);
            expect(Number(even[3])).to.equal(temp[3]);
            expect(Number(even[5])).to.equal(temp[4]);
            expect(even[6]).to.equal(signer[0].address);
        })

        it('Multiple Event creation', async () => {
            let temp = ['test', 'ust Bannu', 8767978, 10, 4000]
            let temp2 = ['Web3 seminar', 'Central Liberary', 696969, 40, 1000]
            const { ticket, signer } = await deploy();
            await ticket.createEvent(...temp, { value: ethers.parseEther('0.1') });
            await ticket.createEvent(...temp2, { value: ethers.parseEther('0.1') });
            const tot = await ticket.totalEvents();
            expect(tot).to.equal(2n);
        })
    })

    describe('Ticket Purchasing and transferring', () => {
        it('ticket Purchasing and other correct info', async () => {
            let temp = ['test', 'ust Bannu', 8767978, 10, 4000]
            const { ticket, signer } = await deploy();
            await ticket.createEvent(...temp, { value: ethers.parseEther('0.1') });
            const event = await ticket.allEvents(0);
            const res = await ticket.purchaseTkt(0, 'test', 2, { value: ethers.parseEther('0.01') })
            const eventAfter = await ticket.allEvents(0);
            const tktsInAcc = await ticket.tktHolders(signer[0].address, 0)
            expect(Number(event[4])).to.equal(Number(eventAfter[4]) + 2);
            expect(Number(tktsInAcc)).to.equal(Number(event[4]) - Number(eventAfter[4]));
        })


        it('store ticket in address correctly by using the explicit function', async () => {
            let temp = ['Web3 Function', 'Central Library', 8767978, 10, 4000]
            const { ticket, signer } = await deploy();
            await ticket.createEvent(...temp, { value: ethers.parseEther('0.1') });
            const res = await ticket.purchaseTkt(0, 'Web3 Function', 10, { value: ethers.parseEther('0.04') })

            const tktsInAcc = await ticket.checkTickets(signer[0].address, 0);
            expect(Number(tktsInAcc)).to.equal(10);
        })

        it('reduce the totalTickets after purchasing tickets', async () => {
            let temp = ['Web3 Function', 'Central Library', 8767978, 10, 4000]
            const { ticket, signer } = await deploy();
            await ticket.createEvent(...temp, { value: ethers.parseEther('0.1') });
            const res = await ticket.purchaseTkt(0, 'Web3 Function', 5, { value: ethers.parseEther('0.04') })

            const e = await ticket.allEvents(0);
            expect(e[4]).to.equal(5n);
        })

        it('successful transfer ticket', async () => {
            let temp = ['Web3 Function', 'Central Library', 8767978, 10, 4000]
            const { ticket, signer } = await deploy();
            await ticket.createEvent(...temp, { value: ethers.parseEther('0.1') });
            const res = await ticket.purchaseTkt(0, 'Web3 Function', 7, { value: ethers.parseEther('0.04') })
            await ticket.TransferTickets(signer[1].address, 3, 0, 'Web3 Function');
            const tktsInAcc1 = await ticket.checkTickets(signer[0].address, 0);
            const tktsInAcc2 = await ticket.checkTickets(signer[1].address, 0);

            expect(Number(tktsInAcc1)).to.equal(4);
            expect(Number(tktsInAcc2)).to.equal(3);
        })
    });
    describe('MoneyWithdrawal', () => {
        // todo: sent amount to right person.
    })
});
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
    })

    describe('Ticket Purchasing', () => {
        it('ticket Purchasing and other correct info', async () => {
            let temp = ['test', 'ust Bannu', 8767978, 10, 4000]
            const { ticket, signer } = await deploy();
            const ress = await ticket.createEvent(...temp, { value: ethers.parseEther('0.1') });
            const event = await ticket.allEvents(0);
            const res = await ticket.purchaseTkt(0, 'test', 2, { value: ethers.parseEther('0.01') })
            const eventAfter = await ticket.allEvents(0);
            expect(Number(event[4])).to.equal(Number(eventAfter[4]) + 2);
        })
    })
});
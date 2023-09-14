const deploy = async () => {
    // const [deployer] = await ethers.getSigners();
    const MyContract = await ethers.getContractFactory('Ticket');
    const deployContract = await MyContract.deploy();
    let adr = await deployContract.target;
    console.log(adr);
}
deploy().then(() => {
    process.exit(0);
})
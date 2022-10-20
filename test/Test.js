const { expect, assert } = require("chai");
const { ethers } = require("hardhat");


describe("Crypto_ICO_testing", function () {
    let blitzContract;
    let blitzAddress;
    let icoContract;
    let icoAddress;
    let vestingContract;
    let vestingAddress;
    let timelockContract;
    let timelockAddress;
    let owner;
    let invest1;
    let invest2;
    let tokenWallet;
    let treasuryWallet;

    beforeEach(async function () {

        [owner, invest1, treasuryWallet] = await ethers.getSigners();
        console.log("Active Address:" + owner.address);

        const blitzs = await ethers.getContractFactory("BlitsToken");
        blitzContract = await blitzs.deploy(treasuryWallet.address);
        await blitzContract.deployed();
        blitzAddress = blitzContract.address;
        console.log(555);
        
        const Timelock = await ethers.getContractFactory("TimeLock");
        timelockContract = await Timelock.deploy(blitzAddress);
        await timelockContract.deployed();
        timelockAddress = timelockContract.address;

        console.log(313);
        const ICO = await ethers.getContractFactory("ICO");
        icoContract = await ICO.deploy( blitzAddress, timelockAddress, treasuryWallet.address);
        await icoContract.deployed();
        icoAddress = icoContract.address;

        var giveMinterRoleToIco = await blitzContract.grantRole("0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6", icoAddress );
        console.log("Done prereq");

        var addLockerICO = await timelockContract.changeLockers(icoAddress);

    })

    it("ICO Tests : ", async function () {

        
        var openSale = await icoContract.changeSaleStatus(true);

        var buyTokenFromBnb = await icoContract.connect(invest1).buyblitzFromNative(invest1.address, { value: ethers.utils.parseUnits("12","ether") });
        await buyTokenFromBnb.wait();

        expect(await timelockContract.lockAmount(invest1.address)).to.equal(ethers.utils.parseUnits("12","ether"));
        console.log(123);
        expect(await blitzContract.balanceOf(timelockContract.address)).to.equal(ethers.utils.parseUnits("12","ether"));
        console.log(234);

        var reserveWallet = await icoContract.reserveWallet();

        // expect(await ethers.provider.getBalance(reserveWallet)).to.equal(ethers.utils.parseUnits("12","ether"));
        console.log(await ethers.provider.getBalance(reserveWallet), "Reserve ICO balance");

        await expect(timelockContract.connect(invest1).releaseTokens()).to.be.reverted;

        console.log(await blitzContract.balanceOf(invest1.address));
        console.log(await blitzContract.balanceOf(timelockContract.address));

    });

});





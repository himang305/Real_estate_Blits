const { expect, assert } = require("chai");
const {ethers} = require("hardhat");

describe("FactoryCloneContract + Governor Contract Testing + Proposal testing", function () {
    it("Test to check deployment of contracts, creation of DAO, Deposit flow ", async function () {

        const [owner, addr1, addr2, addr3, addr4, treasury] = await ethers.getSigners();

        console.log("Active Address:" + owner.address);

        //  USDC Contract Launch
        const USDC = await ethers.getContractFactory("USDC");
        const usdcContract = await USDC.deploy();
        await usdcContract.deployed();
                console.log("USDC Address:" + usdcContract.address);

        let usdcTx = await usdcContract.mint(addr2.address, ethers.utils.parseUnits("12","ether"));
        await usdcTx.wait();

        let usdcTx1 = await usdcContract.mint(addr3.address, ethers.utils.parseUnits("24","ether"));
        await usdcTx1.wait();

        let usdcTx2 = await usdcContract.mint(addr4.address, ethers.utils.parseUnits("6","ether"));
        await usdcTx2.wait();
        
        // Factory Contract launch
        const Clone = await ethers.getContractFactory("FactoryCloneContract");
        const factoryContract = await Clone.deploy();
        await factoryContract.deployed();

        console.log("Active Address:" + addr1.address);

        // Deploy Token and Governor and create DAO test       
        console.log("Factory address:" + factoryContract.address);

        await factoryContract.approveDAO(addr1.address,1);
       
        const setTx = await factoryContract.connect(addr1).createDAO(
                1,
                "token1",
                "TK1",    
                10000,   // total investment = 10000 * 0.1 = 1000 ether
                ethers.utils.parseUnits("0.1","ether"),
                10,
                ethers.utils.parseUnits("50","ether"),
                treasury.address,
                usdcContract.address);
        await setTx.wait();        
        
       var governor_address = await factoryContract.governorArray(0);
       console.log("Governor address : " + governor_address);     
       console.log("Active Address:" + addr2.address);
       const GovernorProxy = await ethers.getContractAt("Governor", governor_address); 
       var token_address = await GovernorProxy.governanceToken();
       const TokenProxy = await ethers.getContractAt("Shares", token_address); 


       // Deposit Flow test 
       var usdc2Tx = await usdcContract.connect(addr2).approve(governor_address, ethers.utils.parseUnits("12","ether"));
       await usdc2Tx.wait(); 
       await GovernorProxy.connect(addr2).buyShares(ethers.utils.parseUnits("12","ether"));
       expect(await usdcContract.balanceOf(addr2.address)).to.equal(0);
       expect(await TokenProxy.balanceOf(addr2.address)).to.equal(ethers.utils.parseUnits("120","ether"));
       expect(await usdcContract.balanceOf(treasury.address)).to.equal(ethers.utils.parseUnits("12","ether"));

       var usdc2Tx = await usdcContract.connect(addr3).approve(governor_address, ethers.utils.parseUnits("24","ether"));
       await usdc2Tx.wait(); 
       await GovernorProxy.connect(addr3).buyShares(ethers.utils.parseUnits("24","ether"));
       expect(await usdcContract.balanceOf(addr3.address)).to.equal(0);
       expect(await usdcContract.balanceOf(treasury.address)).to.equal(ethers.utils.parseUnits("36","ether"));

       var usdc2Tx = await usdcContract.connect(addr4).approve(governor_address, ethers.utils.parseUnits("6","ether"));
       await usdc2Tx.wait(); 
       await GovernorProxy.connect(addr4).buyShares(ethers.utils.parseUnits("6","ether"));
       expect(await usdcContract.balanceOf(addr4.address)).to.equal(0);
       expect(await usdcContract.balanceOf(treasury.address)).to.equal(ethers.utils.parseUnits("42","ether"));


       console.log("Calculate Voting Power of members");
       let supply = await TokenProxy.totalSupply();
       expect(await TokenProxy.getVotes(addr2.address)).to.equal(ethers.utils.parseUnits("120","ether"));
       console.log("Voting power of address_2 = % ", await TokenProxy.getVotes(addr2.address) / supply );

       expect(await TokenProxy.getVotes(addr3.address)).to.equal(ethers.utils.parseUnits("240","ether"));
       console.log("Voting power of address_3 = % ", await TokenProxy.getVotes(addr3.address) / supply );

       expect(await TokenProxy.getVotes(addr4.address)).to.equal(ethers.utils.parseUnits("60","ether"));
       console.log("Voting power of address_4 = % ", await TokenProxy.getVotes(addr4.address) / supply );




       console.log(" Proposal tests Starts Here ");
       console.log(" ");
       console.log(" ");

       await GovernorProxy.connect(addr1).createProposal({
           proposalHash: "jbhj23bj2h3b2jh3bjh32j3bh",
           status: 0,
           proposalId: 0,
           options: [0,0,0,0],
           quorum: 10,
           threshold: 10,
           day: 10});   

        console.log("Creating a Proposal ; ",await GovernorProxy.getProposal(0));

        await GovernorProxy.connect(addr1).submitProposal(0,[0,1,0,0]);   
    
        console.log(" Submitting a Proposal : ",await GovernorProxy.getProposal(0));

        return;
     
    });
});
 




   
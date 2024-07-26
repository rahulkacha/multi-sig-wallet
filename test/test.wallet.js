const { expect } = require("chai");
const { ethers } = require("hardhat");
const sample = require("../sample");

describe("Multi-Signature Wallet Contract", function () {
  let Wallet;
  let wallet;
  let owner1, owner2, owner3, nonOwner;
  const sampleAddresses = sample.addresses;

  beforeEach(async function () {
    // Get the contract factory
    Wallet = await ethers.getContractFactory("Wallet");

    // Get the signers
    [owner1, owner2, owner3, nonOwner] = await ethers.getSigners();

    // Deploy the contract with correct number of required confirmations
    wallet = await Wallet.deploy(sampleAddresses);
    await wallet.deployed();
  });

  it("Should set the correct owners and required number of confirmations", async function () {
    const contractOwners = await wallet.getOwners();
    expect(contractOwners).to.deep.equal(sampleAddresses);
  });

  it("Should generate a transaction", async function () {
    await wallet.generateTransaction(
      owner2.address,
      ethers.utils.parseEther("1"),
      { gasLimit: 1000000 }
    );
    const transaction = await wallet.getTransaction(0);

    expect(transaction.to).to.equal(owner2.address);
    expect(transaction.value).to.equal(ethers.utils.parseEther("1"));
    expect(transaction.executed).to.be.false;
    expect(transaction.numConfirmations).to.equal(0);
  });

  it("Should confirm a transaction", async function () {
    await wallet.generateTransaction(
      owner2.address,
      ethers.utils.parseEther("1"),
      { gasLimit: 1000000 }
    );
    await wallet.connect(owner1).confirmTransaction(0);

    const transaction = await wallet.getTransaction(0);
    expect(transaction.numConfirmations).to.equal(1);
  });

  it("Should execute a transaction after required confirmations", async function () {
    await wallet.generateTransaction(
      owner2.address,
      ethers.utils.parseEther("1"),
      { gasLimit: 1000000 }
    );

    await wallet.connect(owner1).confirmTransaction(0);
    await wallet.connect(owner2).confirmTransaction(0);

    const transaction = await wallet.getTransaction(0);
    expect(transaction.executed).to.be.true;
  });

  it("Should not allow non-owners to confirm transactions", async function () {
    await wallet.generateTransaction(
      owner2.address,
      ethers.utils.parseEther("1"),
      { gasLimit: 1000000 }
    );
    await expect(
      wallet.connect(nonOwner).confirmTransaction(0)
    ).to.be.revertedWith("OwnableUnauthorizedAccount");
  });

  it("Should not allow double confirmation by the same owner", async function () {
    await wallet.generateTransaction(
      owner2.address,
      ethers.utils.parseEther("1")
    );
    await wallet.connect(owner1).confirmTransaction(0);
    await expect(
      wallet.connect(owner1).confirmTransaction(0)
    ).to.be.revertedWith("Transaction already confirmed");
  });

  it("Should not allow transaction execution if not enough confirmations", async function () {
    await wallet.generateTransaction(
      owner2.address,
      ethers.utils.parseEther("1"),
      { gasLimit: 1000000 }
    );
    await wallet.connect(owner1).confirmTransaction(0);
    await expect(wallet.executeTransaction(0)).to.be.revertedWith(
      "Transaction not confirmed"
    );
  });

  it("Should return all transactions", async function () {
    await wallet.generateTransaction(
      owner2.address,
      ethers.utils.parseEther("1"),
      { gasLimit: 1000000 }
    );
    await wallet.generateTransaction(
      owner1.address,
      ethers.utils.parseEther("2"),
      { gasLimit: 1000000 }
    );

    const [length, transactions] = await wallet.getAllTransactions();

    expect(length).to.equal(2);
    expect(transactions.length).to.equal(2);
  });

  it("Should handle edge cases for transaction generation", async function () {
    await expect(
      wallet.generateTransaction(
        ethers.constants.AddressZero,
        ethers.utils.parseEther("1"),
        { gasLimit: 1000000 }
      )
    ).to.be.revertedWith("Invalid owner address");
  });

  it("Should handle edge cases for transaction confirmation", async function () {
    await wallet.generateTransaction(
      owner2.address,
      ethers.utils.parseEther("1")
    );
    await wallet.connect(owner1).confirmTransaction(0);
    await expect(
      wallet.connect(owner1).confirmTransaction(0)
    ).to.be.revertedWith("Transaction already confirmed");
  });

  it("Should handle transaction execution failures", async function () {
    await wallet.generateTransaction(
      owner2.address,
      ethers.utils.parseEther("1"),
      { gasLimit: 1000000 }
    );
    await wallet.connect(owner1).confirmTransaction(0);
    await wallet.connect(owner2).confirmTransaction(0);
    await expect(wallet.executeTransaction(0)).to.be.revertedWith(
      "Transaction already executed"
    );
  });
});

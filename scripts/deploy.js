const hre = require("hardhat");
const sample = require("../sample");

async function main() {
  const owners = sample.addresses;

  const Wallet = await hre.ethers.getContractFactory("Wallet");
  const wallet = await Wallet.deploy(owners);

  await wallet.deployed();

  console.log(`Wallet deployed to ${wallet.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

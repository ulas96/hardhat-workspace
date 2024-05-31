const hre = require("hardhat");

async function main() {

  const publicCampaigns = await hre.ethers.deployContract("PublicCampaigns");

  await publicCampaigns.waitForDeployment();

  console.log(publicCampaigns.target);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

const hre = require("hardhat");

async function main() {
    const EXC = await hre.ethers.getContractFactory("Excelcium");
    const exc = await EXC.deploy();
    await exc.waitForDeployment();

    console.log(exc.target);
}


// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

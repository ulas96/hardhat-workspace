// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//

const hre = require("hardhat");

const gameAddr = "0xEe4240abA3C984203b9138888cFF7aAcfD5145aA" // previous: "0x1Ecd83cF22B941267a4b18C50B2371998a7f4Ebd"
const contractName = "RPS";

const tokenAddr = "0x696653050c71C252254696D154E0318D06376AB3"
const tokenName = "Excelcium";

async function main() {

    const game = await hre.ethers.getContractAt(contractName, gameAddr);

    const token = await hre.ethers.getContractAt(tokenName, tokenAddr);

    const startBalance = await token.balanceOf("0x002C65Be429d430DF090f2DC847df3b468676029");

    console.log(startBalance);

    const approveTx = await token.approve(tokenAddr, 10);
    await approveTx.wait();

    const tx = await game.createGame(1);
    await tx.wait();

    const endBalance = await token.balanceOf("0x002C65Be429d430DF090f2DC847df3b468676029");
    console.log(endBalance);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
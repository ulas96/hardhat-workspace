// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//

const hre = require("hardhat");

const gameAddr = "0x7F3B51891126fa305154E3E35cD64Ed7fe8B3c1F" // previous: "0x811DAfdc01C05277e70f887Eb499AB2f4Ba9501a"
const gameName = "RPS";

const tokenAddr = "0x9e6969254D73Eda498375B079D8bE540FB42fea7" // previous: "0x696653050c71C252254696D154E0318D06376AB3"
const tokenName = "Excelcium";


async function main() {

    const game = await hre.ethers.getContractAt(gameName, gameAddr);

    const token = await hre.ethers.getContractAt(tokenName, tokenAddr);


    const startBalance = await token.balanceOf("0x002C65Be429d430DF090f2DC847df3b468676029");

    console.log(startBalance);

    const approveTx = await token.approve(gameAddr, 10);
    await approveTx.wait();

    console.log("Approved");

    const transferTx = await game.createGame(1, 10);
    await transferTx.wait();

    console.log("Game Created");

    const endBalance = await token.balanceOf("0x002C65Be429d430DF090f2DC847df3b468676029");
    console.log(endBalance);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
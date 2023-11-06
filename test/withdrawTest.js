const hre = require("hardhat");
const gameAddr = "0x3853B8fc287C90970ca5fa9d6A7599422C4BAF48" // previous: "0x2f35Ed12EF0bcfb6D8d61324a4b4BE0fA9dc1bd6"
const gameName = "RPS";


const tokenAddr = "0x9e6969254D73Eda498375B079D8bE540FB42fea7"; // previous: "0x696653050c71C252254696D154E0318D06376AB3"
const tokenName = "Excelcium";

async function main() {

    const game = await hre.ethers.getContractAt(gameName, gameAddr);

    const token = await hre.ethers.getContractAt(tokenName, tokenAddr);


    const startBalance = await token.balanceOf("0x002C65Be429d430DF090f2DC847df3b468676029");

    console.log(startBalance);


    const transferTx = await game.claimRewards(5);
    await transferTx.wait();

    console.log("Rewards Claimed");

    const endBalance = await token.balanceOf("0x002C65Be429d430DF090f2DC847df3b468676029");
    console.log(endBalance);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
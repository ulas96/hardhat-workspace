// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//

const hre = require("hardhat");

const gameAddr = "0x35e199C2a34701DdFFb0003E2f38eAbdA540AbdF" // previous: "0x1Ecd83cF22B941267a4b18C50B2371998a7f4Ebd"
const gameName = "RPS";

const tokenAddr = "0x482FB70C0bb85622c1d59e475b9D82721B61BAA7" // previous: "0x696653050c71C252254696D154E0318D06376AB3"
const tokenName = "Excelcium";

const contractAddr = "0x873289a1aD6Cf024B927bd13bd183B264d274c68";
const contractName = "Bucket";

async function main() {

    const game = await hre.ethers.getContractAt(gameName, gameAddr);

    const token = await hre.ethers.getContractAt(tokenName, tokenAddr);

    const bucket = await hre.ethers.getContractAt(contractName, contractAddr);

    const startBalance = await token.balanceOf("0x002C65Be429d430DF090f2DC847df3b468676029");

    console.log(startBalance);

    const approveTx = await token.approve("0x873289a1aD6Cf024B927bd13bd183B264d274c68", 10);
    await approveTx.wait();

    console.log("Approved");

    const transferTx = await bucket.drop(tokenAddr,10);
    await transferTx.wait();

    console.log("Dropped");

    const endBalance = await token.balanceOf("0x002C65Be429d430DF090f2DC847df3b468676029");
    console.log(endBalance);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
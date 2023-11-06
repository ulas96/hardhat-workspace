// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//

const hre = require("hardhat");

const gameAddr = "0xD70d05A5509236A8CD1D0b2efD6689043bb9B6A5";

const tokenAddr = "0x482FB70C0bb85622c1d59e475b9D82721B61BAA7" // previous: "0x696653050c71C252254696D154E0318D06376AB3"
const tokenName = "Excelcium";

const personalAddress = "0x002C65Be429d430DF090f2DC847df3b468676029";
async function main() {


    const token = await hre.ethers.getContractAt(tokenName, tokenAddr);

    // const bucket = await hre.ethers.getContractAt(contractName, contractAddr);

    const startBalance = await token.balanceOf(personalAddress);

    console.log(startBalance);

    const approveTx = await token.approve(gameAddr, 11);
    await approveTx.wait();

    console.log("Approved");

    const allowance = await token.allowance(personalAddress, gameAddr)

    console.log(allowance);

    const endBalance = await token.balanceOf(personalAddress);
    console.log(endBalance);

    const transferTx = await token.transferFrom(personalAddress, gameAddr, 10);
    await transferTx.wait();

    console.log("Transferred");

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
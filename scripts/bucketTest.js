// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//

const hre = require("hardhat");


const tokenAddr = "0x9e6969254D73Eda498375B079D8bE540FB42fea7"
const tokenName = "Excelcium";

const contractAddr = "0xc2Baf4328C9FEf57f1e819006c78cA72a262ca15";
const contractName = "Bucket";

const personalAddress = "0x002C65Be429d430DF090f2DC847df3b468676029";
async function main() {


    const token = await hre.ethers.getContractAt(tokenName, tokenAddr);

    const bucket = await hre.ethers.getContractAt(contractName, contractAddr);

    const startBalance = await token.balanceOf(personalAddress);

    console.log(startBalance);

    const approveTx = await token.approve(contractAddr, 10);
    await approveTx.wait();

    console.log("Approved");

    const transferTx = await bucket.drop(10);
    await transferTx.wait();

    console.log("Dropped");

    const endBalance = await token.balanceOf(personalAddress);
    console.log(endBalance);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
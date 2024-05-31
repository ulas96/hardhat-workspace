const hre = require("hardhat");
const { contractAddr, contractName } = require("../scripts/constants");

async function main() {

    const contract = await hre.ethers.getContractAt(contractName, contractAddr);

    const campaignsStart = await contract.getPublicCampaigns();

    console.log(campaignsStart.length); 

    const donationDeadline = new Date('2024-06-01T00:00:00Z') // Replace with your date
    const votingDeadline = new Date('2024-06-03T00:00:00Z')// Replace with your date

    console.log(donationDeadline.getTime(), votingDeadline.getTime());
    const createCampaignTx = await contract.createCampaign(donationDeadline.getTime()/1000, votingDeadline.getTime()/1000, 1, ["why?", "how?", "what?"], 10);
    await createCampaignTx.wait()

    const campaignsEnd = await contract.getPublicCampaigns();

    console.log(campaignsEnd.length);

   
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
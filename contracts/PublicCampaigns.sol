

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;


interface Uruk {
    function isMember(address _address) external view returns(bool); 

    function getArticleCount() external view returns(uint256);
}

contract PublicCampaigns {

    Uruk uruk = Uruk(0x9C4577b3a6E179CbffDD7C6F08d7c0E4478928d8);
    
    struct Participant {
        address participantAddress;
        string[] answers;
        uint256 votes;
        bool isRewarded;
    }

    struct Donation {
        address donatorAddress;
        uint256 donationAmount;
    }

    struct Vote {
        address voterAddress;
        uint256 vote;
    }

    struct PublicCampaign {
        uint256 id;
        uint256 donationDeadline;
        uint256 votingDeadline;
        uint256 articleId;
        string[] questions;
        Participant[] participants;
        Donation[] donations;
        Vote[] votes;
        uint256 donation;
        uint256 maxReward;
        uint256 remainingReward;
    }

    PublicCampaign[] public publicCampaigns;

    function createCampaign(uint256 _donationDeadline, uint256 _votingDeadline, uint256 _articleId, string[] memory _questions, uint256 _maxReward) public  {
        require(uruk.isMember(msg.sender));
        require(_donationDeadline > block.timestamp);
        require(_votingDeadline > _donationDeadline);
        PublicCampaign storage newCampaign = publicCampaigns.push();
        newCampaign.id = publicCampaigns.length;
        newCampaign.donationDeadline = _donationDeadline;
        newCampaign.votingDeadline = _votingDeadline;
        newCampaign.articleId = _articleId;
        newCampaign.questions = _questions;
        newCampaign.donation = 0;
        newCampaign.maxReward = _maxReward;
        newCampaign.remainingReward = 0;
    }

    function donateCampaign(uint256 _donationAmount, uint256 _campaignId) external payable {
        require(_donationAmount >= msg.value);
        require(uruk.isMember(msg.sender));
        require(publicCampaigns.length >= _campaignId);
        require(publicCampaigns[_campaignId].donationDeadline > block.timestamp);
        publicCampaigns[_campaignId].donations.push(Donation(msg.sender, _donationAmount));
        publicCampaigns[_campaignId].donation += _donationAmount;
        publicCampaigns[_campaignId].remainingReward += _donationAmount;
    }
    
    function participateCampaign(uint256 _campaignId, string[] memory _answers) public {
        require(uruk.isMember(msg.sender));
        require(publicCampaigns.length >= _campaignId, "Campaign doesn't exist");
        require(_answers.length == publicCampaigns[_campaignId - 1].questions.length);
        PublicCampaign storage currentCampaign = publicCampaigns[_campaignId - 1];
        Participant memory currentParticipant = Participant(msg.sender, _answers,0 , false);
        currentCampaign.participants.push(currentParticipant);
    }

    

    function rewardParticipant(uint256 _campaignId, uint256 _participantId) public {
        require(uruk.isMember(msg.sender));
        require(publicCampaigns[_campaignId-1].remainingReward > 0);
        require(publicCampaigns[_campaignId-1].participants.length >= _participantId, "Participant doesn't exist");
        require(publicCampaigns[_campaignId-1].participants[_participantId-1].isRewarded == false, "Participant already rewarded");
        publicCampaigns[_campaignId-1].participants[_participantId-1].isRewarded == true;
        publicCampaigns[_campaignId-1].remainingReward -= publicCampaigns[_campaignId-1].maxReward;
    }

    function claimReward(uint256 _campaignId) public {
        require(uruk.isMember(msg.sender));
        require(publicCampaigns[_campaignId-1].participants.length > 0, "No participants");
        for(uint i = 0; i < publicCampaigns[_campaignId-1].participants.length; i++) {
            if(publicCampaigns[_campaignId-1].participants[i].participantAddress == msg.sender) {
                require(publicCampaigns[_campaignId-1].participants[i].isRewarded == true, "Not rewarded");
                payable(msg.sender).transfer(publicCampaigns[_campaignId-1].maxReward);
            }
        }
    }

    function getCompaigns() public view returns(PublicCampaign[] memory) {
        return publicCampaigns;
    }

}
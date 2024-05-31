

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;


interface Uruk {
    function isMember(address _address) external view returns(bool); 

    function getArticleCount() external view returns(uint256);
}

contract PublicCampaigns {

    Uruk uruk = Uruk(0xd9447c058938D8Fcf917cDBC3544f089D8e12Eb6);
    
    struct Participant {
        address participantAddress;
        uint256 id;
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
        require(_donationDeadline > block.timestamp, "Donation deadline should be in the future");
        require(_votingDeadline > _donationDeadline, "Voting dealine should be after donation deadline");
        require(_articleId > 0);
        require(uruk.getArticleCount() >= _articleId);
        require(_maxReward > 0);
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
        for (uint256 i = 0; i < currentCampaign.participants.length; i++) {
            require(currentCampaign.participants[i].participantAddress == msg.sender, "You already participated to this campaign.");
        } 
        Participant memory currentParticipant = Participant(msg.sender,currentCampaign.participants.length + 1,_answers,0 , false);
        currentCampaign.participants.push(currentParticipant);
    }


    function vote(uint256 _campaignId, uint256 _participantId) public {
        require(uruk.isMember(msg.sender));
        require(publicCampaigns.length >= _campaignId);
        PublicCampaign storage currentCampaign = publicCampaigns[_campaignId - 1];
        require(currentCampaign.participants.length >= _participantId);
        require(currentCampaign.votingDeadline > block.timestamp);
        for (uint256 i = 0; i < currentCampaign.votes.length; i++) {
            require(currentCampaign.votes[i].voterAddress == msg.sender, "You already voted to this campaign.");
        }
        Vote memory currentVote = Vote(msg.sender, _participantId);
        currentCampaign.votes.push(currentVote);
        currentCampaign.participants[_participantId].votes += 1;
    }


    function decideWinners(uint256 _campaignId) public view {
        require(uruk.isMember(msg.sender));
        require(publicCampaigns.length >= _campaignId, "Campaign doesn't exist");
        PublicCampaign memory currentCampaign = publicCampaigns[_campaignId - 1];
        require(currentCampaign.votingDeadline < block.timestamp, "Voting deadline not reached");
        currentCampaign.participants = bubbleSort(currentCampaign.participants);
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

    function getPublicCampaigns() public view returns(PublicCampaign[] memory) {
        return publicCampaigns;
    }

    function bubbleSort(Participant[] memory arr) public pure returns (Participant[] memory) {
        uint n = arr.length;
        for (uint i = 0; i < n - 1; i++) {
            for (uint j = 0; j < n - i - 1; j++) {
                if (arr[j].votes > arr[j + 1].votes) {
                    (arr[j], arr[j + 1]) = (arr[j + 1], arr[j]);
                }
            }
        }
        
        return arr;
    }

}
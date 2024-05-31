

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract SimpleVoting {

    
    struct Participant {
        address participantAddress;
        uint256 id;
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
        uint256 donation;
        uint256 remainingReward;
        Participant[] participants;
        Votes[] votes;
    }

    PublicCampaign[] public publicCampaigns;

    function createCampaign(uint256 _donationDeadline, uint256 _votingDeadline, uint256 _articleId, string[] memory _questions, uint256 _maxReward) public  {
        PublicCampaign storage newCampaign = publicCampaigns.push();
        newCampaign.id = publicCampaigns.length;
        newCampaign.donation = 0;
        newCampaign.remainingReward = 0;
    }

    function donateCampaign(uint256 _donationAmount, uint256 _campaignId) external payable {
        require(_donationAmount >= msg.value);
        require(publicCampaigns.length >= _campaignId);

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
//SPDX-License-Identifier:MIT
pragma solidity ^0.8.30;

contract CrowdFunding {
    struct Campaign {
        string description;
        uint256 deadline;
        uint256 goal;
        uint256 raised;
        address founder;
        bool iscomp;
    }

    struct User {
        string name;
        address addr;
    }

    uint256 public campid = 0;
    mapping(address => bool) public users;
    mapping(uint256 => Campaign) public campaigns;
    mapping(address => Campaign[]) public userscamp;
    mapping(uint256 => mapping(address => uint256)) public contributions;

    function signup() public {
        require(users[msg.sender] == false, "User is already registered");
        users[msg.sender] = true;
    }

    
    function createcampaign(string memory des, uint256 durationInSeconds, uint256 g) public {
        campaigns[campid] = Campaign({
            description: des,
            deadline: block.timestamp + durationInSeconds,
            goal: g,
            raised: 0,
            founder: msg.sender,
            iscomp: false
        });
        campid++;
    }

    function fundcampaign(uint256 id) public payable {
        Campaign storage cp = campaigns[id];
        require(cp.raised != cp.goal, "the campaign has reached its goal");
        require(cp.raised + msg.value <= cp.goal, "Funding exceeds goal");
        require(block.timestamp <= cp.deadline, "Campaign deadline has passed");
        cp.raised += msg.value;
        contributions[id][msg.sender] += msg.value;
    }

    function getAllCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory cpp = new Campaign[](campid);
        for (uint256 i = 0; i < campid; i++) {
            cpp[i] = campaigns[i];
        }
        return cpp;
    }

    function withdrawfunds(uint256 id) public {
        Campaign storage cp = campaigns[id];
        require(msg.sender == cp.founder, "only founder can withdraw funds");
        require(cp.raised >= cp.goal, "Funding goal not met");
        uint256 amount = cp.raised;
        cp.raised = 0;
        cp.iscomp = true;
        payable(cp.founder).transfer(amount);
    }

    function refund(uint256 id) public {
        Campaign storage cp = campaigns[id];
        require(block.timestamp > cp.deadline, "Campaign not ended yet");
        require(cp.raised < cp.goal, "Funding goal was met");
        uint256 amount = contributions[id][msg.sender];
        require(amount > 0, "No contribution to refund");

        contributions[id][msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}

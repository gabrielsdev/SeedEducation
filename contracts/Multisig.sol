// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Institutions.sol";

contract Multisig {    

    mapping (bytes32 => address[]) private addressesThatVotedIn;
    mapping (bytes32 => mapping (address => uint)) private indexOfAddressesThatVotedIn; // 1-based indexing. 0 means non-existent

    bytes32[] private pollList;
    mapping (bytes32 => uint) private indexOfPollList;

    string private constant CHANGE_REQUIREMENT = "CHANGE_REQUIREMENT";

    bool private qualifiedMajority; // true: qualified majority, greater than 2/3; false: simple majority, greater than 50%;
    
    address private institutionContractAddress;

    event Voted(
        bytes32 pollId,
        bool voted
    );

    event VoteCanceled(
        bytes32 pollId,
        bool voteCanceled
    );

    event Executed(
        string opName,
        address lastSender,
        bytes32 pollId
    );

    modifier onlyAdmin() {
        require(Institutions(institutionContractAddress).isAuthorizedAdmin(msg.sender), "Sender not authorized");
        _;
    }

    constructor(address _institutionContractAddress) {
        institutionContractAddress = _institutionContractAddress;
        qualifiedMajority = true;
    }

    function getTotalVotesInPoll(bytes32 pollId) public view returns (uint){
        return addressesThatVotedIn[pollId].length;
    }

    function getPollId(string memory opName) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(opName));
    }

    function getPollList() public view returns (bytes32[] memory){
        return pollList;
    }   

    function changeMajorityRequirement() external onlyAdmin {
        bytes32 pollId = getPollId(CHANGE_REQUIREMENT);
        if(voteAndVerify(pollId)){
            qualifiedMajority = !qualifiedMajority;
            deletePollId(pollId);
            emit Executed(CHANGE_REQUIREMENT, msg.sender, pollId);
        }
    }

    function isMajorityAchieved(bytes32 pollId) public view returns (bool){
        uint _votes = getTotalVotesInPoll(pollId);
        if (qualifiedMajority) {
            if (_votes > ((Institutions(institutionContractAddress).getAdminsInstitutionsList().length * 2)/3)) {
                return true;
            }
        } else if (_votes > (Institutions(institutionContractAddress).getAdminsInstitutionsList().length / 2)) {
            return true;
        }
        return false;
    }

    function alreadyVoted(address sender, bytes32 pollId) public view returns (bool) {
        if (indexOfAddressesThatVotedIn[pollId][sender] == 0) {
            return false;
        }
        return true;
    }

    function noVotesFor(bytes32 pollId) public view returns (bool) {
        if (getTotalVotesInPoll(pollId) == 0){
            return true;
        }
        return false;
    }

    // Every time this method is called there will be a check if the majority has been reached,
    // as the majority can also be reached after removing an administrator 
    // (in addition to the most commom situation which is a new vote, of course).
    // Thus, by performing an extra call, the user executes the pending action.
    function voteAndVerify(bytes32 pollId) internal returns (bool) {
        address sender = msg.sender;
        if (!alreadyVoted(sender, pollId)) { // 1-based index
            if (noVotesFor(pollId)) {
                indexOfPollList[pollId] = pollList.length;
                pollList.push(pollId);
            }
            addressesThatVotedIn[pollId].push(sender);
            indexOfAddressesThatVotedIn[pollId][sender] = getTotalVotesInPoll(pollId);
            emit Voted(pollId, true);
        } 
        else {
            emit Voted(pollId, false);
        }
        return isMajorityAchieved(pollId);
    }

    function cancelVote(bytes32 pollId) external onlyAdmin {
        address sender = msg.sender;
        uint index = indexOfAddressesThatVotedIn[pollId][sender];

        if (index > 0 && index <= getTotalVotesInPoll(pollId)) {
            // move last item into index being vacated (unless we are dealing with last index)
            if (index != getTotalVotesInPoll(pollId)) {
                address lastAddress = addressesThatVotedIn[pollId][getTotalVotesInPoll(pollId) - 1];
                addressesThatVotedIn[pollId][index - 1] = lastAddress;
                indexOfAddressesThatVotedIn[pollId][lastAddress] = index;
            }

            // shrink array
            addressesThatVotedIn[pollId].pop();
            indexOfAddressesThatVotedIn[pollId][sender] = 0;
            emit VoteCanceled(pollId, true);
            if (noVotesFor(pollId)){
                deletePollId(pollId);
            }
        }
        emit VoteCanceled(pollId, false);
    }

    function deletePollId(bytes32 pollId) internal {
        for (uint i = 0; i < getTotalVotesInPoll(pollId); i++) {
            indexOfAddressesThatVotedIn[pollId][addressesThatVotedIn[pollId][i]] = 0;
        }
        delete addressesThatVotedIn[pollId];

        uint index = indexOfPollList[pollId];
        uint lastPosition = pollList.length - 1;
        if (index != lastPosition) {
            bytes32 lastPollId = pollList[lastPosition];
            pollList[index] = lastPollId;
            indexOfPollList[lastPollId] = index;
        }
        pollList.pop();
        indexOfPollList[pollId] = 0;
    }
}
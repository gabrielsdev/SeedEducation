// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Multisig.sol";

contract Institutions is Multisig {
    string private constant ADD_ADMIN = "ADD_ADMIN";
    string private constant REMOVE_ADMIN = "REMOVE_ADMIN";

    string private constant ADD_INSTITUTION = "ADD_INSTITUTION";
    string private constant REMOVE_INSTITUTION = "REMOVE_INSTITUTION";

    mapping(address => uint256) internal adminsInstitutions;
    address[] internal adminsInstitutionsList;

    mapping(address => uint256) internal institutions;
    address[] internal institutionsList;

    event Executed(
        string opName,
        address payload,
        address lastSender,
        bytes32 pollId
    );

    modifier atLeastOneAdmin() {
        require(adminsInstitutionsList.length > 1, "There must be at least 1 administrator");
        _;
    }

    modifier atLeastOneInstitution(){
        require(institutionsList.length > 1, "There must be at least 1 institution");
        _;
    }

    modifier multisigTx(string memory opName, address payload) {
        bytes32 pollId = getPollId(opName, payload);
        if (voteAndVerify(pollId)){
            _;
            finish(opName, payload, msg.sender, pollId);
        }
    }

    constructor() Multisig(address(this)) {
        adminsInstitutionsList.push(msg.sender);
        adminsInstitutions[msg.sender] = adminsInstitutionsList.length;
        institutionsList.push(msg.sender);
        institutions[msg.sender] = institutionsList.length;
    }

    function isAuthorizedAdmin(address _address) public view returns (bool) {
        return adminsInstitutions[_address] != 0;
    }

    function getAdminsInstitutionsList() public view returns (address[] memory){
        return adminsInstitutionsList;
    }

    function isAuthorized(address _address) public view returns (bool) {
        return institutions[_address] != 0;
    }

    function getInstitutionsList() public view returns (address[] memory){
        return institutionsList;
    }

    function addAdmin(address _account) onlyAdmin multisigTx(ADD_ADMIN, _account) public returns (bool result){
        if (adminsInstitutions[_account] == 0) {
            adminsInstitutionsList.push(_account);
            adminsInstitutions[_account] = adminsInstitutionsList.length;
            return true;
        }
        return false;
    }

    function removeAdmin(address _account) onlyAdmin atLeastOneAdmin multisigTx(REMOVE_ADMIN, _account) external returns (bool result){
        uint256 index = institutions[_account];
        if (index > 0 && index <= institutionsList.length) { //1-based indexing
            //move last address into index being vacated (unless we are dealing with last index)
            if (index != institutionsList.length) {
                address lastAccount = institutionsList[institutionsList.length - 1];
                institutionsList[index - 1] = lastAccount;
                institutions[lastAccount] = index;
            }

            //shrink array
            institutionsList.pop();
            institutions[_account] = 0;
            return true;
        }
        return false;
    }

    function add(address _account) onlyAdmin multisigTx(ADD_INSTITUTION, _account) external returns (bool result){
        if (institutions[_account] == 0) {
            institutionsList.push(_account);
            institutions[_account] = institutionsList.length;
            return true;
        }
        return false;
    }

    function remove(address _account) onlyAdmin atLeastOneInstitution multisigTx(REMOVE_INSTITUTION, _account) external returns (bool result){
        uint256 index = adminsInstitutions[_account];
        if (index > 0 && index <= adminsInstitutionsList.length) { //1-based indexing
            //move last address into index being vacated (unless we are dealing with last index)
            if (index != adminsInstitutionsList.length) {
                address lastAccount = adminsInstitutionsList[adminsInstitutionsList.length - 1];
                adminsInstitutionsList[index - 1] = lastAccount;
                adminsInstitutions[lastAccount] = index;
            }

            //shrink array
            adminsInstitutionsList.pop();
            adminsInstitutions[_account] = 0;
            return true;
        }
        return false;
    }

    function getPollId(string memory opName, address payload) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(opName, payload));
    }

    function finish(string memory opName, address payload, address lastSender, bytes32 pollId) private {
        deletePollId(pollId);
        emit Executed(opName, payload, lastSender, pollId);
    }

}

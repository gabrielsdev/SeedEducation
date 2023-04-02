// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import ".Token1155.sol";
import "./Institutions.sol";



contract Operations {

    mapping(uint256 => uint256)  public balance;
    address public institutionContractAddress;
    address tokenContract;
    constructor(address _tokenContract ) {
            tokenAddress = _tokenContract;   
    }
    
    modifier onlyAdmin() {
        require(Institutions(institutionContractAddress).isAuthorizedAdmin(msg.sender), "Sender not authorized");
        _;
    }

    constructor(address _institutionContractAddress) {
        institutionContractAddress = _institutionContractAddress;
    }
    function BuyToken(uint256 id, address payable _to)public payable{
        require(msg.value >= tokenPrice);
        numberToken = msg.value / tokenPrice;
        bool sent = _to.send(msg.value);
        require(sent, "Failed to send Ether");
        Token(tokenContract).safeTransferFrom(Token(tokenContract).TokenCreator[id],msg.sender,id,numberToken,"");
    }
    function Lucro(uint256 id,address payable _to) public payable{
        require(address(this)== _to);
        require(Token(tokenContract).TokenCreator[id]== msg.sender);
        balance[id] += msg.value;
        bool sent = _to.send();
        require(sent, "Failed to send Ether");
    }

    function Withdraw(uint256 id,uint256 amounts,address payable _to) public {
        require(amount <= Token(tokenContract).balanceOf(msg.sender,id),"withdrawal greater than balance" );
        lucro = balance[id] / Token(tokenContract).tokenTotal[id];
        Token(tokenContract).burn(_to,id,amounts);
        receber = Token(tokenContract).tokenPrice(id) * lucro;
        balance -= receber;
        bool sent = _to.send(receber);
        require(sent, "Failed to send Ether");
    }
}
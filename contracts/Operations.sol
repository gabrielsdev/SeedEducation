// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./Token1155.sol";
import "./Institutions.sol";



contract Operations {

    mapping(uint256 => uint256)  public balance;

    address public tokenContract;
    constructor(address _tokenContract ) {
            tokenContract = _tokenContract;   
    }
    

    
    function BuyToken(uint256 id, address payable _to)public payable{
        require(msg.value >= Token(tokenContract).tokenPrice(id));
        uint256 numberToken = msg.value / Token(tokenContract).tokenPrice(id);
        bool sent = _to.send(msg.value);
        require(sent, "Failed to send Ether");
        Token(tokenContract).safeTransferFrom(Token(tokenContract).TokenCreator(id),msg.sender,id,numberToken,"");
    }
    function Lucro(uint256 id,address payable _to) public payable{
        require(address(this)== _to);
        require(Token(tokenContract).TokenCreator(id)== msg.sender);
        balance[id] += msg.value;
        bool sent = _to.send(msg.value);
        require(sent, "Failed to send Ether");
    }

    function Withdraw(uint256 id,uint256 amounts,address payable _to) public {
        require(amounts <= Token(tokenContract).balanceOf(msg.sender,id),"withdrawal greater than balance" );
        uint256 lucro = balance[id] / Token(tokenContract).tokenTotal(id);
        Token(tokenContract).burn(_to,id,amounts);
        uint256 receber = Token(tokenContract).tokenPrice(id) * lucro;
        balance[id] -= receber;
        bool sent = _to.send(receber);
        require(sent, "Failed to send Ether");
    }
    receive() external payable {}
    function teste() public  view returns (uint256) {
        return address(this).balance;
    }
}
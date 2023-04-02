// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./institutions.sol";

contract Token is ERC1155, Ownable  {
    mapping(uint256 => string) public hashOfDoc;   
    mapping(uint256 => address) public TokenCreator;
    mapping(uint256 => uint256) public tokenPrice;
    mapping(uint256 => uint256) public tokenTotal;
    address public institutions;    

    constructor(address _institutions) ERC1155("") {
        institutions = _institutions;
    }

    modifier OwnerOfToken(uint256 id){
        require(msg.sender == TokenCreator[id]);
        _;
    }
    modifier Ownable(address _owner){
        require(Institutions(institutions).isAuthorized(_owner));
        _;
    }


    function setURI(string memory newuri) public  {
        _setURI(newuri);
    }

    function mint( uint256 id, uint256 amount,uint256 price, string memory hash)
        Ownable(msg.sender)
        public
    {
        tokenPrice[id] = price;
        createhashOfDoc(id, hash);
        _mint(msg.sender, id, amount,"");
        tokenTotal[id] +=  amount;
        
    }    
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        Ownable()
        public       
    {
        //_mintBatch(to, ids, amounts, data);
    }
    function createhashOfDoc(uint256 id, string memory hash) internal {
        hashOfDoc[id] = hash;
    }   
    function uri(uint256 id) public view override virtual  returns (string memory) {
        return hashOfDoc[id];
    }
    function burn( address account, uint256 id, uint256 amount) public onlyOwner{
        _burn( account,  id,  amount);
    }
}
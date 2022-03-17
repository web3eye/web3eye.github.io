// SPDX-License-Identifier: None

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract GenesisCoder is Ownable, ERC721 {
    using Strings for uint256;
    using SafeMath for uint256;

    uint256 public constant mintNum = 2;
    uint256 public constant mintPrice = 0;
    uint256 public constant maxTotalSupply = 100000;
    
    string public baseURI = "";
    uint256 public totalSupply = 0;
    bool public enableSale = false;
    bool public allowTransfer = true;

    event Minted(address indexed _user, uint256 indexed _tokenId, string _tokenURI);

    constructor() ERC721("Genesis Coder", "GC") {}

    function setBaseURI(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }

    function setEnableSale(bool _enableSale) external onlyOwner {
        enableSale = _enableSale;
    }

    function setAllowTransfer(bool _allowTransfer) external onlyOwner {
        allowTransfer = _allowTransfer;
    }

    function withdraw(address payable _addr, uint256 _amount) external onlyOwner {
        require(_amount <= address(this).balance, "Insufficient balance.");
        payable(_addr).transfer(_amount);
    }
    
    function _batchMint(address _addr, uint256 _num) private {
        require(totalSupply.add(_num) <= maxTotalSupply, "Not enough tokens left.");

        uint256 tokenId = totalSupply;
        for(uint i = 0; i < _num; i++) {
            tokenId = tokenId.add(1);

            totalSupply = totalSupply.add(1);
            _safeMint(_addr, tokenId);

            emit Minted(_addr, tokenId, tokenURI(tokenId));
        }
    }

    function publicMint(uint256 _num) external payable {
        require(enableSale, "Sale is not active.");
        require(_num > 0 && _num <= mintNum, "Too many tokens.");
        require(msg.value >= mintPrice.mul(_num), "Insufficient payment.");

        _batchMint(msg.sender, _num);
    }
    
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, "/", tokenId.toString())) : "";
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        require(allowTransfer, "Transfer error.");
    }
}

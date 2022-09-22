// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
// @vertion: v1.0.4
// Author Julio Vinachi
/// @custom:security-contact jv@topacio.trade
contract NFT is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Burnable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    uint public maxWalletAmount;
    mapping(address => bool) public isMaxTxExempt;
    address public pair;
    address private owner;
    // Openzeppelin variables
    mapping(address => uint256) private _administradores;
    mapping(address => mapping(address => uint256)) private _allowances;

    /**
     * @dev Throws if called by any account other than the owner.
     */
    
    modifier onlyOwner(){
        require(msg.sender == owner,"you are not the owner contract...");
        _;
    }

    modifier onlyAdministrator() {
         require(_administradores[msg.sender]!=0,"you are not administrator");
        _;
    }

    constructor() ERC721("Topacio NFT Collections", "TOPACIONFT") {
        _administradores[msg.sender] = 1;
        owner = msg.sender;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://ipfs.io/ipfs/";
    }

    function getContract() public view returns(address){
        return address(this);
    }

    function safeMint(address to, string memory uri) public onlyAdministrator {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }
    
    function changeOwner(address _owner) public onlyOwner{
        owner = _owner;
    }
    
    function addAdmin(address admin) public onlyOwner{
        _administradores[admin]=1;
    }

    function removeAdmin(address admin) public onlyOwner {
        delete(_administradores[admin]);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        require(isMaxTxExempt[to] || balanceOf(to) + 1 <= maxWalletAmount, "Max Wallet Limit Exceeds!");

        super._beforeTokenTransfer(from, to, tokenId);
    }

    


    function burnNFT(uint256 tokenId) public {
        super._approve(address(0),tokenId);
        //emit Transfer(msg.sender, address(0), tokenId);
        super._burn(tokenId);
    }
    
    function _burn(uint256 tokenId) internal override(ERC721,ERC721URIStorage) {
        // super._approve(address(0),tokenId);
        // super._clearApproval(msg.sender, tokenId);
        // super._removeTokenFrom(msg.sender, tokenId);
        // emit Transfer(msg.sender, address(0), tokenId);
        require(_isApprovedOrOwner(msg.sender, tokenId));
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function updateTokenURI(
        uint256 tokenId, 
        string memory _tokenURI
    ) external onlyAdministrator {
        _setTokenURI(tokenId, _tokenURI);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function setMaxWallet(uint256 amountLimit) public onlyAdministrator {
        maxWalletAmount = amountLimit;
    }

    function setMaxWalletPercentage(uint256 percentage) public onlyAdministrator {
        maxWalletAmount = (totalSupply() * percentage) / 10000;
    }

    function setMaxTxExempt(address account, bool value) external onlyAdministrator {
        isMaxTxExempt[account] = value;
    }
}

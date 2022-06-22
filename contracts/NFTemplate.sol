// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

//import "ERC721Enumerable.sol";
 import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

 import "@openzeppelin/contracts/access/Ownable.sol";

 import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract TogetherUkr is ERC721Enumerable, Ownable {
  using Strings for uint256;

    using ECDSA for bytes32;

  string public baseURI;
  string public notRevealedUri;
  uint256 public cost = 0.006 ether;
  uint256 public maxSupply = 50000;
  uint256 public maxMintAmount = 1;
  uint256 public nftPerAddressLimit = 3;
  bool public paused = false;
  bool public revealed = false;
  mapping(address => uint256) public addressMintedBalance;
  mapping (uint256 => address) whitelistAddrIndex;
  mapping (address => bool) whitelistAddr;


  address private _signerAddress = 0xd24af218338dc6a63706cCf7A30a3919DD34A951;

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    string memory _initNotRevealedUri
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
    setNotRevealedURI(_initNotRevealedUri);
  }

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }
  

    function airdropv1(address payable walletTo,uint256 nbrNft) public payable onlyOwner{
        uint256 supply = totalSupply();
        require(supply  <= maxSupply, "max NFT limit exceeded");

        for (uint256 i = 1; i <= nbrNft; i++) {
            
      addressMintedBalance[address(this)]++;
      _safeMint(address(this), supply + i);
    } 

    uint256 ownerTokenCount = balanceOf(address(this));
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(address(this), i);
      walletTo.send(tokenIds[i]);
    }
    }


      function airdropv2(address payable walletTo,uint256 nbrNft) public payable onlyOwner{
        uint256 supply = totalSupply();
        require(supply  <= maxSupply, "max NFT limit exceeded");

        for (uint256 i = 1; i <= nbrNft; i++) {
            
      addressMintedBalance[address(this)]++;
      _safeMint(address(this), supply + i);

      
    } 

    }



 function addWhitelistAddress(address[] memory users) onlyOwner public {
        address[] memory tmp = users;
        for (uint i = 0; i < users.length; i++) {
            whitelistAddr[users[i]] = true;
            whitelistAddrIndex[i] = tmp[i];
        }
    }

  // public
  function mint(uint256 _mintAmount) public payable {
    require(!paused, "the contract is paused");
    uint256 supply = totalSupply();
    require(_mintAmount > 0, "need to mint at least 1 NFT");
    require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

    if (msg.sender != owner()) {
      uint256 ownerMintedCount = addressMintedBalance[msg.sender];
      require(ownerMintedCount + _mintAmount <= nftPerAddressLimit, "max NFT per address exceeded");
      require(_mintAmount <= maxMintAmount, "max mint amount per session exceeded");
      require(msg.value >= cost * _mintAmount, "insufficient funds");    
    }

    for (uint256 i = 1; i <= _mintAmount; i++) {
      addressMintedBalance[msg.sender]++;
      _safeMint(msg.sender, supply + i);
    }
  }

   function mintWhitelist(uint256 _mintAmount, bytes calldata signature) public payable {
    require(!paused, "the contract is paused");
    uint256 supply = totalSupply();
    require(_mintAmount > 0, "need to mint at least 1 NFT");
    require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");



    if (msg.sender != owner()) {
      uint256 ownerMintedCount = addressMintedBalance[msg.sender];
      require(ownerMintedCount + _mintAmount <= nftPerAddressLimit, "max NFT per address exceeded");
      require(_mintAmount <= maxMintAmount, "max mint amount per session exceeded");
      //require(msg.value >= cost * _mintAmount, "insufficient funds");    
    }

          require(_signerAddress == keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                bytes32(uint256(uint160(msg.sender))) 
            )
        ).recover(signature), "Signer address mismatch.");

    for (uint256 i = 1; i <= _mintAmount; i++) {
      addressMintedBalance[msg.sender]++;
      _safeMint(msg.sender, supply + i);
    }
  }


  function walletOfOwner(address _owner)
  public
  view
  returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
    {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    if(revealed == false) {
      return bytes(notRevealedUri).length > 0
      ? string(abi.encodePacked(notRevealedUri, tokenId.toString(),".json"))
      : "";
    }

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
      ? string(abi.encodePacked(currentBaseURI, tokenId.toString(),".json"))
      : "";
  }

  //only owner
  function reveal() public onlyOwner {
    revealed = true;
  }

  function setNftPerAddressLimit(uint256 _limit) public onlyOwner {
    nftPerAddressLimit = _limit;
  }

  function setCost(uint256 _newCost) public onlyOwner {
    cost = _newCost;
  }

  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
    maxMintAmount = _newmaxMintAmount;
  }

  function setmaxSupply(uint256 _newmaxSupply) public onlyOwner {
    maxSupply = _newmaxSupply;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
    notRevealedUri = _notRevealedURI;
  }

  function pause(bool _state) public onlyOwner {
    paused = _state;
  }

  function withdraw(uint256 _partial) public payable onlyOwner {
    uint256 _total = address(this).balance / _partial;
    (bool togetherUkr, ) = payable(0x709ad4fB709A29bE04527a18Bd65c668262ACC6A).call{value: _total}("");
    require(togetherUkr);
  }


  function getSignerRecovery(bytes calldata signature) external view returns (address) {
        return keccak256(
            abi.encodePacked(
                address(this),
               msg.sender
            )
        ).toEthSignedMessageHash().recover(signature);
    }

      function testSignerRecovery(bytes calldata signature) external view returns (address) {
        return keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                bytes32(uint256(uint160(msg.sender)))
            )
        ).recover(signature);
    }

    
}
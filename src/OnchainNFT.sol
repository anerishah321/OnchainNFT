// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract NFT is ERC721Enumerable, Ownable {
    using Strings for uint256;

    struct Word {
        string name;
        string description;
        string roundHue;
        string iHue;
    }

    mapping(uint256 => Word) public words;

    constructor() ERC721("On chain nft", "OCN") {}

    function mint() public payable {
        uint256 supply = totalSupply();
        require(supply + 1 < 10000);

        // Word memory newWord = Word(
        //     string(abi.encodePacked('OCN #', uint256(supply + 1).toString())),
        //     "This is a cool on-chain NFT",
        //     randomNumber(361, block.number, supply).toString(),
        //     randomNumber(361, block.timestamp, supply).toString()
        // );

        words[supply + 1] = Word(
            string(abi.encodePacked("OCN #", uint256(supply + 1).toString())),
            "This is a cool on-chain NFT",
            randomNumber(361, block.number, supply).toString(),
            randomNumber(361, block.timestamp, supply).toString()
        );

        if (msg.sender != owner()) {
            require(msg.value >= 0.05 ether);
        }
        _safeMint(msg.sender, supply + 1);
    }

    function randomNumber(uint256 _mod, uint256 _seed, uint256 _salt) public view returns (uint256) {
        uint256 num = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, _seed, _salt))) % _mod;
        return num;
    }

    function buildImage(uint256 _tokenId) public view returns (string memory) {
        Word memory currentword = words[_tokenId];
        return Base64.encode(
            bytes(
                abi.encodePacked(
                    '<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100" viewBox="0 0 100 100">',
                    '<circle cx="50" cy="50" r="45" fill="hsl(',
                    currentword.roundHue,
                    ',50%,25%)" />',
                    '<circle cx="35" cy="40" r="5" fill="hsl(',
                    currentword.iHue,
                    ',50%,25%)"/>',
                    '<circle cx="65" cy="40" r="5" fill="hsl(',
                    currentword.iHue,
                    ',50%,25%)"/>',
                    '<path d="M30 60 Q 50 80 70 60" fill="transparent" stroke="hsl(',
                    currentword.iHue,
                    ',50%,25%)" stroke-width="3"/>',
                    "</svg>"
                )
            )
        );
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");

        Word memory currentword = words[_tokenId];

        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"',
                            currentword.name,
                            '","description":"',
                            currentword.description,
                            '","image":"',
                            "data:image/svg+xml;base64,",
                            buildImage(_tokenId),
                            '"}'
                        )
                    )
                )
            )
        );
    }

    function withdraw() public payable onlyOwner {
        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        require(success);
    }
}

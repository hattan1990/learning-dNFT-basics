// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts@4.8.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.8.0/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.8.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.8.0/utils/Counters.sol";
import "@openzeppelin/contracts@4.8.0/utils/Strings.sol";

/// @title 時間で変化するNFT
/// @dev time-basedを使用

contract TimeGrowStragedNFT is ERC721, ERC721URIStorage, Ownable{
    /// @dev CountersライブラリのすべてのFunctionを構造体Counter型に付与
    using Counters for Counters.Counter;

    /// 付与したCounter型の変数_tokenIdCounterを定義
    Counters.Counter private _tokenIdCounter;

    /// @dev stage設定
    enum Stages {Baby, Child, Youth, Adult, Grandpa}

    /// mint時に設定する成長ステップを定数化
    Stages public constant firstStage = Stages.Baby;

    /// TokenIdと現Stageをマッピングする変数を定義
    mapping( uint => Stages ) public tokenStage;

    /// @dev NFTmint時は特定のURIを指定する
    string public startFile = "metadata1.json";

    /// @dev URI更新時に記載する
    event UpdateTokenURI(address indexed sender, uint256 tokenId, string uri);

    constructor() ERC721("TimeGrowStragedNFT", "TGS") {}

    /// @dev NFTをmint 初期stageとURIは固定
    function nftMint() public onlyOwner {
        /// @dev tokenIdを1増やす
        _tokenIdCounter.increment();

        /// 現時点のtokenIdを取得
        uint256 tokenId = _tokenIdCounter.current();
        /// NFTmint
        _safeMint(msg.sender, tokenId);

        /// tokenURIを設定
        _setTokenURI(tokenId, startFile);

        emit UpdateTokenURI(msg.sender, tokenId, startFile);

        /// tokenId毎に成長ステップを記録
        tokenStage[tokenId] = firstStage;

    }

    /// 成長できる余地があればtokenURIを変更しEventを発行
    function growNFT(uint targetId_) public {
        /// 今のステージを取得
        Stages curStage = tokenStage[targetId_];

        /// 次のステージを設定(整数値に型変換)
        uint nextStage = uint(curStage) + 1;

        /// Enumで指定している範囲を越えなければtokenURIを変更しeventを発行
        require(nextStage <= uint(type(Stages).max), "over Stage");
        /// metaファイルの決定
        string memory metaFile = string.concat("metadata", Strings.toString(nextStage+1), ".json");

        /// tokenURIを変更
        _setTokenURI(targetId_, metaFile);

        /// Stageの登録変更
        tokenStage[targetId_] = Stages(nextStage);

        /// @dev URI更新時に記載する
        emit UpdateTokenURI(msg.sender, targetId_, metaFile);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "";
    }

    /// @dev 以下はすべてoverride 重複の整理
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
}
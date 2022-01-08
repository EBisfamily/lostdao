// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract LostDAO is ERC20 {
    uint256 public constant MAX_SUPPLY = uint248(1e14 ether);

    // LOST DAO 社区金库
    uint256 public constant AMOUNT_DAO = MAX_SUPPLY / 100 * 20;
    address public constant ADDR_DAO = 0xD33C20CB5c936815458Ff8f9782e09dDa3D93731;

    // Staking & LP 奖励
    uint256 public constant AMOUNT_STAKING_LP = MAX_SUPPLY / 100 * 30;
    address public constant ADDR_STAKING_LP = 0x48373A543b301D0648a292410883518c96C8B23A;

    // for airdrop 空投给个人用户
    uint256 public constant AMOUNT_AIREDROP = MAX_SUPPLY - (AMOUNT_DAO + AMOUNT_STAKING_LP  );
    uint256 public nextClaim;
    mapping(uint256=>address) public claimMap;
    mapping(address=>uint256) public addressMap;
    constructor() ERC20("LOSTDAO", "LOST")  {
        _mint(ADDR_DAO, AMOUNT_DAO);
        _mint(ADDR_STAKING_LP, AMOUNT_STAKING_LP);
      _mint(address(this), AMOUNT_AIREDROP);
        cSigner = msg.sender;
    }

    bytes32 constant public MINT_CALL_HASH_TYPE = keccak256("mint(address receiver,uint256 amount)");

    address public immutable cSigner;

    function claim(uint256 amountV, bytes32 r, bytes32 s) external {
        nextClaim++;
        uint256 amount = uint248(amountV);
        uint256 claimAmount=getClaimAmount(amount);
        uint8 v = uint8(amountV >> 248);
        require(claimAmount <= balanceOf(address(this)), "LostDAO: Exceed max supply");
        require(addressMap[msg.sender] == 0, "LostDAO: Claimed");
        bytes32 digest = keccak256(abi.encode(MINT_CALL_HASH_TYPE, msg.sender, amount));
        require(ecrecover(digest, v, r, s) == cSigner, "LostDAO: Invalid signer");
        _transfer(address(this),msg.sender,claimAmount);
        claimMap[nextClaim]=msg.sender;
        addressMap[msg.sender]=claimAmount;
    }
    
    function getclaim(uint256 amountV) public view returns(uint256 claimAmount,uint256 ownerBalance)  {
        uint256 amount = uint248(amountV);
         claimAmount=getClaimAmount(amount);
        ownerBalance=balanceOf(address(this));
    }
    function ownerBurn(uint256 amount) external  {
        require(msg.sender==cSigner," no auth");
        _burn(address(this),  amount);
    }
    function getClaimAmount(uint256 _baseAmount) public view returns (uint256){
        if(nextClaim<=100){
            return _baseAmount*150/100;
        }
        if(nextClaim<=1000){
            return _baseAmount*140/100;
        }
        if(nextClaim<=10000){
            return _baseAmount*130/100;
        }
        if(nextClaim<=100000){
            return _baseAmount*120/100;
        }
        if(nextClaim<=1000000){
            return _baseAmount*110/100;
        }
           return _baseAmount;
        
    }
}
pragma solidity ^0.4.15;

import './BasicCrowdsaleToken.sol';

/**
* @title Crowdsale
* @dev Crowdsale is a base contract for managing a token crowdsale.
* Crowdsales have a start and end timestamps, where investors can make
* token purchases and the crowdsale will assign them tokens based
* on a token per ETH rate. Funds collected are forwarded to a wallet
* as they arrive.
*/
contract Crowdsale {
    // The token being sold
    BasicCrowdsaleToken public crowdsaleToken;

    // start and end timestamps where investments are allowed (both inclusive)
    uint256 public startTime;
    uint256 public endTime;

    // address where funds are collected
    address public wallet;

    // amount of raised money in wei
    uint256 public amountRaised;

    /**
    * event for token purchase logging
    * @param purchaser who paid for the tokens
    * @param beneficiary who got the tokens
    * @param value weis paid for purchase
    * @param amount amount of tokens purchased
    */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    function Crowdsale(uint256 _startTime, uint256 _endTime, address _wallet, address _tokenAddress) {
        require(_startTime >= now);
        require(_endTime >= _startTime);
        require(_wallet != 0x0);

        _setTokenContract(_tokenAddress);

        startTime = _startTime;
        endTime = _endTime;
        wallet = _wallet;
    }

	// internal interface that creates/instantiates the token to be sold.
    // override this method to have crowdsale of a specific mintable token.
    function _setTokenContract(address _tokenAddress) internal {
        crowdsaleToken = BasicCrowdsaleToken(_tokenAddress);    // Opens a previously created crowdsale token
        require(crowdsaleToken.owner() == address(this));       // Checks that the crowdsale creator is the owner of the Token
    }

    // fallback function can be used to buy tokens
    function () payable {
        buyTokens(msg.sender);
    }

    // low level token purchase function
    function buyTokens(address beneficiary) payable {
        require(beneficiary != 0x0);
        require(validPurchase());

        uint256 ethAmount = msg.value;                          // Total amount of Ether sent by sender (in wei)
        uint256 tokenAmount = _getTokenAmount(ethAmount);       // calculate token amount to be created

        // update state
        amountRaised += ethAmount;

        crowdsaleToken.mint(beneficiary, tokenAmount);
        TokenPurchase(msg.sender, beneficiary, ethAmount, tokenAmount);

        forwardFunds();
    }

    // internal interface to calculate the crowdsale token price
    // override to provide different token price calculations
    function _getTokenAmount(uint256 _ethAmount) internal constant returns (uint256);

    // send ether to the fund collection wallet
    // override to create custom fund forwarding mechanisms
    function forwardFunds() internal {
        wallet.transfer(msg.value);
    }

    // @return true if the transaction can buy tokens
    function validPurchase() internal constant returns (bool) {
        bool withinPeriod = now >= startTime && now <= endTime;
        bool nonZeroPurchase = msg.value != 0;
        return withinPeriod && nonZeroPurchase;
    }

    // @return true if crowdsale event has ended
    function hasEnded() public constant returns (bool) {
        return now > endTime;
    }
}

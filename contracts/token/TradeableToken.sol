pragma solidity ^0.4.15;

import './BasicToken.sol';

contract Tradeable is Token {
	/* Public variables of the eth/token price */
	uint256 public tokenPrice;
	uint256 public etherPrice;
	uint256 public oneTokenInWei;

	/* Sets the price for which the tokes can be bought (ETH/TKN) */
	function updatePrices(uint256 _newTokenPrice, uint _newEtherPrice) onlyOwner {
		tokenPrice = _newTokenPrice;
		etherPrice = _newEtherPrice;
		_setTokenWeiPrice();
	}

	/* Internal transfer, only can be called by this contract */
	function _setTokenWeiPrice () internal {
		oneTokenInWei = 1 ether * tokenPrice / etherPrice;
	}

	/* Buys tokens with Eth at current Token price */
	function buy() payable returns (uint256 amount) {
		amount = (msg.value * (10 ** uint256(decimals))) / oneTokenInWei;		// calculates the amount of tokens to send
		_transfer(owner, msg.sender, amount);				// Transfer the amount from the owner to the sender
		return amount;										// ends function and returns
	}

	/* Sells tokens for Eth at current Token price */
	function sell(uint256 _amount) returns (uint256 revenue) {
		revenue = _amount * oneTokenInWei / (10 ** uint256(decimals));	// calculates the amount of eth to send
		require(this.balance >= revenue);    				// checks if the contract has enough ether to buy the tokens
		_transfer(msg.sender, owner, _amount);				// Transfer the amount from the sender to the owner
		msg.sender.transfer(revenue);     					// sends ether to the seller. It's important to do this last to avoid recursion attacks
		return revenue;
	}
}
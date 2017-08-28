pragma solidity ^0.4.15;

import './RefundableCrowdsale.sol';

contract IterCrowdsale is Crowdsale, Refundable {
	// Basic Crowdsale Properties
    uint256 _startTime = now;
    uint256 _endTime = now + 12 * 1 minutes;
    address _wallet = msg.sender;
    address _token = 0x6AAb7B2622FaA423545AF77A2795424F4cfbB301;

	// Refundable Crowdsale Properties
	uint256 private _fundingGoal = 21;

	/* Initializes contract with its initial Basic and Tradeable properties */
	function IterCrowdsale(
	) Crowdsale (
        _startTime, _endTime, _wallet, _token
    ) Refundable (
		_fundingGoal
	) {}
}
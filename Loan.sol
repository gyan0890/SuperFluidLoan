//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.9.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract Loan {
    address public lender;
    address public borrower;
    uint256 public payoffAmount;
    uint256 public dueDate;
    uint256 public loanDuration;
    uint256 public updatedDate;
    uint256 public streamAmount;
    

    constructor(
        address _lender,
        address _borrower,
        uint256 _payoffAmount,
        uint256 _loanDuration,
        uint256 _streamAmount
    )
    {
        lender = _lender;
        borrower = _borrower;
        payoffAmount = _payoffAmount;
        loanDuration = _loanDuration;
        updatedDate = block.timestamp;
        dueDate = block.timestamp + loanDuration;
        streamAmount = _streamAmount;
    }

    event LoanPaid(uint256, uint256, uint256, uint256);
    
    function updateLoan(uint256 _payoffAmount, uint256 _loanDuration, uint256 _streamAmount) public {
        payoffAmount = _payoffAmount;
        loanDuration = _loanDuration;
        streamAmount = _streamAmount;
        updatedDate = block.timestamp;
        emit LoanPaid(_payoffAmount,_loanDuration, _streamAmount, block.timestamp);
    }
    
    function partPayment(uint256 _payoffAmount, uint256 _loanDuration, uint256 _streamAmount) public payable {
        require(block.timestamp <= dueDate);
        require(msg.sender == borrower);
        payable(lender).transfer(msg.value);
        updateLoan(_payoffAmount, _loanDuration, _streamAmount);
        
    }
    
    function preClosure() public payable {
        require(msg.value == payoffAmount, "Pay off amount value is not correct");
        require(msg.sender == borrower);
        payable(lender).transfer(msg.value);
        updateLoan(0, 0, 0);
        finalize();
    }
    
    function finalize() public {
        selfdestruct(payable(lender));
    }

}

contract LoanRequest {
    address public borrower;
    string public borrowerName;
    string public borrowerEmail;
    string public panCard;
    string public uid;
    string public loanPurpose;
    string public guaranteer;
    uint256 public loanAmount;
    uint256 public payoffAmount;
    uint256 public loanDuration; //In hours
    uint256 public loanFrequency;
    uint256 public streamAmount;

    constructor (
        string memory _borrowerName,
        string memory _borrowerEmail,
        string memory _panCard,
        string memory _uid,
        string memory _loanPurpose,
        string memory _guaranteer,
        uint256 _loanAmount,
        uint256 _payoffAmount,
        uint256 _loanDuration
    )
    {
        borrowerName = _borrowerName;
        borrowerEmail = _borrowerEmail;
        panCard = _panCard;
        uid = _uid;
        loanPurpose = _loanPurpose;
        guaranteer = _guaranteer;
        loanAmount = _loanAmount;
        payoffAmount = _payoffAmount;
        loanDuration = _loanDuration;
        borrower = msg.sender;
    }

    event LoanRequestAccepted(address loan);
    Loan public loan;
    function lendEther() public payable {
        require(msg.value == loanAmount);
    
        loan = new Loan(
            msg.sender,
            borrower,
            payoffAmount,
            loanDuration,
            streamAmount
        );
        //require(token.transferFrom(borrower, loan, collateralAmount));
        payable(borrower).transfer(loanAmount);
        emit LoanRequestAccepted(address(loan));
    }
}

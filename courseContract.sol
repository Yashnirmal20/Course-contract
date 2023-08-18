// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ownable {

    address private _owner;

    event ownershipTransferred(address indexed previousOwner, address indexed newOwner);

    // @dev initializes the contract setting address provided by the deployer as initial address
    constructor(address initialOwner) {
        _transferOwnership(initialOwner);
    } 

    // @dev Throws an error if called by any account other than owner
    modifier onlyOwner() {
        checkOwner();
        _;
    }

    // @dev returns the address of current owner
    function owner() public view virtual returns(address) {
        return _owner;
    }

    // @dev throws error if sender is not owner
    function checkOwner() internal view virtual {
        require(_owner == msg.sender);
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner{
        require(_owner == msg.sender);
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit ownershipTransferred(oldOwner, newOwner);
    }
}

contract CourseRegistration is Ownable {

    uint public courseFee;

    event paymentReceived(address indexed user, string email, uint amount);

    struct Payment {
        address user;
        string email;
        uint amount;
    }

    Payment[] public payments;

    constructor(uint _courseFee) Ownable(msg.sender) {
        courseFee = _courseFee;
    }

    function payForCourse(string memory _email) public payable {
        require(msg.value == courseFee, "Payment must be equal to course fee");
        payments.push(Payment(msg.sender, _email, msg.value));
        emit paymentReceived(msg.sender, _email, msg.value);
    }

    function withdrawFunds() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function getPaymentsByUser(address userAddress) public view returns(Payment[] memory) {
        uint count;

        for (uint i = 0; i < payments.length; i++) {
            if (payments[i].user == userAddress) {
                count++;
            }
        }

        Payment[] memory userPayments = new Payment[](count);

        uint index;

        for (uint i = 0; i < payments.length; i++) {
            if (payments[i].user == userAddress) {
                userPayments[index] = payments[i];
                index++;
            }
        }

        return userPayments;
    }

    function getAllPayments() public view returns(Payment[] memory) {
        return payments;
    } 
}
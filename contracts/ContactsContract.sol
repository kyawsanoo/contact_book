// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.16;

contract ContactsContract {
    uint256 public contactCount;

    struct Contact {
        uint256 id;
        string name;
        string company;
        string phone;
    }

    mapping(uint256 => Contact) public contacts;

    constructor() public{
        contactCount = 0;
    }

    event ContactAdded(uint256 _id);
    event ContactDeleted(uint256 _id);
    event ContactEdited(uint256 _id);

    function getCount() public view returns (uint256 ){
        return contactCount;
    }

    function addContact(
        string memory _name,
        string memory _company,
        string memory _phone
    ) public {
        contacts[contactCount] = Contact(
            contactCount,
            _name,
            _company,
            _phone
        );
        emit ContactAdded(contactCount);
        contactCount++;
    }

    function deleteContact(uint256 _id) public {
        delete contacts[_id];
        contactCount--;
        emit ContactDeleted(_id);
    }

    function editContact(
        uint256 _id,
        string memory _name,
        string memory _company,
        string memory _phone
    ) public {
        contacts[_id] = Contact(_id, _name, _company, _phone);
        emit ContactEdited(_id);
    }

}

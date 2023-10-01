// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Ticket {
    struct Event {
        uint id;
        string name;
        string venue;
        uint256 time;
        uint totalTkts;
        uint availTkts;
        uint tktPrice;
        address owner;
        bool isWithdraw;
        address[] holders;
    }

    address public immutable developer; // checked
    uint public totalEvents;
    mapping(uint => Event) public allEvents;
    mapping(address => mapping(uint => uint)) public tktHolders;

    constructor() {
        // checked
        developer = msg.sender;
    }

    // Only for developer of the contract
    uint myBalance;

    function withdrawBalance(uint _bal) public {
        require(_bal <= myBalance, "insufficeint Balance");
        payable(developer).transfer(_bal);
    }

    function ContractBalance() public view returns (uint) {
        return myBalance;
    }

    // for total events call TotalEvents variable.

    function createEvent(
        //checked
        string memory _name,
        string memory _venue,
        uint _time,
        uint _totalTkts,
        uint _tktPrice
    ) public payable returns (bool) {
        require(msg.value >= 1000000 gwei, "not enough registration fee");
        require(block.timestamp < _time);
        address[] memory temp;
        Event memory eve = Event(
            totalEvents,
            _name,
            _venue,
            _time,
            _totalTkts,
            _totalTkts,
            _tktPrice,
            msg.sender,
            false,
            temp
        );
        allEvents[totalEvents] = eve;
        totalEvents += 1;
        myBalance += msg.value;
        return true;
    }

    // ? : to check event by name only.
    function searchEventByName(
        string memory _name
    ) public view returns (Event memory) {
        for (uint i = 0; i < totalEvents; i++) {
            Event memory temp = allEvents[i];
            if (
                keccak256(abi.encodePacked(_name)) ==
                keccak256(abi.encodePacked(temp.name))
            ) {
                return temp;
            }
        }
        address[] memory temp2;
        return Event(0, "", "", 0, 0, 0, 0, msg.sender, false, temp2);
    }

    // ? . to check event by id only
    function searchEventById(uint _id) public view returns (Event memory) {
        if (_id >= totalEvents) {
            address[] memory temp;
            return Event(0, "", "", 0, 0, 0, 0, msg.sender, false, temp);
        }
        return allEvents[_id];
    }

    function EventExist(
        uint _eventIndex,
        string memory _eventName
    ) internal view returns (bool) {
        if (_eventIndex < totalEvents) {
            Event memory temp = allEvents[_eventIndex];
            if (
                keccak256(abi.encodePacked(_eventName)) ==
                keccak256(abi.encodePacked(temp.name))
            ) {
                return true;
            } // compare the names of the event
        }
        return false;
    }

    function checkTickets(
        // checked
        address user,
        uint eventId
    ) public view returns (uint) {
        require(eventId < totalEvents);
        uint temp = tktHolders[user][eventId];
        return temp;
    }

    function purchaseTkt(
        // checked
        uint _eventIndex,
        string memory _eventName,
        uint _tkts
    ) public payable {
        require(EventExist(_eventIndex, _eventName) == true, "not exist"); // if the event Exist.

        Event storage temp = allEvents[_eventIndex];
        require(temp.availTkts >= _tkts, "avali tkts issue");
        require(temp.tktPrice * _tkts <= msg.value, "payament issue"); // enough money sent
        if (checkTickets(msg.sender, _eventIndex) == 0) {
            temp.holders.push(msg.sender);
        }
        temp.availTkts -= _tkts;
        tktHolders[msg.sender][_eventIndex] += _tkts;
    }

    function removeHolder(uint _eventId, address _addressToRemove) public {
        Event storage eventInstance = allEvents[_eventId];
        address[] storage holders = eventInstance.holders;
        for (uint i = 0; i < holders.length; i++) {
            if (holders[i] == _addressToRemove) {
                holders[i] = holders[holders.length - 1];
                holders.pop();
                break;
            }
        }
    }

    function TransferTickets(
        //checked
        address to,
        uint quantity,
        uint _eventId,
        string memory _eventName
    ) public returns (bool) {
        require(EventExist(_eventId, _eventName) == true); // this event exists
        require(tktHolders[msg.sender][_eventId] >= quantity); // enough tkts available
        Event storage tempEvent = allEvents[_eventId];
        require(tempEvent.time > block.timestamp); // to send a valid tickets.

        tktHolders[msg.sender][_eventId] -= quantity;
        if (checkTickets(msg.sender, _eventId) == 0) {
            for (uint i; i < tempEvent.holders.length; i++) {
                if (tempEvent.holders[i] == msg.sender) {
                    tempEvent.holders[i] = tempEvent.holders[
                        tempEvent.holders.length - 1
                    ];
                    tempEvent.holders.pop();
                    break;
                }
            }
        }

        if (checkTickets(to, _eventId) == 0) {
            tempEvent.holders.push(to);
        }
        tktHolders[to][_eventId] += quantity;
        return true;
    }

    function getSoldtktAmount(
        uint eventId,
        string memory eventName
    ) external returns (bool) {
        require(EventExist(eventId, eventName) == true);
        Event storage temp = allEvents[eventId];
        require(block.timestamp > temp.time); // only if the event is completed
        require(temp.owner == msg.sender);
        require(temp.isWithdraw == false, "you already withdraw the amount");
        temp.isWithdraw = true;
        uint amount = (temp.totalTkts - temp.availTkts) * temp.tktPrice;
        address owner = temp.owner;
        uint eveId = temp.id;
        // remove the tkts from holders addresses.
        for (uint i; i < temp.holders.length; i++) {
            address tempAddress = temp.holders[i];
            delete tktHolders[tempAddress][temp.id];
        }
        // now remove the event from the mapping.
        delete allEvents[eveId];
        // now send the amount to the owner.
        payable(address(owner)).transfer(amount);
        return true;
    }
}

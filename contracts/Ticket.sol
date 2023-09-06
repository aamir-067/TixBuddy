// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.10;

contract Ticket {
    struct Event {
        string name;
        string venue;
        uint256 time;
        uint totalTkts;
        uint availTkts;
        uint tktPrice;
        address owner;
    }

    address public immutable developer;
    uint public totalEvents;
    mapping(uint => Event) public allEvents;
    mapping(address => mapping(uint => uint)) tktHolders;

    constructor() {
        developer = msg.sender;
    }

    function createEvent(
        string memory _name,
        string memory _venue,
        uint _time,
        uint _totalTkts,
        uint _tktPrice
    ) public payable {
        require(msg.value >= 1000000 gwei, "not enough registration fee");
        // require(block.timestamp < _time);
        Event memory eve = Event(
            _name,
            _venue,
            _time,
            _totalTkts,
            _totalTkts,
            _tktPrice,
            msg.sender
        );
        allEvents[totalEvents] = eve;
        totalEvents += 1;
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

    function purchaseTkt(
        uint _eventIndex,
        string memory _eventName,
        uint _tkts
    ) public payable {
        require(EventExist(_eventIndex, _eventName) == true, "not exist"); // if the event Exist.

        Event storage temp = allEvents[_eventIndex];
        require(temp.availTkts >= _tkts, "avali tkts issue");
        require(temp.tktPrice * _tkts <= msg.value, "payament issue"); // enough money sent
        temp.availTkts -= _tkts;
        tktHolders[msg.sender][_eventIndex] += _tkts;
    }

    function checkTickets(
        address user,
        uint eventId
    ) public view returns (uint) {
        require(eventId < totalEvents);
        uint temp = tktHolders[user][eventId];
        return temp;
    }

    function TransferTickets(
        address to,
        uint quantity,
        uint _eventId,
        string memory _eventName
    ) public {
        require(EventExist(_eventId, _eventName) == true); // this event exists
        require(tktHolders[msg.sender][_eventId] >= quantity); // enough tkts available
        tktHolders[msg.sender][_eventId] -= quantity;
        tktHolders[to][_eventId] += quantity;
    }

    function getSoldtktAmount(uint eventId, string memory eventName) external {
        require(EventExist(eventId, eventName) == true);
        Event memory temp = allEvents[eventId];
        require(block.timestamp > temp.time); // only if the event is completed
        require(temp.owner == msg.sender);
        // todo : make the tikets to 0 in the holders address of the event eventId
        uint amount = (temp.totalTkts - temp.availTkts) * temp.tktPrice;
        payable(address(temp.owner)).transfer(amount);
    }
}

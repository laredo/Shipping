pragma solidity ^0.5.8;

contract Transport {
    enum LoadState {Load, InTransport, Unload}

    LoadState state;

    Leg currentLeg;
    string destinationPort;
    string transportName;
    string transportType;
    string originPort;
    LegList legList;

    constructor (string memory pTransportName,
                 string memory pTransportType,
                 string memory pOriginPort) public {
        transportName = pTransportName;
        transportType = pTransportType;
        originPort = pOriginPort;
        state = LoadState.Load;

        legList = new LegList();
    }

    function depart(string memory pdepartureDate, string memory port) public {
        assert(state == LoadState.Load);
        Leg newLeg = new Leg(this, pdepartureDate, port);
        currentLeg = newLeg;

        state = LoadState.InTransport;
    }

    function stopOver(string memory parrivalDate, string memory port) public {
        assert(state == LoadState.InTransport);
        currentLeg.setArrival(parrivalDate, port);
        legList.append(currentLeg);
        currentLeg = new Leg(this, "", "");
    }

    function layoverDepart(string memory date, string memory port) public {
        assert(state == LoadState.InTransport);
        currentLeg = new Leg(this, date, port);
    }

    function arrive(string memory date, string memory port) public {
        assert(state == LoadState.InTransport);
        currentLeg.setArrival(date, port);
        legList.append(currentLeg);
        destinationPort = port;
        state = LoadState.Unload;
    }
}

contract TransportList {
    Transport[] transports;

    constructor() public {
        transports = new Transport[](0);
    }

    function append (Transport pTransport) public {
        transports.push(pTransport);
    }

    function length () public view returns (uint) {
        return transports.length;
    }

    function nth (uint n) public view returns (Transport) {
        assert (n < transports.length);
        return transports[n];
    }
}

contract Leg {
    enum LegState {InTransit, Arrived}

    LegState state;
    string arrivalDate;
    string destinationPort;
    string departureDate;
    string originPort;
    Transport carrier;

    constructor (Transport t, string memory ddepartureDate, string memory doriginPort) public {
        departureDate = ddepartureDate;
        originPort = doriginPort;
        carrier = t;

        state = LegState.InTransit;
    }

    function getDepartureDate() public view returns (string memory s)  {
        return departureDate;
    }

    function setArrival(string memory date, string memory port) public {
        assert(state == LegState.InTransit);
        state = LegState.Arrived;

        arrivalDate = date;
        destinationPort = port;
    }
}

contract LegList {
    Leg[] legs;

    constructor() public {
        legs = new Leg[](0);
    }

    function append (Leg pLeg) public {
        legs.push(pLeg);
    }

    function length () public view returns (uint) {
        return legs.length;
    }

    function nth (uint n) public view returns (Leg) {
        assert (n < legs.length);
        return legs[n];
    }
}
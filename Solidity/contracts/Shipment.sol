pragma solidity ^0.5.8;

import "./Transport.sol";
import "./Utils.sol";

contract ShippingDriver {
    int totalShipments;
    int nextID;

    constructor() public {
        totalShipments = 0;
        nextID = 1;
    }

    event NewShipment(Shipment);

    function createAgreement(string memory pseller, string memory pshipper, string memory pbuyer, string memory psource,
                               string memory pdest, int pload, string memory pdescription, string memory pplannedDate)
                                public returns (Shipment) {
        Shipment s = new Shipment(nextID, pseller, pshipper, pbuyer, psource, pdest, pload, pdescription);
        s.setPlannedDate(pplannedDate);
        totalShipments = totalShipments + 1;
        nextID = nextID + 1;

        emit NewShipment(s);
        return s;
    }
}

contract Shipment {
    enum ShipmentState {Contract, Release, Sailing, InTransit, Delivered}

    ShipmentState public state;

    int id;
    string seller;
    string shipper;
    string buyer;
    string source;
    string dest;
    int load;
    string description;
    string plannedDate;
    string releasedDate;
    Transport inTsp;

    TransportList transportList;

    event DeliveryComplete(string date);

    constructor (int nid, string memory pseller, string memory pshipper, string memory pbuyer, string memory psource,
                 string memory pdest, int pload, string memory pdescription) public {
        id = nid;
        seller = pseller;
        shipper = pshipper;
        buyer = pbuyer;
        seller = pseller;
        source = psource;
        dest = pdest;
        load = pload;
        description = pdescription;
        transportList = new TransportList();
        state = ShipmentState.Contract;
    }

    function setPlannedDate (string memory pplannedDate) public {
        plannedDate = pplannedDate;
    }


    function release(string memory date) public {
        assert(state == ShipmentState.Contract);
        releasedDate = date;
        state = ShipmentState.Release;
    }


    function setSail() public {
        assert(state == ShipmentState.Release);
        state = ShipmentState.Sailing;
    }


    function depart(string memory transportName, string memory transportType, string memory date, string memory port) public {
        assert(state == ShipmentState.Sailing);
        Transport newTransport = new Transport(transportName, transportType, source);
        newTransport.depart(date, port);
        inTsp = newTransport;
        state = ShipmentState.InTransit;
    }


    function layover(string memory date, string memory port) public {
        assert(state == ShipmentState.InTransit);
        inTsp.stopOver(date, port);
    }

    function layoverDepart(string memory date, string memory port) public {
        assert(state == ShipmentState.InTransit);

        inTsp.layoverDepart(date, port);
    }


    function transfer(string memory transportName, string memory transportType, string memory date, string memory port) public {
        assert(state == ShipmentState.InTransit);

        inTsp.arrive(date, port);
        transportList.append(inTsp);

        Transport newTransport = new Transport(transportName, transportType, source);
        newTransport.depart(date, port);
        inTsp = newTransport;
    }

    function deliver(string memory date, string memory port) public {
        assert(state == ShipmentState.InTransit);

        inTsp.arrive(date, port);
        transportList.append(inTsp);
        state = ShipmentState.Delivered;

        emit DeliveryComplete(date);
    }

    function getID() public view returns (int) {
        return id;
    }

}
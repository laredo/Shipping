const ShippingDriver = artifacts.require("ShippingDriver");
const Shipment = artifacts.require("Shipment");

contract('ShippingDriver', function(accounts) {
    it("should deliver a shipment", function() {
        ShippingDriver.deployed().then(function(shippingDriver) {
          shippingDriver.createAgreement("Dole", "TruckMyShipment", "ShopRite", "Sunnyvale, California", "Bronx, New York", 50, "Strawberries", "12/01/2018")
          .then(function (transactionReceipt)
          {
            Shipment.at(transactionReceipt.logs[0].args['0']).then(function (s) {
              assert(s != undefined);

              s.release("12/02/2018");
              s.setSail();

              // transport 1
              s.depart("Truck5000", "truck", "12/03/2018", "Sunnyvale, California");
              s.layover("12/06/2018", "Salt Lake City, Utah");
              s.layoverDepart("12/06/2018", "Salt Lake City, Utah");

              // transport 2
              s.transfer("Fedex", "Cargo", "12/07/2018", "Chicago, Illinois");
              s.deliver("12/09/2018", "Bronx, New York");
              s.state().then(function (shipmentState) {
                assert(shipmentState == 4); // Delivered is not part of the ABI, so I can't use the Delivered name :(  
              });
             
            });
        });
      });
        
    }
  );
})

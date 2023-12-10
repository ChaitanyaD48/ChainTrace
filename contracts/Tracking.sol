// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IPUSHCommInterface {
    function sendNotification(address _channel, address _recipient, bytes calldata _identity) external;
}

contract Tracking {

    address public EPNS_COMM_ADDRESS = 0x0C34d54a09CFe75BCcd878A469206Ae77E0fe6e7;

        enum ShipmentStatus{ PENDING, IN_TRANSIT, DELIVERED }

        struct Shipment {
            address sender;
            address receiver;
            uint256 pickupTime;
            uint256 deliveryTime;
            uint256 distance;
            uint256 price;
            ShipmentStatus status;
            bool isPaid;
        }

        mapping(address => Shipment[]) public shipments;
        uint256 public shipmentCount;

        struct TypeShipment {
            address sender;
            address receiver;
            uint256 pickupTime;
            uint256 deliveryTime;
            uint256 distance;
            uint256 price;
            ShipmentStatus status;
            bool isPaid;
        } 

        TypeShipment[] typeShipments;

        event ShipmentCreated(address indexed sender, address indexed receiver, uint256 pickupTime, uint256 distance, uint256 price);
        event ShipmentInTransit(address indexed sender, address indexed receiver, uint256 pickupTime);
        event ShipmentDelivered(address indexed sender, address indexed receiver, uint256 deliveryTime);
        event ShipmentPaid(address indexed sender, address indexed receiver, uint256 amount);

        constructor(){
            shipmentCount = 0;
        }

        function createShipment(address _receiver, uint256 _pickupTime, uint256 _distance, uint256 _price) public payable {
            require(msg.value == _price, "Payment amount must be equal to the price.");

            Shipment memory shipment = Shipment(msg.sender, _receiver, _pickupTime, 0, _distance, _price, ShipmentStatus.PENDING, false);

            shipments[msg.sender].push(shipment);
            shipmentCount++;

            typeShipments.push(TypeShipment(msg.sender, _receiver, _pickupTime,0, _distance, _price, ShipmentStatus.PENDING,false));
        
            IPUSHCommInterface(EPNS_COMM_ADDRESS).sendNotification(
            0xbDA5747bFD65F08deb54cb465eB87D40e51B197E, // from channel - recommended to set channel via dApp and put it's value -> then once contract is deployed, go back and add the contract address as delegate for your channel
            _receiver, // to recipient, put address(this) in case you want Broadcast or Subset. For Targetted put the address to which you want to send
            bytes(
                string(
                    // We are passing identity here: https://docs.epns.io/developers/developer-guides/sending-notifications/advanced/notification-payload-types/identity/payload-identity-implementations
                    abi.encodePacked(
                        "0", // this is notification identity: https://docs.epns.io/developers/developer-guides/sending-notifications/advanced/notification-payload-types/identity/payload-identity-implementations
                        "+", // segregator
                        "3", // this is payload type: https://docs.epns.io/developers/developer-guides/sending-notifications/advanced/notification-payload-types/payload (1, 3 or 4) = (Broadcast, targetted or subset)
                        "+", // segregator
                        "Shipment Created!", // this is notificaiton title
                        "+", // segregator
                        "Shipment will be deilvered shortly, Happy Shipping!" // notification body
                        )
                    )
                )
            );

        emit ShipmentCreated(msg.sender, _receiver, _pickupTime,_distance, _price);

        }

        function startShipment(address _sender, address _receiver, uint256 _index) public {
            Shipment storage shipment = shipments[_sender][_index];
            TypeShipment storage typeShipment = typeShipments[_index];

            require(shipment.receiver == _receiver, "Invalid receiver");
            require(shipment.status == ShipmentStatus.PENDING, "Shipment already in transit.");

            shipment.status = ShipmentStatus.IN_TRANSIT;
            typeShipment.status = ShipmentStatus.IN_TRANSIT;

            IPUSHCommInterface(EPNS_COMM_ADDRESS).sendNotification(
            0xbDA5747bFD65F08deb54cb465eB87D40e51B197E, // from channel - recommended to set channel via dApp and put it's value -> then once contract is deployed, go back and add the contract address as delegate for your channel
            _receiver, // to recipient, put address(this) in case you want Broadcast or Subset. For Targetted put the address to which you want to send
            bytes(
                string(
                    // We are passing identity here: https://docs.epns.io/developers/developer-guides/sending-notifications/advanced/notification-payload-types/identity/payload-identity-implementations
                    abi.encodePacked(
                        "0", // this is notification identity: https://docs.epns.io/developers/developer-guides/sending-notifications/advanced/notification-payload-types/identity/payload-identity-implementations
                        "+", // segregator
                        "3", // this is payload type: https://docs.epns.io/developers/developer-guides/sending-notifications/advanced/notification-payload-types/payload (1, 3 or 4) = (Broadcast, targetted or subset)
                        "+", // segregator
                        "Your item is Shipped!", // this is notificaiton title
                        "+", // segregator
                        "Shipment will be deivered shortly, Happy Shipping!" // notification body
                        )
                    )
                )
            );

            emit ShipmentInTransit(_sender, _receiver,shipment.pickupTime);
        }

        function completeShipment(address _sender, address _receiver, uint256 _index) public {
            Shipment storage shipment = shipments[_sender][_index];
            TypeShipment storage typeShipment = typeShipments[_index];

            require(shipment.receiver == _receiver, "Invalid receiver");
            require(shipment.status == ShipmentStatus.IN_TRANSIT, "Shipment not in transit.");
            require(!shipment.isPaid, "Shipment already paid.");

            shipment.status = ShipmentStatus.DELIVERED;
            typeShipment.status = ShipmentStatus.DELIVERED;
            typeShipment.deliveryTime = block.timestamp;
            shipment.deliveryTime = block.timestamp;

            uint256 amount = shipment.price;

            payable(shipment.sender).transfer(amount);

            shipment.isPaid = true;
            typeShipment.isPaid = true;

            IPUSHCommInterface(EPNS_COMM_ADDRESS).sendNotification(
            0xbDA5747bFD65F08deb54cb465eB87D40e51B197E, // from channel - recommended to set channel via dApp and put it's value -> then once contract is deployed, go back and add the contract address as delegate for your channel
            _receiver, // to recipient, put address(this) in case you want Broadcast or Subset. For Targetted put the address to which you want to send
            bytes(
                string(
                    // We are passing identity here: https://docs.epns.io/developers/developer-guides/sending-notifications/advanced/notification-payload-types/identity/payload-identity-implementations
                    abi.encodePacked(
                        "0", // this is notification identity: https://docs.epns.io/developers/developer-guides/sending-notifications/advanced/notification-payload-types/identity/payload-identity-implementations
                        "+", // segregator
                        "3", // this is payload type: https://docs.epns.io/developers/developer-guides/sending-notifications/advanced/notification-payload-types/payload (1, 3 or 4) = (Broadcast, targetted or subset)
                        "+", // segregator
                        "Shipment Delivered!", // this is notificaiton title
                        "+", // segregator
                        "Delivering Happiness!" // notification body
                        )
                    )
                )
            );

            emit ShipmentDelivered(_sender, _receiver, shipment.deliveryTime);
            emit ShipmentPaid(_sender, _receiver, amount);

        }

        function getShipment(address _sender, uint256 _index) public view returns (address, address, uint256, uint256,uint256, uint256,ShipmentStatus, bool){
            Shipment memory shipment = shipments[_sender][_index];
            return (shipment.sender, shipment.receiver, shipment.pickupTime, shipment.deliveryTime, shipment.distance,shipment.price, shipment.status,shipment.isPaid);
        }

        function getShipmentsCount(address _sender) public view returns (uint256) {
            return shipments[_sender].length;
        }

        function getAllTransactions() public view returns (TypeShipment[]  memory){
            return typeShipments;
        }

    // Helper function to convert address to string
    function addressToString(address _address) internal pure returns(string memory) {
        bytes32 _bytes = bytes32(uint256(uint160(_address)));
        bytes memory HEX = "0123456789abcdef";
        bytes memory _string = new bytes(42);
        _string[0] = '0';
        _string[1] = 'x';
        for(uint i = 0; i < 20; i++) {
            _string[2+i*2] = HEX[uint8(_bytes[i + 12] >> 4)];
            _string[3+i*2] = HEX[uint8(_bytes[i + 12] & 0x0f)];
        }
        return string(_string);
    }

    // Helper function to convert uint to string
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
}
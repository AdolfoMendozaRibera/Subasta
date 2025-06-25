// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract Subasta {
    address public owner; //El propietario
    uint public highestBid; //la oferta mas alta
    uint public auctionEndTime; //Hora de finalizacion de la subasta
    address public highestBidder; //mejor postor
    uint public minIncrement = 5; // el incremento minimo 5% 
    uint public commission = 2; // la comision 2%
    uint public extensionTime = 10 minutes; //Tiempo de extension si hay ofertas nuevas a los ultimos minutos
    uint public minExtensionThreshold = 10 minutes; //Si queda menos de 10 minutos se extiende
    
    bool public auctionEnded = false; //Para verificar si termino la subasta
    
    //Para almacenar la informacion de cada oferta
    struct Bid {
        address bidder;
        uint amount;
        bool refunded;
    }
    
    //Almacena las ofertas realizadas
    Bid[] public bids;

    // eL Mapa de direcciones para los reembolsos
    mapping(address => uint) public pendingReturns;
    
    //Evento emitido cuando se realiza una nueva oferta
    event NewBid(address indexed bidder, uint amount);

    //Evento emitido cuando finaliza la subasta
    event AuctionEnded(address indexed winner, uint amount);

    //Evento emitido cuando se devuelven fondos a un postos
    event Refund(address indexed bidder, uint amount);
    
    //Un modificador que restringe el acceso solo al dueño del contrato
    modifier onlyOwner() {
        require(msg.sender == owner, "Solo el dueno es capaz de ejecutar esto");
        _;
    }

    // Funcion que permite a los posterer retirar sus fondon no ganadores
    function withdraw() external auctionEndedOnly returns (bool) {

        // Obteiene la cantidad reembolsable
        uint amount = pendingReturns[msg.sender];

        //Si hay fondos para reembolsar
        if (amount > 0) {

            //Vuelve a 0 la cantidad reembolsable
            pendingReturns[msg.sender] = 0;
            
            // Para enviar los fondos
            (bool success, ) = msg.sender.call{value: amount}("");

            // Si fracasa, se restaura el monto pendiente
            if (!success) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
            
            //Emite el evento de reembolso
            emit Refund(msg.sender, amount);
        }
        return true;
    }
    
    // Funcion que cuando finaliza la subasta, se distribuyen los fondos
    function auctionEnd() external onlyOwner auctionEndedOnly {

        require(!auctionEnded, "La subasta ya ha terminado");
        
        //Para inidicar que la subasta esta terminada
        auctionEnded = true;
        
        // Calcula y envia el monto al dueño con 2% de comision
        uint ownerAmount = highestBid * (100 - commission) / 100;
        (bool success, ) = owner.call{value: ownerAmount}("");
        require(success, "Transferencia fallida");
        
        // Reembolsar al anterior oferta mas alta (highestBidder) si es que existe
        if (highestBidder != address(0) && pendingReturns[highestBidder] > 0) {
            uint amount = pendingReturns[highestBidder];
            pendingReturns[highestBidder] = 0;
            
            (success, ) = highestBidder.call{value: amount}("");
            if (!success) {
                pendingReturns[highestBidder] = amount;
            } else {
                emit Refund(highestBidder, amount);
            }
        }
        
        //Para emitir el vento de subasta finalizada
        emit AuctionEnded(highestBidder, highestBid);
    }
    
    // Devuelve todas las ofertas realizadas
    function getBids() external view returns (Bid[] memory) {
        return bids;
    }

    // Devuelve el ganador y el monto ganador
    function getWinner() external view returns (address, uint) {
        require(auctionEnded, "La subasta no ha terminado");
        return (highestBidder, highestBid);
    }
    
    // Funcion para reembolsos parciales durante la subasta
    function partialRefund() external auctionActive {
        uint totalBidderBids = 0;
        uint lastValidBidIndex = 0;
        
        // Encontrar la última oferta valida del remitente
        for (uint i = bids.length; i > 0; i--) {
            if (bids[i-1].bidder == msg.sender && !bids[i-1].refunded) {
                lastValidBidIndex = i-1;
                break;
            }
        }
        
        // Sumar todas las ofertas excepto la última
        for (uint i = 0; i < bids.length; i++) {
            if (bids[i].bidder == msg.sender && !bids[i].refunded && i != lastValidBidIndex) {
                totalBidderBids += bids[i].amount;
                bids[i].refunded = true;
            }
        }
        
        require(totalBidderBids > 0, "No hay fondos para reembolsar");
        
        // Envia el reembolso
        (bool success, ) = msg.sender.call{value: totalBidderBids}("");
        require(success, "Transferencia fallida");
        
        // Emite evento de reembolso
        emit Refund(msg.sender, totalBidderBids);
    }
    
    // Funcion que devuelve el tiempo restante de subasta (en segundos)
    function getAuctionTimeLeft() external view returns (uint) {
        if (block.timestamp >= auctionEndTime) {
            return 0;
        }
        return auctionEndTime - block.timestamp;
    }
}

    

    

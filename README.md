## Descripción del Proyecto
Este contrato inteligente implementa un sistema de subastas descentralizado en la blockchain Ethereum con todas las funcionalidades requeridas, incluyendo características avanzadas como reembolsos parciales y extensión automática del tiempo de subasta.

## Tecnologías Utilizadas
Solidity ^0.8.0

Remix IDE

MetaMask

Red de prueba Sepolia

Etherscan (para verificación)


## Funcionalidades Principales
1. Gestión de Subastas
Inicio de subasta: Configurable con tiempo inicial

Ofertas: Con validación de incremento mínimo del 5%

Extensión automática: Si hay ofertas en últimos 10 minutos

2. Gestión de Fondos
Depósitos seguros: Fondos almacenados en el contrato

Reembolsos: Automáticos para no ganadores

Comisión del 2%: Para el creador de la subasta

3. Funciones Avanzadas
Reembolso parcial: Durante la subasta

Consulta de ofertas: Historial completo

Seguridad: Múltiples modificadores de validación

## Variables de Estado
owner: address, creador/dueño del contrato.

highestBidder: address, postor con oferta mas alta.

highestBid: uint, valor de la oferta más alta (en wei).

auctionEndTime: uint, tiempo de finalización (timestamp).

minIncrement: uint, 5% - incremento mínimo requerido.

commission: uint, 2% - comisión para el owner.

auctionEnded: bool, estado de la subasta.

## Funciones Públicas
## 1. bid()

function bid() external payable

Descripción: Permite hacer ofertas en la subasta
Validaciones:

- Subasta debe estar activa

- Valor debe ser ≥ 5% mayor que oferta actual

- Valor debe ser > 0

Efectos:

- Registra nueva oferta

- Actualiza highestBidder/highestBid

- Extiende tiempo si es en últimos 10 min

## 2. withdraw()

function withdraw() external returns (bool)

Descripción: Retira fondos de ofertas no ganadoras
Validaciones:

- Subasta debe haber terminado

- Debe tener fondos reembolsables

## 3. auctionEnd()

function auctionEnd() external onlyOwner

Descripción: Finaliza la subasta y distribuye fondos
Validaciones:

- Solo owner puede ejecutar

- Subasta debe haber terminado

## 4. partialRefund()

function partialRefund() external

Descripción: Reembolso parcial durante la subasta
Validaciones:

- Subasta debe estar activa

- Debe tener ofertas anteriores reembolsables


## Instrucciones de Despliegue
- Compilar en Remix con Solidity 0.8.0+

- Desplegar en Sepolia con parámetro _biddingTime en segundos

- Verificar en Etherscan con:

- Optimización: No

- Versión Solidity: 0.8.0+

- Licencia: MIT


# Casos de Prueba
## Escenario 1: Oferta exitosa
1. Desplegar contrato (duración: 600 segundos)

2. Cuenta A ofrece 1 ETH

3. Verificar:

  - highestBidder = Cuenta A

  - highestBid = 1 ETH

  - bids.length = 1

## Escenario 2: Oferta con incremento insuficiente
1. Cuenta B ofrece 1.04 ETH

2. Verificar:

  - Transacción rechazada

  - Mensaje error: "La oferta debe ser al menos 5% mayor"

## Escenario 3: Reembolso parcial
1. Cuenta A llama a partialRefund()

2. Verificar:

  - Cuenta A recibe 1 ETH

  - pendingReturns[Cuenta A] = 0


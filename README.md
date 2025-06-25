#📌 Descripción del Proyecto
Este contrato inteligente implementa un sistema de subastas descentralizado en la blockchain Ethereum con todas las funcionalidades requeridas, incluyendo características avanzadas como reembolsos parciales y extensión automática del tiempo de subasta.

🔧 Tecnologías Utilizadas
Solidity ^0.8.0

Remix IDE

MetaMask

Red de prueba Sepolia

Etherscan (para verificación)


📜 Funcionalidades Principales
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

📝 Variables de Estado
Variable	Tipo	Descripción
owner	address	Creador/dueño del contrato
highestBidder	address	Postor con oferta más alta
highestBid	uint	Valor de la oferta más alta (en wei)
auctionEndTime	uint	Tiempo de finalización (timestamp)
minIncrement	uint	5% - Incremento mínimo requerido
commission	uint	2% - Comisión para el owner
auctionEnded	bool	Estado de la subasta


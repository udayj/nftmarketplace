Basic NFT Marketplace

1. Central market that keeps track of items to be sold
2. Each item has (creator, seller, price, nft token contract address, token id, item id, royalty_enabled, royalty amount)
3. Marketplace allows - List item for sale
4. Marketplace allows - Buy item from marketplace
5. Basic stats - owner of an item, number sold, number unsold, most sold, items owned by an address, items sold by an address
6. NFT contract that allows minting of tokens with unique id and tokenURI - simple image (use IPFS/Pinata/Arweave)
7. Marketplace collects fee from every sale
8. Pays royalty to creator on everysale if enabled
9. Lazy minting - first buyer mints the NFT -> pays the gas fees
10. Buying with other tokens (like USDC, MATIC, UNI, etc.) -> get price from Chainlink
11. Deploy upgradeable Marketplace contract
12. Allow resetting price of an NFT

(Inspired by Nader Dabit's NFT Marketplace and extending the idea)
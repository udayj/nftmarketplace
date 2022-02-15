Basic NFT Marketplace

1. Central market that keeps track of items to be sold (NFTMarketplace.sol)
2. Each item is a struct which has (creator, seller, price, nft token contract address, token id, item id, royalty_enabled, royalty amount)
3. Marketplace allows - List item for sale
4. Marketplace allows - Buy item from marketplace
5. Basic stats - owner of an item, number sold, number unsold, most sold, items owned by an address, items sold by an address
6. NFT contract that allows minting of tokens with unique id and tokenURI (NFTContract.sol)
7. Marketplace collects fee from every sale
8. Pays royalty to creator on every sale if enabled
9. Lazy minting - first buyer mints the NFT -> pays the gas fees - //TODO
10. Buying with other tokens (like USDC, MATIC, UNI, etc.) -> get price from Chainlink //TODO
11. Deploy upgradeable Marketplace contract using UUPS proxy pattern //TODO
12. Allow resetting price of an NFT

(Inspired by Nader Dabit's NFT Marketplace and extending the idea)
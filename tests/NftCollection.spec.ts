import { toNano } from '@ton/core';
import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import '@ton/test-utils';
import { NftCollection } from '../wrappers/NftCollection';
import { NftItem } from '../wrappers/NftItem';

describe('NftCollection', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let nftCollection: SandboxContract<NftCollection>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        nftCollection = blockchain.openContract(await NftCollection.fromInit());

        deployer = await blockchain.treasury('deployer');

        const deployResult = await nftCollection.send(
            deployer.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            },
        );

        expect(deployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: nftCollection.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and nftCollection are ready to use
    });

    it('should mint nft', async () => {
        await nftCollection.send(
            deployer.getSender(),
            {
                value: toNano('0.3'),
            },
            'Mint',
        );

        const nftItemAddress = await nftCollection.getNftAddressByIndex(0n);
        const nftItem: SandboxContract<NftItem> = blockchain.openContract(NftItem.fromAddress(nftItemAddress));

        let nftItemData = await nftItem.getItemData();
        console.log('old owner', nftItemData.owner);

        const nftCollectionData = await nftCollection.getCollectionData();
        console.log('nftCollectionData', nftCollectionData.collection_content.beginParse().loadStringTail());

        // создать новый кошелек
        const user = await blockchain.treasury('user');
        await nftItem.send(
            deployer.getSender(),
            {
                value: toNano('0.2'),
            },
            {
                $$type: 'Transfer',
                new_owner: user.address,
                query_id: 0n,
            },
        );

        nftItemData = await nftItem.getItemData();
        console.log('new owner', nftItemData.owner);
    });
});

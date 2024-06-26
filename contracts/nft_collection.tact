import "@stdlib/deploy";
import "@stdlib/ownable";
import "./nft_item";
import "./messages";

contract NftCollection with Deployable, Ownable {
    const minTonForStorage: Int = ton("0.03");
    const gasConsumption: Int = ton("0.03");
    owner: Address;
    next_item_index: Int as uint32 = 0;
    collection_content: String;
    init(){
        self.owner = sender();
        self.collection_content = "Alina NFT Collection";
    }

    receive("Mint"){
        self.requireOwner();
        self.mint(sender());
    }

    fun mint(receiver: Address) {
        require(self.next_item_index >= 0, "non-sequential NFTs");
        let nft_init: StateInit = self.getNftItemInit(self.next_item_index);
        let msgValue: Int = context().value;
        // кол-во TON coins на балансе до транзакции
        let tonBalanceBeforeMsg: Int = (myBalance() - msgValue);
        // storageFee - планируем оставить в рамках этого сообщения
        let storageFee: Int = (self.minTonForStorage - min(tonBalanceBeforeMsg, self.minTonForStorage));
        // итоговое значение, которое отправится дальше
        msgValue = (msgValue - (storageFee + self.gasConsumption));
        send(SendParameters{
                to: contractAddress(nft_init),
                value: msgValue,
                mode: SendIgnoreErrors,
                body: Transfer{query_id: 0, new_owner: receiver}.toCell(),
                code: nft_init.code,
                data: nft_init.data
            }
        );
        self.next_item_index = (self.next_item_index + 1);
    }

    get fun getNftItemInit(item_index: Int): StateInit {
        let b: StringBuilder = beginString();
        b.append("Item # - ");
        b.append(item_index.toString());
        return initOf NftItem(self.owner, myAddress(), item_index, b.toString());
    }

    get fun nftAddressByIndex(item_index: Int): Address {
        let initCode: StateInit = self.getNftItemInit(item_index);
        return contractAddress(initCode);
    }

    get fun collectionData(): CollectionData {
        return
            CollectionData{
                next_item_index: self.next_item_index,
                // формат строки преобразуем в формат ячейки
                // через slice мы можем читать данные ячейки
                collection_content: self.collection_content.asSlice().asCell(),
                owner_address: self.owner
            };
    }
}

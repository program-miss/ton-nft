message Transfer {
    query_id: Int as uint64;
    new_owner: Address;
}
struct CollectionData {
    next_item_index: Int;
    collection_content: Cell;
    owner_address: Address;
}
struct ItemData {
    owner: Address;
    collection_address: Address;
    item_index: Int;
    individual_content: Cell;
}
struct CollectionMetaData {
    image: String;
    name: String;
    description: String;
    // массивов в tact нет, есть cell
    // social_links: String[];
}

//using artifacts.require to import the SmartContract
const SmartContract = artifacts.require("ContactsContract");
contract("ContactsContract", () => {
  it("Testing smart contract", async () => {
    const smartContract = await SmartContract.deployed();
    //fire the add contact function
    await smartContract.addContact("kyaw kyaw", "XYZ Company", "0927272727");
    const count = await smartContract.getCount();
    assert(count >= 0);
  });
});
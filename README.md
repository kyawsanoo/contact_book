# about the app
A simple flutter contact book app that interact with smart contract deployed on local ethereum blockchain using Truffle & Ganache.
Check [screen shot](https://youtu.be/lnZI3Y33S9Y) for the app's functions in more detail.

# smart contract info
ContactsContract.sol is a smart contract our flutter app will interact on local EVM.
Here is the whole contract code:

```solidity
    // SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.16;

contract ContactsContract {
    uint256 public contactCount;

    struct Contact {
        uint256 id;
        string name;
        string company;
        string phone;
    }

    mapping(uint256 => Contact) public contacts;

    constructor() public{
        contactCount = 0;
    }

    event ContactAdded(uint256 _id);
    event ContactDeleted(uint256 _id);
    event ContactEdited(uint256 _id);

    function getCount() public view returns (uint256 ){
        return contactCount;
    }

    function addContact(
        string memory _name,
        string memory _company,
        string memory _phone
    ) public {
        contacts[contactCount] = Contact(
            contactCount,
            _name,
            _company,
            _phone
        );
        emit ContactAdded(contactCount);
        contactCount++;
    }

    function deleteContact(uint256 _id) public {
        delete contacts[_id];
        contactCount--;
        emit ContactDeleted(_id);
    }

    function editContact(
        uint256 _id,
        string memory _name,
        string memory _company,
        string memory _phone
    ) public {
        contacts[_id] = Contact(_id, _name, _company, _phone);
        emit ContactEdited(_id);
    }

}

```

# before we start
We will use [Truffle](https://github.com/trufflesuite/truffle) for developing our above smart contract on local Ethereum Virtual Machine(EVM). 
Truffle can be easily installed using the following command:
```npm
npm install -g truffle
```
We will also use [Ganache](https://trufflesuite.com/ganache/), a testing local Ethereum blockchain so that we can test and deploy our smart contract before publishing it.
Download Ganache, install and open creating a workspace. 

# how to initialize truffle into flutter project
To initialize Truffle, we need to create a Flutter project first using the following command:
flutter create contact_book
cd contact_book

Once we have the basic Flutter app ready, we can initialize truffle by running:
truffle init
This command will create the following folders for you:
contracts/ : Contains smart contract code.
migrations/: Contains migrations scripts which will be used be truffle to handle deployment.
test/: Contains test scripts
truffle-config.js: Contains truffle configurations

# creating smart contracts in Solidity
Create our smart contract NotesContract.sol file in contracts/ directory.

# compiling and migrating smart contract
Before compile, we must set up truffle config as below
```javascript
module.exports = {
networks: {
development: {
host:
"127.0.0.1", // Localhost (default: none)
port: 7545,        // Standard Ethereum port (default: none)
network_id: "*",   // Any network (default: none)
},
},
contracts_build_directory: "./src/artifacts/",
// Configure your compilers
compilers: {
solc: {
optimizer: {
enabled: false,
runs: 200
},
evmVersion: "byzantium"
}
}
};
```
In the terminal, go to the contracts directory and run the following command:
truffle compile
After successful compilation will show as follow:
> Compiling .\contracts\ContactsContract.sol
> Artifacts written to D:\web3projects\trffle_start_project\contact_book\src\artifacts
> Compiled successfully using:
- solc: 0.5.16+commit.9c3226ce.Emscripten.clang

After that, we need to migrate our smart contract on local EVM server, Ganache. For that, start the Ganache app which will start an instance of Blockchain on port 7545
Now open the truffle-config.js from our project folder and check host and port in it:
```info
host:
"127.0.0.1", // Localhost (default: none)
port: 7545,        // Standard Ethereum port (default: none)
network_id: "*",   // Any network (default: none)
```

We should make sure to check contract abi folder "artifacts" in the truffle-config.js also.
contract_build_directory: "./src/artifacts"

In the migrations/ directory, we will also need a file called 1_initial_migration.js which handles the deployment of our ContatctsContract.sol contract and add the following code in that file:

```javascript

const SmartContract = artifacts.require("ContactsContract");
module.exports = function (deployer) {
deployer.deploy(SmartContract);
};
```


After all, start migrate using command:
truffle migrate
The successful migration will display as follow:
```info
> transaction hash:    0xba0cb4a5c5a3aa2168b2238776300ffeb50906539cbbfb02e6a50c86993bc37d
> Blocks: 0            Seconds: 0                                
> contract address:    0x283B8fE536dEE52D3b59224Cde13147a48A2c33b
> block number:        70
> block timestamp:     1677680416
> account:             0xbC798958C97b816C9b43786D3df8B40766820D1D
> balance:             99.66346668
> gas used:            706532 (0xac7e4)
> gas price:           20 gwei
> value sent:          0 ETH
> total cost:          0.01413064 ETH

> Saving artifacts
> Total cost:          0.01413064 ETH

> Total deployments:   1
> Final cost:          0.01413064 ETH

Once the above migrate command is successfully executed, the first account on Ganache will have slightly less than 100ETH. I
t is due to the transaction cost of migrating smart contracts on the blockchain
```

# flutter packages for interaction with smart contract, state management and UI
http: ^0.13.3
web3dart: ^2.1.4
web_socket_channel: ^2.1.0
provider: ^5.0.0
google_fonts: ^2.1.0
flutter_staggered_grid_view: ^0.4.0

# Linking smart contract in flutter 
Since the app interact with a smart contract, we needs abi of that smart contract to make interaction through.
We can find smart contract abi under the src/artifacts folder named ContactsContract.json, you got it when you deployed a smart contract.
We also need the smart contract address. Using abi and smart contract address, flutter can load deployed smart contract.
We can check linking codes in contacts_controller.dart as follow:

```dart
    init() async {
  _client = Web3Client(_rpcUrl, Client(), socketConnector: () {
    return IOWebSocketChannel.connect(_wsUrl).cast<String>();
  });
  await getAbi();
  await getCredentials();
  await getDeployedContract();
}

```

# ethereum client
Since the app interact with smart contract on local ethereum EVM, 
web3dart will connect a JSON rpc API url of your project, you can check it from Ganache.  
To make a smart contract call with app, we need private key of smart contract deployed wallet address.

Here is the code in flutter:
```dart
   @override
void initState() {
  super.initState();
  _client = Web3Client(_rpcUrl, Client(), socketConnector: () {
    return IOWebSocketChannel.connect(_wsUrl).cast<String>();
  });

}

Future<void> getAbi() async {
  String abiStringFile = await rootBundle
      .loadString("src/artifacts/ContactsContract.json");
  var jsonAbi = jsonDecode(abiStringFile);
  _abiCode = jsonEncode(jsonAbi['abi']);
  _contractAddress =
      EthereumAddress.fromHex(jsonAbi["networks"]["5777"]["address"]);
}

Future<void> getCredentials() async {
  _credentials = EthPrivateKey.fromHex(_privateKey);

}

Future<void> getDeployedContract() async {
  _contract = DeployedContract(
      ContractAbi.fromJson(_abiCode, "ContactsContract"), _contractAddress);
  _count = _contract.function("contactCount");
  _contacts = _contract.function("contacts");
  _addContact = _contract.function("addContact");
  _deleteContact = _contract.function("deleteContact");
  _editContact = _contract.function("editContact");

  _contactAddedEvent = _contract.event("ContactAdded");
  _contactDeletedEvent = _contract.event("ContactDeleted");
  await getContacts();
}


```

# smart contract calls in app
Here is smart contacts contract calls code in flutter for 
- add new contact
- edit existing contact
- delete contact and
- select all contacts 
```dart
     addContact(Contact contact) async {
  debugPrint("creating new contact: name- ${contact.name}, company- ${contact.company}, phone- ${contact.phone}");
  isLoading = true;
  notifyListeners();
  await _client.sendTransaction(
    _credentials,
    Transaction.callContract(
      contract: _contract,
      function: _addContact,
      parameters: [
        contact.name,
        contact.company,
        contact.phone
      ],
    ),
  );
  await getContacts();
}


editContact(Contact contact) async {
  isLoading = true;
  notifyListeners();
  print(BigInt.from(int.parse(contact.id)));
  await _client.sendTransaction(
    _credentials,
    Transaction.callContract(
      contract: _contract,
      function: _editContact,
      parameters: [BigInt.from(int.parse(contact.id)), contact.name, contact.company, contact.phone],
    ),
  );
  await getContacts();
}

deleteContact(int id) async {
  isLoading = true;
  notifyListeners();
  await _client.sendTransaction(
    _credentials,
    Transaction.callContract(
      contract: _contract,
      function: _deleteContact,
      parameters: [BigInt.from(id)],
    ),
  );
  await getContacts();
}

getContacts() async {
  List contactList = await _client
      .call(contract: _contract, function: _count, params: []);
  BigInt totalContacts = contactList[0];
  count = totalContacts.toInt();
  debugPrint("count $count");
  contacts.clear();
  for (int i = 0; i < count; i++) {
    var temp = await _client.call(
        contract: _contract, function: _contacts, params: [BigInt.from(i)]);
    if (temp[1] != "") {
      contacts.add(
        Contact(
          temp[0].toString(),
          name: temp[1],
          company: temp[2],
          phone: temp[3],
        ),
      );
    }
  }
  isLoading = false;
  notifyListeners();
}

```

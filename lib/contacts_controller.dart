import 'dart:convert';
import 'package:dart_web3/dart_web3.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web_socket_channel/io.dart';

import 'contact.dart';


class ContactsController extends ChangeNotifier {
  List<Contact> contacts = [];
  bool isLoading = true;
  late int count;
  final String _rpcUrl = "http://192.168.100.116:7545";
  //"http://127.0.0.1:7545";
  final String _wsUrl = "ws://192.168.100.116:7545/";
      //"ws://127.0.0.1:7545/";
  final String _privateKey =
      //"2e002bc2ad2d9552f1af901c6a06e7cf618d288d48c3d9e20454da3776e17e0c";
      "f029548fc73fc7c91b66272f7089c2c5cdbc4897ac9b6e0bfe3404b0842f7568";

  late Web3Client _client;
  late String _abiCode;

  late Credentials _credentials;
  late EthereumAddress _contractAddress;
  late DeployedContract _contract;

  late ContractFunction _count;
  late ContractFunction _contacts;
  late ContractFunction _addContact;
  late ContractFunction _deleteContact;
  late ContractFunction _editContact;
  late ContractEvent _contactAddedEvent;
  late ContractEvent _contactDeletedEvent;

  ContactsController() {
    init();
  }

  init() async {
    _client = Web3Client(_rpcUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(_wsUrl).cast<String>();
    });
    await getAbi();
    await getCredentials();
    await getDeployedContract();
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

}
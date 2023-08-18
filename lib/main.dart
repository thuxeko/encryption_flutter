import 'package:encrypt_decrypt_app/aesHelper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Encrypt Decrypt Application',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const EncryptionPage(),
    );
  }
}

class EncryptionPage extends StatefulWidget {
  const EncryptionPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EncryptionPageState createState() => _EncryptionPageState();
}

class _EncryptionPageState extends State<EncryptionPage> {
  final GlobalKey<_LeftPageState> _leftPageKey = GlobalKey<_LeftPageState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Encryption App')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            // Larger screens
            return Row(
              children: [
                Expanded(
                  flex: 6,
                  child: LeftPage(key: _leftPageKey),
                ),
                Expanded(
                  flex: 4,
                  child: RightPage(leftPageKey: _leftPageKey),
                ),
              ],
            );
          } else {
            // Mobile screens
            return _buildMobileView();
          }
        },
      ),
    );
  }

  Widget _buildMobileView() {
    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          LeftPage(key: _leftPageKey),
          RightPage(leftPageKey: _leftPageKey),
        ],
      ),
    ));
  }
}

class LeftPage extends StatefulWidget {
  const LeftPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LeftPageState createState() => _LeftPageState();
}

class _LeftPageState extends State<LeftPage> {
  final TextEditingController _passPhraseController = TextEditingController();
  final TextEditingController _keyPairController = TextEditingController();
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  bool _hidePassphrase = true;
  bool _hideKeyPair = true;
  bool _isAES = true;
  String _passphrase = '';
  String _keyPair = '';
  String _input = '';
  String _output = '';

  void _encryptData() {
    var dataInput = _inputController.text;
    var dataEncrypt = _isAES ? AESHelper.encrypt(dataInput, _passphrase) : '';

    setState(() {
      _output = dataEncrypt;
      _outputController.text = _output;
    });
  }

  void _decryptData() {
    var dataInput = _inputController.text;
    var dataDecrypt = _isAES ? AESHelper.decrypt(dataInput, _passphrase) : '';

    setState(() {
      _output = dataDecrypt!;
      _outputController.text = _output;
    });
  }

  void _resetView() {
    setState(() {
      _passPhraseController.text = _keyPairController.text =
          _inputController.text = _outputController.text = '';

      _hidePassphrase = _hideKeyPair = _isAES = true;
      _passphrase = _keyPair = _input = _output = '';
    });
  }

  String getInput() {
    return _input;
  }

  String getOutput() {
    return _output;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Text('Encryption Type:'),
              Radio(
                value: true,
                groupValue: _isAES,
                onChanged: (bool? value) {
                  setState(() {
                    _isAES = value!;
                  });
                },
              ),
              const Text('AES'),
              Radio(
                value: false,
                groupValue: _isAES,
                onChanged: (bool? value) {
                  setState(() {
                    _isAES = value!;
                  });
                },
              ),
              const Text('RSA'),
            ],
          ),
          const SizedBox(height: 16),
          if (_isAES)
            TextField(
              controller: _passPhraseController,
              decoration: InputDecoration(
                  labelText: 'Passphrase',
                  hintText: 'Input your passphrase',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.key),
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _hidePassphrase = !_hidePassphrase;
                        });
                      },
                      icon: Icon(
                        _hidePassphrase
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ))),
              obscureText: _hidePassphrase,
              onChanged: (value) {
                setState(() {
                  _passphrase = value;
                });
              },
            ),
          if (!_isAES)
            TextField(
              controller: _keyPairController,
              keyboardType: TextInputType.multiline,
              maxLines: 1,
              decoration: InputDecoration(
                  labelText: 'Public Key/Private Key',
                  hintText: 'Input public key encrypt - Private key decrypt',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.key),
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _hideKeyPair = !_hideKeyPair;
                        });
                      },
                      icon: Icon(
                        _hideKeyPair ? Icons.visibility_off : Icons.visibility,
                      ))),
              obscureText: _hideKeyPair,
              onChanged: (value) {
                setState(() {
                  _keyPair = value;
                });
              },
            ),
          const SizedBox(height: 16),
          TextField(
              controller: _inputController,
              keyboardType: TextInputType.multiline,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Input',
                hintText: 'Input your data encrypt/decrypt',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _input = value;
                });
              }),
          const SizedBox(height: 16),
          TextField(
            controller: _outputController,
            keyboardType: TextInputType.multiline,
            maxLines: 5,
            decoration: InputDecoration(
                labelText: 'Output',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: _outputController.text));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Copied to clipboard!')));
                    },
                    icon: const Icon(
                      Icons.copy,
                    ))),
            readOnly: true,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _encryptData,
                child: const Text('Encrypt'),
              ),
              ElevatedButton(
                onPressed: _decryptData,
                child: const Text('Decrypt'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _resetView();
                  });
                },
                child: const Text('Clear'),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class RightPage extends StatefulWidget {
  // ignore: library_private_types_in_public_api
  final GlobalKey<_LeftPageState> leftPageKey;

  const RightPage({
    required this.leftPageKey,
    Key? key,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _RightPageState createState() => _RightPageState();
}

class _RightPageState extends State<RightPage> {
  String input = '';
  String output = '';
  String qrData = '';
  bool haveQR = false;

  void genQR() {
    final _LeftPageState leftPageState = widget.leftPageKey.currentState!;

    input = leftPageState.getInput();
    output = leftPageState.getOutput();

    if (output.isEmpty && input.isEmpty) {
      Fluttertoast.showToast(
          msg: 'Not have data create QR Code',
          toastLength: Toast.LENGTH_LONG,
          webPosition: "right",
          timeInSecForIosWeb: 5,
          webBgColor: "linear-gradient(to right, #FF5252, #FF5252)",
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

    setState(() {
      if (output.isNotEmpty || input.isNotEmpty) {
        qrData = output.isNotEmpty ? output : input;
        haveQR = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (!haveQR)
            SizedBox(
              width: 320,
              height: 320,
              child: Image.asset('assets/images/meme_cat.jpg'),
            ),
          if (haveQR)
            Container(
              alignment: Alignment.center,
              child: SizedBox(
                height: 320,
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 320,
                  gapless: false,
                  embeddedImage: const AssetImage('assets/images/meme_cat.jpg'),
                  embeddedImageStyle: const QrEmbeddedImageStyle(
                    size: Size(20, 20),
                  ),
                  errorStateBuilder: (cxt, err) {
                    return const Center(
                      child: Text(
                        'Uh oh! Something went wrong...',
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              genQR();
            },
            child: const Text('Create QR Code'),
          )
        ],
      ),
    );
  }
}

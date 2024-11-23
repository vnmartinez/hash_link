import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/asn1/primitives/asn1_integer.dart' as asn1_integer;
import 'package:pointycastle/asn1/primitives/asn1_sequence.dart'
    as asn1_sequence;
import 'package:pointycastle/export.dart' as pc;

class RSAKeyHelper {
  static ({
    String publicKey,
    String privateKey,
  }) generateRSAKeyPair() {
    final keyParams =
        pc.RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 12);

    final secureRandom = pc.FortunaRandom();
    final seedSource = Uint8List.fromList(
        List.generate(32, (_) => DateTime.now().microsecond % 256));
    secureRandom.seed(pc.KeyParameter(seedSource));

    final keyGen = pc.RSAKeyGenerator()
      ..init(pc.ParametersWithRandom(keyParams, secureRandom));

    final pair = keyGen.generateKeyPair();
    final privateKey = pair.privateKey as pc.RSAPrivateKey;
    final publicKey = pair.publicKey as pc.RSAPublicKey;

    final publicKeyPem = _encodePublicKeyToPem(publicKey);
    final privateKeyPem = _encodePrivateKeyToPem(privateKey);

    return (publicKey: publicKeyPem, privateKey: privateKeyPem);
  }

  static String _encodePublicKeyToPem(pc.RSAPublicKey publicKey) {
    final pem = '''
-----BEGIN RSA PUBLIC KEY-----
${base64.encode(_encodePublicKey(publicKey))}
-----END RSA PUBLIC KEY-----
''';
    return pem;
  }

  static String _encodePrivateKeyToPem(pc.RSAPrivateKey privateKey) {
    final pem = '''
-----BEGIN RSA PRIVATE KEY-----
${base64.encode(_encodePrivateKey(privateKey))}
-----END RSA PRIVATE KEY-----
''';
    return pem;
  }

  static Uint8List _encodePublicKey(pc.RSAPublicKey publicKey) {
    final asn1Seq = asn1_sequence.ASN1Sequence();
    asn1Seq.add(asn1_integer.ASN1Integer(publicKey.modulus!));
    asn1Seq.add(asn1_integer.ASN1Integer(publicKey.exponent!));
    return asn1Seq.encode();
  }

  static Uint8List _encodePrivateKey(pc.RSAPrivateKey privateKey) {
    final asn1Seq = asn1_sequence.ASN1Sequence();
    asn1Seq.add(asn1_integer.ASN1Integer(BigInt.from(0)));
    asn1Seq.add(asn1_integer.ASN1Integer(privateKey.modulus!));
    asn1Seq.add(asn1_integer.ASN1Integer(privateKey.exponent!));
    asn1Seq.add(asn1_integer.ASN1Integer(privateKey.p!));
    asn1Seq.add(asn1_integer.ASN1Integer(privateKey.q!));
    asn1Seq.add(asn1_integer.ASN1Integer(privateKey.privateExponent!));
    return asn1Seq.encode();
  }
}
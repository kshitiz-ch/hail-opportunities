enum Flavor {
  DEV,
  PROD,
}

class F {
  static Flavor? appFlavor;
  // TODO: Refactor this code
  static String get url {
    switch (appFlavor) {
      case Flavor.DEV:
        return 'https://api.buildwealthdev.in';
      case Flavor.PROD:
        return 'https://api.buildwealth.in';
      default:
        return '';
    }
  }

  static String get certificateEnabledUrl {
    switch (appFlavor) {
      case Flavor.DEV:
        return 'https://mapi.buildwealthdev.in';
      case Flavor.PROD:
        return 'https://mapi.buildwealth.in';
      default:
        return '';
    }
  }

  static String get clientCertificate {
    switch (appFlavor) {
      case Flavor.DEV:
        return ApiClientCertificate.devCertificate.trim();
      case Flavor.PROD:
        return ApiClientCertificate.prodCertificate.trim();
      default:
        return '';
    }
  }

  static String get clientCertificateKey {
    switch (appFlavor) {
      case Flavor.DEV:
        return ApiClientCertificate.devCertificateKey.trim();
      case Flavor.PROD:
        return ApiClientCertificate.prodCertificateKey.trim();
      default:
        return '';
    }
  }

  static String get urlTaxy {
    switch (appFlavor) {
      case Flavor.DEV:
        return 'https://api.wealthydev.in';
      case Flavor.PROD:
        return 'https://api.wealthy.in';
      default:
        return '';
    }
  }

  static String get graphqlUrl {
    switch (appFlavor) {
      case Flavor.DEV:
        return 'https://graph.buildwealthdev.in/graphql/';
      case Flavor.PROD:
        return 'https://graph.buildwealth.in/graphql/';
      default:
        return '';
    }
  }

  static String get garageUrl {
    switch (appFlavor) {
      case Flavor.DEV:
        return 'https://api.gragedev.in';
      case Flavor.PROD:
        return 'https://api.grage.in';
      default:
        return '';
    }
  }

  static String get webSocketUrl {
    switch (appFlavor) {
      case Flavor.DEV:
        return 'wss://tpm6sa1uk1.execute-api.ap-south-1.amazonaws.com/development?token=';
      case Flavor.PROD:
        return 'wss://apis.buildwealth.in/realtime?token=';
      default:
        return '';
    }
  }

  static String get quinjetBaseUrl {
    switch (appFlavor) {
      // TODO: update for dev when available
      case Flavor.DEV:
        return '';
      case Flavor.PROD:
        return 'https://quinjet.wealthy.systems/partners';
      default:
        return '';
    }
  }

  static String get fundsApiBaseUrl {
    switch (appFlavor) {
      // TODO: update for dev when available
      case Flavor.DEV:
        return 'https://fundsapi.wealthydev.in';
      case Flavor.PROD:
        return 'https://fundsapi.wealthy.in';
      default:
        return '';
    }
  }

  static String get title {
    switch (appFlavor) {
      case Flavor.DEV:
        return 'Wealthy Partner Dev';
      case Flavor.PROD:
        return 'Wealthy Partner';
      default:
        return 'Wealthy Partner';
    }
  }

  static String get freshChatAppId {
    return "dd0c0de1-99d3-4a57-969a-a460ccde743b";
  }

  static String get freshChatAppKey {
    return "73b52898-d478-40c4-95cb-c9e6bd220348";
  }

  static String get freshChatDomain {
    return "msdk.in.freshchat.com";
  }

  static String get razorPayKey {
    switch (appFlavor) {
      case Flavor.DEV:
        return 'rzp_test_n9Cp5njaben9BP';
      case Flavor.PROD:
        return 'rzp_live_x0UWhoSAzsvhIX';
      default:
        return 'rzp_test_n9Cp5njaben9BP';
    }
  }
}

class ApiClientCertificate {
  static const String prodCertificate = '''
-----BEGIN CERTIFICATE-----
MIIEFTCCAv2gAwIBAgIUSq8gZYfk1B48oVZTvbq0J6BUxDMwDQYJKoZIhvcNAQEL
BQAwgagxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpDYWxpZm9ybmlhMRYwFAYDVQQH
Ew1TYW4gRnJhbmNpc2NvMRkwFwYDVQQKExBDbG91ZGZsYXJlLCBJbmMuMRswGQYD
VQQLExJ3d3cuY2xvdWRmbGFyZS5jb20xNDAyBgNVBAMTK01hbmFnZWQgQ0EgNTZi
MDM3MDQ1NTdkMTdjM2QzZTZkZWJkMWYxMTkwOTYwHhcNMjMwMzAzMTQxNDAwWhcN
MzgwMjI3MTQxNDAwWjAiMQswCQYDVQQGEwJVUzETMBEGA1UEAxMKQ2xvdWRmbGFy
ZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALbh2uOA5KChuA2erCI/
vrxYFIENLQOXYvaErBMpIM26Hfcezj0oB8uSmBC2gAGkZ+DET9ovXsJrIjqoipjV
K7Y3qmsq3Kwg7VLNiLxIxEhz2NghW3rcqVTjeiufk+LGeB2PhFFlwd8b4jrgcS6H
xVJrIY5twOFugWm/xDuJBFSzO1eu/w2KEpUM+hEwSu2smtibJ+OZjKFJBOHkWRpS
NZ7K33gjWeJZTaXpsHI8dkOxdzsI73v7cTVBAnMxMZC8A09cKSF4ug4Oc+COKwFU
2GZhUjX3grzIwRQI/LQxlbV9vKJQvfgQADOtEO0u2lpptVPE1x4lt8lUKsfEd32+
XWkCAwEAAaOBuzCBuDATBgNVHSUEDDAKBggrBgEFBQcDAjAMBgNVHRMBAf8EAjAA
MB0GA1UdDgQWBBQq95w/ON3zAwkkEXYPyjAfpAzpzzAfBgNVHSMEGDAWgBQQKIaU
/SiNnZFLFQgzvMkWRfZ9ZTBTBgNVHR8ETDBKMEigRqBEhkJodHRwOi8vY3JsLmNs
b3VkZmxhcmUuY29tL2E1ZTc5ZDI4LTc3MTQtNDJjNC05NDE0LTNjMzUwZjdlYjE2
My5jcmwwDQYJKoZIhvcNAQELBQADggEBAAr2Fr7tWJZkBHxN+TjthiPBFEqReqBO
Auq79EfaNu1wLxGu412DWmDE/JHi72YtjKNcuY1MmIAnrbYHL14xpNyRP0ahSztv
3V7p2vk7f3oQa2YKz7DUkRwlDRNRg3CrrDCTwklVrlygmHE9dFZtji9i4/dYlqeu
VMT457AJrxsPV9WWAq+KHAhrtJckO8ZKoqB0Iu6mIAyALErPTsequpyuwzfoscPB
qnU2O1TCokSIQuwhilTz2hnuA7fjlbv5XT8EQK8KPFw/gXDkWNn8KLlnXRGKez66
dQmoIEUkfB2oWiqHSLFJ2a+R57xeywb4cwx0OsjtIuegH44ocuJA/hQ=
-----END CERTIFICATE-----
''';

  static const String prodCertificateKey = '''
-----BEGIN PRIVATE KEY-----
MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQC24drjgOSgobgN
nqwiP768WBSBDS0Dl2L2hKwTKSDNuh33Hs49KAfLkpgQtoABpGfgxE/aL17CayI6
qIqY1Su2N6prKtysIO1SzYi8SMRIc9jYIVt63KlU43orn5Pixngdj4RRZcHfG+I6
4HEuh8VSayGObcDhboFpv8Q7iQRUsztXrv8NihKVDPoRMErtrJrYmyfjmYyhSQTh
5FkaUjWeyt94I1niWU2l6bByPHZDsXc7CO97+3E1QQJzMTGQvANPXCkheLoODnPg
jisBVNhmYVI194K8yMEUCPy0MZW1fbyiUL34EAAzrRDtLtpaabVTxNceJbfJVCrH
xHd9vl1pAgMBAAECggEACV9mXzIAJZ5cJzCKXF/9d7wg4uNIuw4jZ4RxqDK7qGeB
OSTGR5qZWazL59FempbxLvMIr6MtXVPtx2lTXxVPvfE45fCmqhiu6Qc5GoM1Mgxj
4OHGxTNxZzUYUguF4gGvbr5n9t768mMEs2VEz7BsI7bzW5AS6krGTaPjG/T/+JI3
x6XNwO/TzNJTlURGJ/CgUtLrkTBJy6cw7wfVfhoyzEvzTasr23wiWuQeHaq6Ronm
xgQTBTIdemydke5BBVrjZm/dvV2oNpRpxp2pn/JodhiL9WHS2Odf3EST0iQAgaxC
S1tdDV/T10DrTpK9BGqv6IK7C9krtAnmUFPYHeqAoQKBgQDf0olB6T0Jd3MBYVbI
YIXyyNEQj+pvaEEPbK0lqtsNE5Q/8kZT4UHUNitxEw4rBry+GONFutrbWPONRF3I
dKbyBIuAVrx8wfAsvlkUSNHoMMAwrb3UEU08nEBnDMgTtdSSBvj+TYErtLwNmamK
/uJtLkTCEs0qD6HOC9knW4LwUQKBgQDRLJMjsejKL4W0WYEtoJWXi4f6xk8jBRbG
2iqHHAeGQVagnncFiPixs//Lkt5/RnhFqww46TBjNcuekPOxZRta7tY1uNAM4V06
ALHg9YWrjhmNdqKoAJ7/CTa7q6fht1jVk2xL7crHYUqkSC4Dc2hP7L6sLiRvX9Ou
Xb0g7zatmQKBgC601Ie4kFAlaQ5kraNq4Qjk9xuprJZK/yik2Qz/Nm7oIwulFx/x
5bbPBwm1nENGSKSytNqcP4d+bHSSS6/FCAGBCUtizjqKjgAISLZ+6660XabK2s4i
Pifjw1y9whK64v0GD3eh3M6uDIAaDNNAlSeLfDWzjrS0RmOk/U/FPPHBAoGAbbyi
3OEjLZ9M19b1DEjo8f5Dsm6Dae3rixs9oHA2ClsQ5Wb9LiwzvJagJd7BV6hSxMn9
uYWs2v+H+YI2NuTCOyx9uOViUL+StzFSIKDuJZiBE1Qf9V+OCmJ9Emv1wVb9Bd83
u4XfEkaacCFl8m2DVhrv1UjH2J4/YYTQCg01dFECgYBhonMtvlF+xmOioEC+tyyg
h7mx5xSGiHoAhpTW1ysq1Ztnec7r4ZmahMDxdf6dmPG1+aL5cHBgneznHyQoOAVB
8WzzuOlsmHRNElWJQtsU13fLSOYcCF+RPYbN3aiDGUr/BsKoJxwJMRpqsAb92PS9
86F50dyUKTZXV0K7aFPANw==
-----END PRIVATE KEY-----
''';

  static const String devCertificate = '''
-----BEGIN CERTIFICATE-----
MIIEFTCCAv2gAwIBAgIUX7rn7Vagh1MIK7UYKn+dKvx8xu8wDQYJKoZIhvcNAQEL
BQAwgagxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpDYWxpZm9ybmlhMRYwFAYDVQQH
Ew1TYW4gRnJhbmNpc2NvMRkwFwYDVQQKExBDbG91ZGZsYXJlLCBJbmMuMRswGQYD
VQQLExJ3d3cuY2xvdWRmbGFyZS5jb20xNDAyBgNVBAMTK01hbmFnZWQgQ0EgNTZi
MDM3MDQ1NTdkMTdjM2QzZTZkZWJkMWYxMTkwOTYwHhcNMjMwMzAzMTQxOTAwWhcN
MzgwMjI3MTQxOTAwWjAiMQswCQYDVQQGEwJVUzETMBEGA1UEAxMKQ2xvdWRmbGFy
ZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMdaA2k6OkFI8VTTMuGA
FTEe6oN1U7BdrVKY7rGNWpPje9gPuKFzs9znDRCijP2sRqbv238nWC0NZ+Yq3U4b
Nvp23DyBm/gmOIMrc/gG+zY14ikSyS9recRo6s1Jj1VoKaVEiXmFBPs9Gf58MK4u
r3jQ5XFa7izkus7ckSeqM29ejuQXxxDo6EQbflpEGhHSyE0VuAWCZj6etpe2GhJp
15ekOr3TpcHAOpZBKNockQOFV4GiN9QdEuCMKAi/1V+QSP5D4R+ug/JmjV2SwAFc
BPk/1Ri6rK62UB2N/90oe3kop35Ku5EsDgvdim4m7oqfJb2QaGdevA5KqnbGPo13
gg8CAwEAAaOBuzCBuDATBgNVHSUEDDAKBggrBgEFBQcDAjAMBgNVHRMBAf8EAjAA
MB0GA1UdDgQWBBQqKemoxeCqjnMpI5Lb/fAOHJxKVDAfBgNVHSMEGDAWgBQQKIaU
/SiNnZFLFQgzvMkWRfZ9ZTBTBgNVHR8ETDBKMEigRqBEhkJodHRwOi8vY3JsLmNs
b3VkZmxhcmUuY29tL2E1ZTc5ZDI4LTc3MTQtNDJjNC05NDE0LTNjMzUwZjdlYjE2
My5jcmwwDQYJKoZIhvcNAQELBQADggEBAAKRmHBKGGfg2GbJTyX9Bspg/txMAoll
RQmKDL/sx7fggiTSZb9Qrk5JfIV5WUatKXqtCYAsARZTVZk1LlRPoDEEZvxBDz+G
tCiylDv8pWhBcHyuTIpe2sCMAYdOUZGC9VohOrLgEo9OnJP2sNDKA4mLK/xT45QB
kZVX3F63B+oEtPAbmHmb+XYA8InsWA/tFPJ7lc8HOTUhyqhNwN5j3GBetc3NZ+3w
Rn4UnfChNhS4At+vp/yZmLtwQnAH31i/BPRNiV3ZGYKFX+SGMdvR52lvm0iGdkOt
wygPD0112cL/O109IyZL8ejXrv/yD3KhgQu/9GyJn0eH4aAPUmh7Cas=
-----END CERTIFICATE-----
''';

  static const String devCertificateKey = '''
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDHWgNpOjpBSPFU
0zLhgBUxHuqDdVOwXa1SmO6xjVqT43vYD7ihc7Pc5w0Qooz9rEam79t/J1gtDWfm
Kt1OGzb6dtw8gZv4JjiDK3P4Bvs2NeIpEskva3nEaOrNSY9VaCmlRIl5hQT7PRn+
fDCuLq940OVxWu4s5LrO3JEnqjNvXo7kF8cQ6OhEG35aRBoR0shNFbgFgmY+nraX
thoSadeXpDq906XBwDqWQSjaHJEDhVeBojfUHRLgjCgIv9VfkEj+Q+EfroPyZo1d
ksABXAT5P9UYuqyutlAdjf/dKHt5KKd+SruRLA4L3YpuJu6KnyW9kGhnXrwOSqp2
xj6Nd4IPAgMBAAECggEAX2T6luMvN0hxe5bpFTGWcoAJ1shROOdK5miaaEptGrHT
9ItpXZEhc8b44In4j/ddg8rprUoljsGIg4LljdfGEkrIjweynCemCVbE0t58Xe+g
/uinb1Kt3UgbfAsEVOlYbGaEpqr5vEP76WSCYweiHl1QPlM2ADOgFRdFOsbegB7V
xu1iOoGMFPkxlDGfGN5zs8bUSeMbNe+iym5WGiLyqVJ5/sz91RiTY2WuXcCvbVWQ
d3r+h6Y/NeedGHUvx1PY5OUQjeOmH0ot9qPHxivnQAfpQJE8EazOYp0YjFGrbVa1
isFF7aA9O+9pjNdxKAW/8X1JhdRyn/7kIqi9fnMs8QKBgQDz+fRqd3FtSCcZmtlB
kPde9NuqN6jJ6hSSnFDcPbynlvLgL19ofYkIqLmOvJbh+gQ8QmfDp0lygUF4Ip4/
rBXMt4a6U+bxSXSgklAGEZhl0qIkUT9wQzETFNHB9S/mKWjg41GIOxtXtgeCPALP
KKGKHx1amLOZ74ynWBjTe7qeNwKBgQDRLRC3VQm/nU9/D+URaWy9sOvxDFOSxWDJ
+/2GtMqZuDZb8SDqE5oBFrxpEYWskl2GiHJctZmBytlT0+zmGCXPDSIEpHLVKAIF
NgS9wduohcM88TkYGoDvnvSGQF/ldLGbFaggzpc3GNx+P0aDaqcBwKRyu9YwfdQw
o/KZNH2O6QKBgQC9nfuXL4PJcnVpEg9eRQPtGhMLhTy6ySH6HGE/+v9/pPLYyBi3
xjFVuISW6f2+XakjCF1LE94ij1DJxOYHCIDc3ZppgEISL4vkLDLjtJMkOANqhHbw
klg2w0yPGTeEA5UOi73XSlDi54eIcYmhZau/BJW0zs9viV1gxjhtTVFqGwKBgQCA
fT80bn8jff00Hs5mCK1sRD5afmjj0mynBixwz6NYE6kIhzDhuJK0MoQfwkyreekL
V8twGXknGjSvYpG1sYWgDwAje+Sx/PZovwrgiTFl7mzEhaS9oqIrDyhDQ03kw+7J
Rd9V77FBffsLbdDhruTRlcUuWSWz+cca7cp6w5yQ6QKBgBABA9agB4AymqOaAMN9
C527RKmxsD2q/ctt9+IeJpWbBOyOR/bSO08F4FW0hDzNiFqOYwoeCkx5e7G8wi/R
DCUnPe4N1hmOgfu6Ql44fy3lHgGYqg2ECFmpFcYiw8gbraZl5O5gJdUjN0PCWBkH
lALvPmo9UqUCgcuYii1iGjsV
-----END PRIVATE KEY-----
''';
}

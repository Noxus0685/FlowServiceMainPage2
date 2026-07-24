// CodeGear C++Builder
// Copyright (c) 1995, 2025 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'OverbyteIcsTypes.pas' rev: 36.00 (Windows)

#ifndef OverbyteIcsTypesHPP
#define OverbyteIcsTypesHPP

#pragma delphiheader begin
#pragma option push
#if defined(__BORLANDC__) && !defined(__clang__)
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member 
#endif
#pragma pack(push,8)
#include <System.hpp>
#include <SysInit.hpp>
#include <Winapi.Windows.hpp>
#include <Winapi.Messages.hpp>
#include <System.SysUtils.hpp>

//-- user supplied -----------------------------------------------------------
#include <mswsock.h>
#include <ws2ipdef.h>
namespace OverbyteIcsWinsock
{
typedef fd_set *PFDSet;
typedef fd_set TFDSet;
}

namespace Overbyteicstypes
{
//-- forward type declarations -----------------------------------------------
struct TIcsIPv6Address;
struct TTcpKeepAlive;
struct TWWWAuthInfo;
//-- type declarations -------------------------------------------------------
using System::Sysutils::TBytes;

typedef unsigned *Psize_t;

typedef unsigned __int64 *PUInt64;

typedef System::WideChar * PSockChar;

typedef void *TWSocketData;

typedef int socklen_t;

typedef timeval *PTimeVal;

typedef timeval TTimeVal;

typedef hostent *PHostEnt;

typedef hostent THostEnt;

typedef netent *PNetEnt;

typedef netent TNetEnt;

typedef servent *PServEnt;

typedef servent TServEnt;

typedef protoent *PProtoEnt;

typedef protoent TProtoEnt;

typedef in_addr *PInAddr;

typedef in_addr TInAddr;

typedef sockaddr_in *PSockAddrIn;

typedef sockaddr_in TSockAddrIn;

typedef WSAData *PWSAData;

typedef WSAData TWSAData;

typedef _TRANSMIT_FILE_BUFFERS *PTransmitFileBuffers;

typedef _TRANSMIT_FILE_BUFFERS TTransmitFileBuffers;

typedef ip_mreq TIpMReq;

typedef ip_mreq *PIpMReq;

typedef sockproto *PSockProto;

typedef sockproto TSockProto;

typedef unsigned TWSAEvent;

typedef Winapi::Windows::PHandle PWSAEvent;

typedef in_addr6 *PInAddr6;

typedef in_addr6 TInAddr6;

typedef sockaddr_in6 *PSockAddrIn6;

typedef sockaddr_in6 TSockAddrIn6;

typedef ipv6_mreq TIPv6MReq;

typedef PIPV6_MREQ PIPv6MReq;

typedef addrinfo TAddrInfoA;

typedef addrinfoW TAddrInfoW;

typedef PADDRINFOW PAddrInfo;

typedef addrinfoW TAddrInfo;

typedef _WSANETWORKEVENTS TWSANetworkEvents;

typedef LPWSANETWORKEVENTS PWSANetworkEvents;

typedef linger *PLinger;

typedef linger TLinger;

enum DECLSPEC_DENUM TSocketFamily : unsigned int { sfAny, sfAnyIPv4, sfAnyIPv6, sfIPv4, sfIPv6 };

typedef in_addr TIcsInAddr;

typedef in_addr *PIcsInAddr;

#pragma pack(push,4)
struct DECLSPEC_DRECORD TIcsIPv6Address
{
public:
	System::StaticArray<System::Word, 8> Words;
};
#pragma pack(pop)


typedef TIcsIPv6Address *PIcsIPv6Address;

typedef System::LongWord TIcsIPv4Address;

typedef unsigned *PIcsIPv4Address;

enum DECLSPEC_DENUM TSocketState : unsigned int { wsInvalidState, wsOpened, wsBound, wsConnecting, wsSocksConnected, wsConnected, wsAccepting, wsListening, wsClosed, wsDnsLookup };

enum DECLSPEC_DENUM TSocketSendFlags : unsigned int { wsSendNormal, wsSendUrgent };

enum DECLSPEC_DENUM TSocketLingerOnOff : unsigned int { wsLingerOff, wsLingerOn, wsLingerNoSet };

enum DECLSPEC_DENUM TSocketKeepAliveOnOff : unsigned int { wsKeepAliveOff, wsKeepAliveOnCustom, wsKeepAliveOnSystem };

enum DECLSPEC_DENUM TSocketErrs : unsigned int { wsErrTech, wsErrFriendly };

enum DECLSPEC_DENUM TWSocketOption : unsigned int { wsoNoReceiveLoop, wsoTcpNoDelay, wsoSIO_RCVALL, wsoNoHttp10Tunnel, wsoNotifyAddressListChange, wsoNotifyRoutingInterfaceChange, wsoAsyncDnsLookup, wsoIcsDnsLookup, wsoUseSTD3AsciiRules, wsoIgnoreIDNA, wsoNoSendException };

typedef System::Set<TWSocketOption, TWSocketOption::wsoNoReceiveLoop, TWSocketOption::wsoNoSendException> TWSocketOptions;

#pragma pack(push,1)
struct DECLSPEC_DRECORD TTcpKeepAlive
{
public:
	unsigned OnOff;
	unsigned KeepAliveTime;
	unsigned KeepAliveInterval;
};
#pragma pack(pop)


enum DECLSPEC_DENUM Overbyteicstypes__1 : unsigned int { htsatBasic, htsatNtlm, htsatDigest };

typedef System::Set<Overbyteicstypes__1, Overbyteicstypes__1::htsatBasic, Overbyteicstypes__1::htsatDigest> THttpTunnelServerAuthTypes;

enum DECLSPEC_DENUM THttpTunnelState : unsigned int { htsData, htsConnecting, htsConnected, htsWaitResp0, htsWaitResp1, htsWaitResp2 };

enum DECLSPEC_DENUM THttpTunnelChunkState : unsigned int { htcsGetSize, htcsGetExt, htcsGetData, htcsGetBoundary, htcsDone };

enum DECLSPEC_DENUM THttpTunnelProto : unsigned int { htp11, htp10 };

enum DECLSPEC_DENUM THttpTunnelReconnectRequest : unsigned int { htrrNone, htrrBasic, htrrDigest, htrrNtlm1 };

enum DECLSPEC_DENUM TSocksState : unsigned int { socksData, socksNegociateMethods, socksAuthenticate, socksConnect };

enum DECLSPEC_DENUM TSocksAuthentication : unsigned int { socksNoAuthentication, socksAuthenticateUsercode };

enum DECLSPEC_DENUM TSocksAuthState : unsigned int { socksAuthStart, socksAuthSuccess, socksAuthFailure, socksAuthNotRequired };

enum DECLSPEC_DENUM TSslState : unsigned int { sslNone, sslHandshakeInit, sslHandshakeStarted, sslHandshakeFailed, sslEstablished, sslInShutdown, sslShutdownComplete };

enum DECLSPEC_DENUM TSslEvent : unsigned int { sslFdRead, sslFdWrite, sslFdClose };

typedef System::Set<TSslEvent, TSslEvent::sslFdRead, TSslEvent::sslFdClose> TSslPendingEvents;

enum DECLSPEC_DENUM TSslMode : unsigned int { sslModeClient, sslModeServer };

enum DECLSPEC_DENUM TLogOption : unsigned int { loDestEvent, loDestFile, loDestOutDebug, loAddStamp, loWsockErr, loWsockInfo, loWsockDump, loSslErr, loSslInfo, loSslDevel, loSslDump, loProtSpecErr, loProtSpecInfo, loProtSpecDump, loProgress };

typedef System::Set<TLogOption, TLogOption::loDestEvent, TLogOption::loProgress> TLogOptions;

enum DECLSPEC_DENUM TLogFileOption : unsigned int { lfoAppend, lfoOverwrite };

enum DECLSPEC_DENUM TLogFileEncoding : unsigned int { lfeUtf8, lfeUtf16 };

enum DECLSPEC_DENUM TNTEventType : unsigned int { etError, etWarning, etInformation, etAuditSuccess, etAuditFailure };

typedef void __fastcall (__closure *TWSockettProgEvent)(System::TObject* Sender, TLogOption LogOption, const System::UnicodeString Msg);

typedef __int64 THttpBigInt;

enum DECLSPEC_DENUM THttpEncoding : unsigned int { encUUEncode, encBase64, encMime };

enum DECLSPEC_DENUM THttpRequest : unsigned int { httpABORT, httpGET, httpPOST, httpPUT, httpHEAD, httpDELETE, httpCLOSE, httpPATCH, httpOPTIONS, httpTRACE };

enum DECLSPEC_DENUM THttpState : unsigned int { httpReady, httpNotConnected, httpConnected, httpDnsLookup, httpDnsLookupDone, httpWaitingHeader, httpWaitingBody, httpBodyReceived, httpWaitingProxyConnect, httpClosing, httpAborting };

enum DECLSPEC_DENUM THttpChunkState : unsigned int { httpChunkGetSize, httpChunkGetExt, httpChunkGetData, httpChunkSkipDataEnd, httpChunkDone };

enum DECLSPEC_DENUM THttpBasicState : unsigned int { basicNone, basicMsg1, basicDone };

enum DECLSPEC_DENUM THttpAuthType : unsigned int { httpAuthNone, httpAuthBasic, httpAuthNtlm, httpAuthDigest, httpAuthBearer, httpAuthToken, httpAuthJWT, httpAuthOAuth, httpAuthDigest2 };

enum DECLSPEC_DENUM THttpCliOption : unsigned int { httpoNoBasicAuth, httpoNoNTLMAuth, httpoBandwidthControl, httpoEnableContentCoding, httpoUseQuality, httpoNoDigestAuth, httpoAllowAnchor, httpoGetContent };

typedef System::Set<THttpCliOption, THttpCliOption::httpoNoBasicAuth, THttpCliOption::httpoGetContent> THttpCliOptions;

#pragma pack(push,4)
struct DECLSPEC_DRECORD TWWWAuthInfo
{
public:
	THttpAuthType AuthType;
	System::UnicodeString Realm;
	System::UnicodeString CharSet;
	System::UnicodeString Uri;
	System::UnicodeString Header;
};
#pragma pack(pop)


typedef System::DynamicArray<TWWWAuthInfo> TWWWAuthInfos;

typedef System::Set<THttpAuthType, THttpAuthType::httpAuthNone, THttpAuthType::httpAuthDigest2> THttpAuthTypes;

enum DECLSPEC_DENUM TSmtpDefaultEncoding : unsigned int { smtpEnc7bit, smtpEnc8bit, smtpEncQuotedPrintable, smtpEncBase64 };

enum DECLSPEC_DENUM TSmtpSendMode : unsigned int { smtpToSocket, smtpToStream, smtpCopyToStream };

enum DECLSPEC_DENUM TSmtpState : unsigned int { smtpReady, smtpDnsLookup, smtpConnecting, smtpConnected, smtpInternalReady, smtpWaitingBanner, smtpWaitingResponse, smtpAbort, smtpInternalBusy };

enum DECLSPEC_DENUM TSmtpMimeState : unsigned int { smtpMimeIntro, smtpMimePlainText, smtpMimeHtmlText, smtpMimeImages, smtpMimeAttach, smtpMimeDone };

enum DECLSPEC_DENUM TSmtpRequest : unsigned int { smtpConnect, smtpHelo, smtpMailFrom, smtpVrfy, smtpRcptTo, smtpData, smtpQuit, smtpRset, smtpOpen, smtpMail, smtpEhlo, smtpAuth, smtpStartTls, smtpCalcMsgSize, smtpMailFromSIZE, smtpToFile, smtpCustom };

enum DECLSPEC_DENUM TSmtpProxyType : unsigned int { smtpNoProxy, smtpSocks4, smtpSocks4A, smtpSocks5, smtpHttpProxy };

enum DECLSPEC_DENUM TSmtpContentType : unsigned int { smtpHtml, smtpPlainText };

enum DECLSPEC_DENUM TSmtpAuthType : unsigned int { smtpAuthNone, smtpAuthPlain, smtpAuthLogin, smtpAuthCramMD5, smtpAuthCramSha1, smtpAuthNtlm, smtpAuthAutoSelect, smtpAuthXOAuth2, smtpAuthOAuthBearer };

enum DECLSPEC_DENUM TSmtpShareMode : unsigned int { smtpShareCompat, smtpShareExclusive, smtpShareDenyWrite, smtpShareDenyRead, smtpShareDenyNone };

enum DECLSPEC_DENUM TSmtpPriority : unsigned int { smtpPriorityNone, smtpPriorityHighest, smtpPriorityHigh, smtpPriorityNormal, smtpPriorityLow, smtpPriorityLowest };

enum DECLSPEC_DENUM TSmtpEncoding : unsigned int { smtpEncodeNone, smtpEncodeBase64, smtpEncodeQP };

enum DECLSPEC_DENUM TSmtpSslType : unsigned int { smtpTlsNone, smtpTlsImplicit, smtpTlsExplicit };

enum DECLSPEC_DENUM TFtpCliSslType : unsigned int { sslTypeNone, sslTypeAuthTls, sslTypeAuthSsl, sslTypeImplicit };

enum DECLSPEC_DENUM TFtpOption : unsigned int { ftpAcceptLF, ftpNoAutoResumeAt, ftpWaitUsingSleep, ftpBandwidthControl, ftpAutoDetectCodePage, ftpFixPasvLanIP, ftpNoExtV4 };

typedef System::Set<TFtpOption, TFtpOption::ftpAcceptLF, TFtpOption::ftpNoExtV4> TFtpOptions;

enum DECLSPEC_DENUM TFtpExtension : unsigned int { ftpFeatNone, ftpFeatSize, ftpFeatRest, ftpFeatMDTMYY, ftpFeatMDTM, ftpFeatMLST, ftpFeatMFMT, ftpFeatMD5, ftpFeatAuthSSL, ftpFeatAuthTLS, ftpFeatProtP, ftpFeatProtC, ftpFeatModeZ, ftpFeatCcc, ftpFeatPbsz, ftpFeatXCrc, ftpFeatXMD5, ftpFeatSitePaswd, ftpFeatSiteExec, ftpFeatSiteIndex, ftpFeatSiteZone, ftpFeatSiteMsg, ftpFeatSiteCmlsd, ftpFeatSiteDmlsd, ftpFeatClnt, ftpFeatComb, ftpFeatUtf8, ftpFeatLang, ftpFeatHost, ftpFeatXCmlsd, ftpFeatXDmlsd, ftpFeatEprt, ftpFeatEpsv };

typedef System::Set<TFtpExtension, TFtpExtension::ftpFeatNone, TFtpExtension::ftpFeatEpsv> TFtpExtensions;

enum DECLSPEC_DENUM TFtpTransMode : unsigned int { ftpTransModeStream, ftpTransModeZDeflate };

enum DECLSPEC_DENUM TZStreamState : unsigned int { ftpZStateNone, ftpZStateSaveDecom, ftpZStateSaveComp };

enum DECLSPEC_DENUM TFtpState : unsigned int { ftpNotConnected, ftpReady, ftpInternalReady, ftpDnsLookup, ftpConnected, ftpAbort, ftpInternalAbort, ftpWaitingBanner, ftpWaitingResponse, ftpPasvReady };

enum DECLSPEC_DENUM TFtpShareMode : unsigned int { ftpShareCompat, ftpShareExclusive, ftpShareDenyWrite, ftpShareDenyRead, ftpShareDenyNone };

enum DECLSPEC_DENUM TFtpDisplayFileMode : unsigned int { ftpLineByLine, ftpBinary };

enum DECLSPEC_DENUM TFtpConnectionType : unsigned int { ftpDirect, ftpProxy, ftpSocks4, ftpSocks4A, ftpSocks5, ftpHttpProxy };

enum DECLSPEC_DENUM TIcsFileCopyType : unsigned int { FCTypeSingle, FCTypeMaskDir, FCTypeArchDir, FCTypeAllDir, FCTypeDates };

enum DECLSPEC_DENUM TIcsFileCopyRepl : unsigned int { FCReplNever, FCReplAlways, FCReplDiff, FCReplNewer };

enum DECLSPEC_DENUM TIcsFileCopyState : unsigned int { FCStateNone, FCStateIgnore, FCStateDir, FCStateSelect, FCStateCopying, FCStateOK, FCStateFailed };

enum DECLSPEC_DENUM TIcsCopyLogLevel : unsigned int { LogLevelInfo, LogLevelFile, LogLevelProg, LogLevelDiag, LogLevelDelimFile, LogLevelDelimTot };

enum DECLSPEC_DENUM TIcsTaskResult : unsigned int { TaskResNone, TaskResOKNew, TaskResOKNone, TaskResFail, TaskResAbort, TaskRunning };

enum DECLSPEC_DENUM TIcsSslCertCheck : unsigned int { SslCCNone, SslCCWarn, SslCCRequire };

typedef System::StaticArray<System::UnicodeString, 6> Overbyteicstypes__2;

typedef System::StaticArray<System::UnicodeString, 6> Overbyteicstypes__3;

typedef System::StaticArray<System::UnicodeString, 3> Overbyteicstypes__4;

enum DECLSPEC_DENUM TSslCliCertMethod : unsigned int { sslCliCertNone, sslCliCertOptional, sslCliCertRequire };

enum DECLSPEC_DENUM TSupplierProto : unsigned int { SuppProtoNone, SuppProtoOwnCA, SuppProtoAcmeV2, SuppProtoCertCentre, SuppProtoServtas };

enum DECLSPEC_DENUM TChallengeType : unsigned int { ChallNone, ChallFileUNC, ChallFileFtp, ChallFileSrv, ChallFileApp, ChallDnsAuto, ChallDnsMan, ChallEmail, ChallAlpnUNC, ChallAlpnSrv, ChallAlpnApp, ChallManual };

enum DECLSPEC_DENUM TSslLoadSource : unsigned int { CertLoadFile, CertWinStoreMachine, CertWinStoreUser };

enum DECLSPEC_DENUM TEvpCipher : unsigned int { Cipher_none, Cipher_aes_128_cbc, Cipher_aes_128_cfb, Cipher_aes_128_ecb, Cipher_aes_128_ofb, Cipher_aes_128_gcm, Cipher_aes_128_ocb, Cipher_aes_128_ccm, Cipher_aes_192_cbc, Cipher_aes_192_cfb, Cipher_aes_192_ecb, Cipher_aes_192_ofb, Cipher_aes_192_gcm, Cipher_aes_192_ocb, Cipher_aes_192_ccm, Cipher_aes_256_cbc, Cipher_aes_256_cfb, Cipher_aes_256_ecb, Cipher_aes_256_ofb, Cipher_aes_256_gcm, Cipher_aes_256_ocb, Cipher_aes_256_ccm, Cipher_bf_cbc, Cipher_bf_cfb64, Cipher_bf_ecb, Cipher_bf_ofb, Cipher_chacha20, Cipher_des_ede3_cbc, Cipher_des_ede3_cfb64, Cipher_des_ede3_ecb, Cipher_des_ede3_ofb, Cipher_idea_cbc, Cipher_idea_cfb64, Cipher_idea_ecb, Cipher_idea_ofb };

enum DECLSPEC_DENUM TEvpDigest : unsigned int { Digest_md5, Digest_mdc2, Digest_sha1, Digest_sha224, Digest_sha256, Digest_sha384, Digest_sha512, Digest_ripemd160, Digest_sha3_224, Digest_sha3_256, Digest_sha3_384, Digest_sha3_512, Digest_shake128, Digest_shake256, Digest_None };

enum DECLSPEC_DENUM TSslPrivKeyType : unsigned int { PrivKeyRsa1024, PrivKeyRsa2048, PrivKeyRsa3072, PrivKeyRsa4096, PrivKeyRsa7680, PrivKeyRsa15360, PrivKeyECsecp256, PrivKeyECsecp384, PrivKeyECsecp512, PrivKeyEd25519, PrivKeyRsaPss2048, PrivKeyRsaPss3072, PrivKeyRsaPss4096, PrivKeyRsaPss7680, PrivKeyRsaPss15360, PrivKeyECsecp256k };

enum DECLSPEC_DENUM TSslPrivKeyCipher : unsigned int { PrivKeyEncNone, PrivKeyEncTripleDES, PrivKeyEncIDEA, PrivKeyEncAES128, PrivKeyEncAES192, PrivKeyEncAES256 };

enum DECLSPEC_DENUM TCertVerMethod : unsigned int { CertVerNone, CertVerBundle, CertVerWinStore, CertVerOwnEvent };

enum DECLSPEC_DENUM THttpDebugLevel : unsigned int { DebugNone, DebugConn, DebugParams, DebugSsl, DebugHdr, DebugBody, DebugSslLow };

enum DECLSPEC_DENUM TCertReadOpt : unsigned int { croNo, croTry, croYes };

enum DECLSPEC_DENUM TChainResult : unsigned int { chainOK, chainFail, chainWarn, chainNone };

enum DECLSPEC_DENUM TSslSecLevel : unsigned int { sslSecLevelAny, sslSecLevel80bits, sslSecLevel112bits, sslSecLevel128bits, sslSecLevel192bits, sslSecLevel256bits };

enum DECLSPEC_DENUM TSslSrvSecurity : unsigned int { sslSrvSecNone, sslSrvSecSsl3, sslSrvSecBack, sslSrvSecInter, sslSrvSecInterFS, sslSrvSecHigh, sslSrvSecHigh128, sslSrvSecHigh192, sslSrvSecTls12Less, sslSrvSecTls13Only };

enum DECLSPEC_DENUM TSslCliSecurity : unsigned int { sslCliSecIgnore, sslCliSecNone, sslCliSecSsl3Only, sslCliSecTls1Only, sslCliSecTls11Only, sslCliSecTls12Only, sslCliSecTls13Only, sslCliSecTls1, sslCliSecTls11, sslCliSecTls12, sslCliSecBack, sslCliSecInter, sslCliSecHigh, sslCliSecHigh128, sslCliSecHigh192 };

//-- var, const, procedure ---------------------------------------------------
static _DELPHI_CONST System::Word OverbyteIcsTypesVersion = System::Word(0x3e8);
extern DELPHI_PACKAGE System::UnicodeString CopyRight;
extern DELPHI_PACKAGE int WSocketGCount;
extern DELPHI_PACKAGE System::Byte GReqVerLow;
extern DELPHI_PACKAGE System::Byte GReqVerHigh;
extern DELPHI_PACKAGE int GIPv6Available;
#define ICS_LOCAL_HOST_V4 L"127.0.0.1"
#define ICS_LOCAL_HOST_V6 L"::1"
#define ICS_LOCAL_HOST_NAME L"localhost"
#define ICS_ANY_HOST_V4 L"0.0.0.0"
#define ICS_ANY_HOST_V6 L"::"
#define ICS_BROADCAST_V4 L"255.255.255.255"
#define ICS_BROADCAST_V6 L"ffff::1"
static _DELPHI_CONST System::WideChar ICS_ANY_PORT = (System::WideChar)(0x30);
static _DELPHI_CONST TSocketFamily DefaultSocketFamily = (TSocketFamily)(3);
#define sHttpVersionError L"Proxy server must support HTTP/1.1"
static _DELPHI_CONST System::Word ICS_SOCKS_BASEERR = System::Word(0x4e20);
static _DELPHI_CONST System::Word ICS_SOCKS_MAXERR = System::Word(0x4e31);
static _DELPHI_CONST System::Word ICS_HTTP_TUNNEL_MAXSTAT = System::Word(0x257);
static _DELPHI_CONST System::Word ICS_HTTP_TUNNEL_BASEERR = System::Word(0x5208);
static _DELPHI_CONST System::Word ICS_HTTP_TUNNEL_MAXERR = System::Word(0x545f);
static _DELPHI_CONST System::Word ICS_HTTP_TUNNEL_PROTERR = System::Word(0x5208);
static _DELPHI_CONST System::Word ICS_HTTP_TUNNEL_GENERR = System::Word(0x5209);
static _DELPHI_CONST System::Word ICS_HTTP_TUNNEL_VERSIONERR = System::Word(0x520a);
static _DELPHI_CONST System::Word socksNoError = System::Word(0x4e20);
static _DELPHI_CONST System::Word socksProtocolError = System::Word(0x4e21);
static _DELPHI_CONST System::Word socksVersionError = System::Word(0x4e22);
static _DELPHI_CONST System::Word socksAuthMethodError = System::Word(0x4e23);
static _DELPHI_CONST System::Word socksGeneralFailure = System::Word(0x4e24);
static _DELPHI_CONST System::Word socksConnectionNotAllowed = System::Word(0x4e25);
static _DELPHI_CONST System::Word socksNetworkUnreachable = System::Word(0x4e26);
static _DELPHI_CONST System::Word socksHostUnreachable = System::Word(0x4e27);
static _DELPHI_CONST System::Word socksConnectionRefused = System::Word(0x4e28);
static _DELPHI_CONST System::Word socksTtlExpired = System::Word(0x4e29);
static _DELPHI_CONST System::Word socksUnknownCommand = System::Word(0x4e2a);
static _DELPHI_CONST System::Word socksUnknownAddressType = System::Word(0x4e2b);
static _DELPHI_CONST System::Word socksUnassignedError = System::Word(0x4e2c);
static _DELPHI_CONST System::Word socksInternalError = System::Word(0x4e2d);
static _DELPHI_CONST System::Word socksDataReceiveError = System::Word(0x4e2e);
static _DELPHI_CONST System::Word socksAuthenticationFailed = System::Word(0x4e2f);
static _DELPHI_CONST System::Word socksRejectedOrFailed = System::Word(0x4e30);
static _DELPHI_CONST System::Word socksHostResolutionFailed = System::Word(0x4e31);
extern DELPHI_PACKAGE System::StaticArray<System::WideChar *, 10> SocketStateNames;
extern DELPHI_PACKAGE System::StaticArray<System::WideChar *, 5> SocketFamilyNames;
#define PROXY_PROTO_HTTP L"http"
#define PROXY_PROTO_SOCKS5 L"socks5"
#define LogAllOptErr (System::Set<TLogOption, TLogOption::loDestEvent, TLogOption::loProgress>() << TLogOption::loWsockErr << TLogOption::loSslErr << TLogOption::loProtSpecErr )
#define LogAllOptInfo (System::Set<TLogOption, TLogOption::loDestEvent, TLogOption::loProgress>() << TLogOption::loWsockErr << TLogOption::loWsockInfo << TLogOption::loSslErr << TLogOption::loSslInfo << TLogOption::loProtSpecErr << TLogOption::loProtSpecInfo )
#define LogAllOptDump (System::Set<TLogOption, TLogOption::loDestEvent, TLogOption::loProgress>() << TLogOption::loWsockErr << TLogOption::loWsockInfo << TLogOption::loWsockDump << TLogOption::loSslErr << TLogOption::loSslInfo << TLogOption::loSslDump << TLogOption::loProtSpecErr << TLogOption::loProtSpecInfo << TLogOption::loProtSpecDump )
static _DELPHI_CONST System::Int8 httperrBase = System::Int8(0x1);
static _DELPHI_CONST System::Int8 httperrNoError = System::Int8(0x0);
static _DELPHI_CONST System::Int8 httperrBusy = System::Int8(0x1);
static _DELPHI_CONST System::Int8 httperrNoData = System::Int8(0x2);
static _DELPHI_CONST System::Int8 httperrAborted = System::Int8(0x3);
static _DELPHI_CONST System::Int8 httperrOverflow = System::Int8(0x4);
static _DELPHI_CONST System::Int8 httperrVersion = System::Int8(0x5);
static _DELPHI_CONST System::Int8 httperrInvalidAuthState = System::Int8(0x6);
static _DELPHI_CONST System::Int8 httperrSslHandShake = System::Int8(0x7);
static _DELPHI_CONST System::Int8 httperrCustomTimeOut = System::Int8(0x8);
static _DELPHI_CONST System::Int8 httperrNoStatusCode = System::Int8(0x9);
static _DELPHI_CONST System::Int8 httperrOutOfMemory = System::Int8(0xa);
static _DELPHI_CONST System::Int8 httperrBgException = System::Int8(0xb);
static _DELPHI_CONST System::Int8 httperrMax = System::Int8(0xb);
extern DELPHI_PACKAGE System::StaticArray<System::WideChar *, 9> HttpCliAuthNames;
extern DELPHI_PACKAGE System::StaticArray<System::WideChar *, 4> SmtpDefEncArray;
#define SmtpEMailSeparators (System::Set<char, _DELPHI_SET_CHAR(0), _DELPHI_SET_CHAR(255)>() << '\x2c' << '\x3b' )
extern DELPHI_PACKAGE System::StaticArray<System::WideChar *, 9> SmtpAuthTypeNames;
extern DELPHI_PACKAGE Overbyteicstypes__2 IcsTaskResultNames;
extern DELPHI_PACKAGE Overbyteicstypes__3 IcsTaskResultStrings;
extern DELPHI_PACKAGE Overbyteicstypes__4 IcsSslCertCheckStrings;
extern DELPHI_PACKAGE System::UnicodeString GLIBEAY_DLL_FileName;
extern DELPHI_PACKAGE System::UnicodeString GSSLEAY_DLL_FileName;
extern DELPHI_PACKAGE bool GSSLStaticLinked;
extern DELPHI_PACKAGE Winapi::Windows::THandle GSSLEAY_DLL_Handle;
extern DELPHI_PACKAGE System::UnicodeString GSSLEAY_DLL_FileVersion;
extern DELPHI_PACKAGE System::UnicodeString GSSLEAY_DLL_FileDescription;
extern DELPHI_PACKAGE bool GSSLEAY_DLL_IgnoreNew;
extern DELPHI_PACKAGE bool GSSLEAY_DLL_IgnoreOld;
extern DELPHI_PACKAGE int GSSL_BUFFER_SIZE;
extern DELPHI_PACKAGE System::UnicodeString GSSL_DLL_DIR;
extern DELPHI_PACKAGE bool GSSL_SignTest_Check;
extern DELPHI_PACKAGE bool GSSL_SignTest_Certificate;
extern DELPHI_PACKAGE bool GSSL_SignTest_Failed;
extern DELPHI_PACKAGE System::UnicodeString GSSL_SignTest_FailError;
extern DELPHI_PACKAGE unsigned ICS_OPENSSL_VERSION_NUMBER;
extern DELPHI_PACKAGE bool ICS_SSL_NO_RENEGOTIATION;
extern DELPHI_PACKAGE bool ICS_RAND_INIT_DONE;
extern DELPHI_PACKAGE int ICS_OPENSSL_VERSION_MAJOR;
extern DELPHI_PACKAGE int ICS_OPENSSL_VERSION_MINOR;
extern DELPHI_PACKAGE int ICS_OPENSSL_VERSION_PATCH;
extern DELPHI_PACKAGE System::UnicodeString ICS_OPENSSL_VERSION_PRE_RELEASE;
extern DELPHI_PACKAGE bool ICS_OSSL3_LOADED_LEGACY;
extern DELPHI_PACKAGE bool ICS_OSSL3_LOADED_FIPS;
extern DELPHI_PACKAGE bool GSSLEAY_LOAD_LEGACY;
extern DELPHI_PACKAGE void *GSSLEAY_PROVIDER_DEFAULT;
extern DELPHI_PACKAGE void *GSSLEAY_PROVIDER_LEGACY;
extern DELPHI_PACKAGE void *GSSLEAY_PROVIDER_FIPS;
extern DELPHI_PACKAGE System::UnicodeString GSSL_RES_SUBDIR;
extern DELPHI_PACKAGE System::UnicodeString GSSL_PUBLIC_DIR;
extern DELPHI_PACKAGE System::UnicodeString GSSL_CERTS_SUBDIR;
extern DELPHI_PACKAGE System::UnicodeString GSSL_ROOTS_SUBDIR;
extern DELPHI_PACKAGE System::UnicodeString GSSL_ROOTCA_NAME;
extern DELPHI_PACKAGE System::UnicodeString GSSL_LOCALHOST_NAME;
extern DELPHI_PACKAGE System::UnicodeString GSSL_INTER_NAME;
extern DELPHI_PACKAGE System::UnicodeString GSSL_DEFROOT_NAME;
extern DELPHI_PACKAGE System::UnicodeString GSSL_EXTRAROOT_NAME;
extern DELPHI_PACKAGE System::UnicodeString GSSL_CERTS_DIR;
extern DELPHI_PACKAGE System::UnicodeString GSSL_ROOTS_DIR;
extern DELPHI_PACKAGE System::UnicodeString GSSL_INTER_FILE;
extern DELPHI_PACKAGE System::UnicodeString GSSL_INTER_CNAME;
extern DELPHI_PACKAGE int ICS_NID_acmeIdentifier;
static _DELPHI_CONST System::Int8 OSSL_VER_MIN = System::Int8(0xf);
static _DELPHI_CONST int OSSL_VER_1101 = int(0x1010100f);
static _DELPHI_CONST int OSSL_VER_1101ZZ = int(0x10101fff);
static _DELPHI_CONST int OSSL_VER_3000 = int(0x30000000);
static _DELPHI_CONST int OSSL_VER_3100 = int(0x30100000);
static _DELPHI_CONST int OSSL_VER_3200 = int(0x30200000);
static _DELPHI_CONST int OSSL_VER_3300 = int(0x30300000);
static _DELPHI_CONST int OSSL_VER_3400 = int(0x30400000);
static _DELPHI_CONST int OSSL_VER_3LAST = int(0x3fffffff);
static _DELPHI_CONST unsigned OSSL_VER_MAX = unsigned(0xffffffff);
static _DELPHI_CONST int MIN_OSSL_VER = int(0x30000000);
static _DELPHI_CONST int MAX_OSSL_VER = int(0x3fffffff);
extern DELPHI_PACKAGE System::StaticArray<TEvpCipher, 6> SslPrivKeyEvpCipher;
static _DELPHI_CONST TSslSrvSecurity sslSrvSecDefault = (TSslSrvSecurity)(5);
static _DELPHI_CONST TSslCliSecurity sslCliSecDefault = (TSslCliSecurity)(9);
extern DELPHI_PACKAGE System::StaticArray<System::WideChar *, 10> SslSrvSecurityNames;
extern DELPHI_PACKAGE System::StaticArray<System::WideChar *, 15> SslCliSecurityNames;
extern DELPHI_PACKAGE System::StaticArray<System::WideChar *, 4> CertVerMethodNames;
#define ALPN_ID_HTTP10 L"http/1.0"
#define ALPN_ID_HTTP11 L"http/1.1"
#define ALPN_ID_HTTP2 L"h2"
#define ALPN_ID_HTTP3 L"h3"
#define ALPN_ID_HTTP2S L"h2s"
#define ALPN_ID_HTTP214 L"h2-14"
#define ALPN_ID_SPDY3 L"spdy/3"
#define ALPN_ID_SPDY31 L"spdy/3.1"
#define ALPN_ID_TURN L"stun.turn"
#define ALPN_ID_STUN L"stun.nat-discovery"
#define ALPN_ID_WEBRTC L"webrtc"
#define ALPN_ID_CWEBRTC L"c-webrtc"
#define ALPN_ID_FTP L"ftp"
#define ALPN_ID_IMAP L"imap"
#define ALPN_ID_POP3 L"pop3"
#define ALPN_ID_ACME_TLS1 L"acme-tls/1"
#define ALPN_ID_DNS_TCP L"dot"
#define ALPN_ID_MQTT L"mqtt"
static _DELPHI_CONST System::Int8 X509_V_OK = System::Int8(0x0);
static _DELPHI_CONST System::Int8 X509_V_ERR_UNABLE_TO_GET_ISSUER_CERT = System::Int8(0x2);
static _DELPHI_CONST System::Int8 X509_V_ERR_UNABLE_TO_GET_CRL = System::Int8(0x3);
static _DELPHI_CONST System::Int8 X509_V_ERR_UNABLE_TO_DECRYPT_CERT_SIGNATURE = System::Int8(0x4);
static _DELPHI_CONST System::Int8 X509_V_ERR_UNABLE_TO_DECRYPT_CRL_SIGNATURE = System::Int8(0x5);
static _DELPHI_CONST System::Int8 X509_V_ERR_UNABLE_TO_DECODE_ISSUER_PUBLIC_KEY = System::Int8(0x6);
static _DELPHI_CONST System::Int8 X509_V_ERR_CERT_SIGNATURE_FAILURE = System::Int8(0x7);
static _DELPHI_CONST System::Int8 X509_V_ERR_CRL_SIGNATURE_FAILURE = System::Int8(0x8);
static _DELPHI_CONST System::Int8 X509_V_ERR_CERT_NOT_YET_VALID = System::Int8(0x9);
static _DELPHI_CONST System::Int8 X509_V_ERR_CERT_HAS_EXPIRED = System::Int8(0xa);
static _DELPHI_CONST System::Int8 X509_V_ERR_CRL_NOT_YET_VALID = System::Int8(0xb);
static _DELPHI_CONST System::Int8 X509_V_ERR_CRL_HAS_EXPIRED = System::Int8(0xc);
static _DELPHI_CONST System::Int8 X509_V_ERR_ERROR_IN_CERT_NOT_BEFORE_FIELD = System::Int8(0xd);
static _DELPHI_CONST System::Int8 X509_V_ERR_ERROR_IN_CERT_NOT_AFTER_FIELD = System::Int8(0xe);
static _DELPHI_CONST System::Int8 X509_V_ERR_ERROR_IN_CRL_LAST_UPDATE_FIELD = System::Int8(0xf);
static _DELPHI_CONST System::Int8 X509_V_ERR_ERROR_IN_CRL_NEXT_UPDATE_FIELD = System::Int8(0x10);
static _DELPHI_CONST System::Int8 X509_V_ERR_OUT_OF_MEM = System::Int8(0x11);
static _DELPHI_CONST System::Int8 X509_V_ERR_DEPTH_ZERO_SELF_SIGNED_CERT = System::Int8(0x12);
static _DELPHI_CONST System::Int8 X509_V_ERR_SELF_SIGNED_CERT_IN_CHAIN = System::Int8(0x13);
static _DELPHI_CONST System::Int8 X509_V_ERR_UNABLE_TO_GET_ISSUER_CERT_LOCALLY = System::Int8(0x14);
static _DELPHI_CONST System::Int8 X509_V_ERR_UNABLE_TO_VERIFY_LEAF_SIGNATURE = System::Int8(0x15);
static _DELPHI_CONST System::Int8 X509_V_ERR_CERT_CHAIN_TOO_LONG = System::Int8(0x16);
static _DELPHI_CONST System::Int8 X509_V_ERR_CERT_REVOKED = System::Int8(0x17);
static _DELPHI_CONST System::Int8 X509_V_ERR_INVALID_CA = System::Int8(0x18);
static _DELPHI_CONST System::Int8 X509_V_ERR_PATH_LENGTH_EXCEEDED = System::Int8(0x19);
static _DELPHI_CONST System::Int8 X509_V_ERR_INVALID_PURPOSE = System::Int8(0x1a);
static _DELPHI_CONST System::Int8 X509_V_ERR_CERT_UNTRUSTED = System::Int8(0x1b);
static _DELPHI_CONST System::Int8 X509_V_ERR_CERT_REJECTED = System::Int8(0x1c);
static _DELPHI_CONST System::Int8 X509_V_ERR_SUBJECT_ISSUER_MISMATCH = System::Int8(0x1d);
static _DELPHI_CONST System::Int8 X509_V_ERR_AKID_SKID_MISMATCH = System::Int8(0x1e);
static _DELPHI_CONST System::Int8 X509_V_ERR_AKID_ISSUER_SERIAL_MISMATCH = System::Int8(0x1f);
static _DELPHI_CONST System::Int8 X509_V_ERR_KEYUSAGE_NO_CERTSIGN = System::Int8(0x20);
static _DELPHI_CONST System::Int8 X509_V_ERR_UNABLE_TO_GET_CRL_ISSUER = System::Int8(0x21);
static _DELPHI_CONST System::Int8 X509_V_ERR_UNHANDLED_CRITICAL_EXTENSION = System::Int8(0x22);
static _DELPHI_CONST System::Int8 X509_V_ERR_KEYUSAGE_NO_CRL_SIGN = System::Int8(0x23);
static _DELPHI_CONST System::Int8 X509_V_ERR_UNHANDLED_CRITICAL_CRL_EXTENSION = System::Int8(0x24);
static _DELPHI_CONST System::Int8 X509_V_ERR_INVALID_NON_CA = System::Int8(0x25);
static _DELPHI_CONST System::Int8 X509_V_ERR_PROXY_PATH_LENGTH_EXCEEDED = System::Int8(0x26);
static _DELPHI_CONST System::Int8 X509_V_ERR_KEYUSAGE_NO_DIGITAL_SIGNATURE = System::Int8(0x27);
static _DELPHI_CONST System::Int8 X509_V_ERR_PROXY_CERTIFICATES_NOT_ALLOWED = System::Int8(0x28);
static _DELPHI_CONST System::Int8 X509_V_ERR_INVALID_EXTENSION = System::Int8(0x29);
static _DELPHI_CONST System::Int8 X509_V_ERR_INVALID_POLICY_EXTENSION = System::Int8(0x2a);
static _DELPHI_CONST System::Int8 X509_V_ERR_NO_EXPLICIT_POLICY = System::Int8(0x2b);
static _DELPHI_CONST System::Int8 X509_V_ERR_DIFFERENT_CRL_SCOPE = System::Int8(0x2c);
static _DELPHI_CONST System::Int8 X509_V_ERR_UNSUPPORTED_EXTENSION_FEATURE = System::Int8(0x2d);
static _DELPHI_CONST System::Int8 X509_V_ERR_UNNESTED_RESOURCE = System::Int8(0x2e);
static _DELPHI_CONST System::Int8 X509_V_ERR_PERMITTED_VIOLATION = System::Int8(0x2f);
static _DELPHI_CONST System::Int8 X509_V_ERR_EXCLUDED_VIOLATION = System::Int8(0x30);
static _DELPHI_CONST System::Int8 X509_V_ERR_SUBTREE_MINMAX = System::Int8(0x31);
static _DELPHI_CONST System::Int8 X509_V_ERR_APPLICATION_VERIFICATION = System::Int8(0x32);
static _DELPHI_CONST System::Int8 X509_V_ERR_UNSUPPORTED_CONSTRAINT_TYPE = System::Int8(0x33);
static _DELPHI_CONST System::Int8 X509_V_ERR_UNSUPPORTED_CONSTRAINT_SYNTAX = System::Int8(0x34);
static _DELPHI_CONST System::Int8 X509_V_ERR_UNSUPPORTED_NAME_SYNTAX = System::Int8(0x35);
static _DELPHI_CONST System::Int8 X509_V_ERR_CRL_PATH_VALIDATION_ERROR = System::Int8(0x36);
static _DELPHI_CONST System::Int8 X509_V_ERR_PATH_LOOP = System::Int8(0x37);
static _DELPHI_CONST System::Int8 X509_V_ERR_SUITE_B_INVALID_VERSION = System::Int8(0x38);
static _DELPHI_CONST System::Int8 X509_V_ERR_SUITE_B_INVALID_ALGORITHM = System::Int8(0x39);
static _DELPHI_CONST System::Int8 X509_V_ERR_SUITE_B_INVALID_CURVE = System::Int8(0x3a);
static _DELPHI_CONST System::Int8 X509_V_ERR_SUITE_B_INVALID_SIGNATURE_ALGORITHM = System::Int8(0x3b);
static _DELPHI_CONST System::Int8 X509_V_ERR_SUITE_B_LOS_NOT_ALLOWED = System::Int8(0x3c);
static _DELPHI_CONST System::Int8 X509_V_ERR_SUITE_B_CANNOT_SIGN_P_384_WITH_P_256 = System::Int8(0x3d);
static _DELPHI_CONST System::Int8 X509_V_ERR_HOSTNAME_MISMATCH = System::Int8(0x3e);
static _DELPHI_CONST System::Int8 X509_V_ERR_EMAIL_MISMATCH = System::Int8(0x3f);
static _DELPHI_CONST System::Int8 X509_V_ERR_IP_ADDRESS_MISMATCH = System::Int8(0x40);
static _DELPHI_CONST System::Int8 X509_V_ERR_DANE_NO_MATCH = System::Int8(0x41);
static _DELPHI_CONST System::Int8 X509_V_ERR_EE_KEY_TOO_SMALL = System::Int8(0x42);
static _DELPHI_CONST System::Int8 X509_V_ERR_CA_KEY_TOO_SMALL = System::Int8(0x43);
static _DELPHI_CONST System::Int8 X509_V_ERR_CA_MD_TOO_WEAK = System::Int8(0x44);
static _DELPHI_CONST System::Int8 X509_V_ERR_INVALID_CALL = System::Int8(0x45);
static _DELPHI_CONST System::Int8 X509_V_ERR_STORE_LOOKUP = System::Int8(0x46);
static _DELPHI_CONST System::Int8 X509_V_ERR_NO_VALID_SCTS = System::Int8(0x47);
static _DELPHI_CONST System::Int8 X509_V_ERR_PROXY_SUBJECT_NAME_VIOLATION = System::Int8(0x48);
static _DELPHI_CONST System::Int8 OCSP_REVOKED_STATUS_NOSTATUS = System::Int8(-1);
static _DELPHI_CONST System::Int8 OCSP_REVOKED_STATUS_UNSPECIFIED = System::Int8(0x0);
static _DELPHI_CONST System::Int8 OCSP_REVOKED_STATUS_KEYCOMPROMISE = System::Int8(0x1);
static _DELPHI_CONST System::Int8 OCSP_REVOKED_STATUS_CACOMPROMISE = System::Int8(0x2);
static _DELPHI_CONST System::Int8 OCSP_REVOKED_STATUS_AFFILIATIONCHANGED = System::Int8(0x3);
static _DELPHI_CONST System::Int8 OCSP_REVOKED_STATUS_SUPERSEDED = System::Int8(0x4);
static _DELPHI_CONST System::Int8 OCSP_REVOKED_STATUS_CESSATIONOFOPERATION = System::Int8(0x5);
static _DELPHI_CONST System::Int8 OCSP_REVOKED_STATUS_CERTIFICATEHOLD = System::Int8(0x6);
static _DELPHI_CONST System::Int8 OCSP_REVOKED_STATUS_REMOVEFROMCRL = System::Int8(0x8);
static _DELPHI_CONST System::Int8 OCSP_DEFAULT_NONCE_LENGTH = System::Int8(0x10);
static _DELPHI_CONST System::Int8 OCSP_NOCERTS = System::Int8(0x1);
static _DELPHI_CONST System::Int8 OCSP_NOINTERN = System::Int8(0x2);
static _DELPHI_CONST System::Int8 OCSP_NOSIGS = System::Int8(0x4);
static _DELPHI_CONST System::Int8 OCSP_NOCHAIN = System::Int8(0x8);
static _DELPHI_CONST System::Int8 OCSP_NOVERIFY = System::Int8(0x10);
static _DELPHI_CONST System::Int8 OCSP_NOEXPLICIT = System::Int8(0x20);
static _DELPHI_CONST System::Int8 OCSP_NOCASIGN = System::Int8(0x40);
static _DELPHI_CONST System::Byte OCSP_NODELEGATED = System::Byte(0x80);
static _DELPHI_CONST System::Word OCSP_NOCHECKS = System::Word(0x100);
static _DELPHI_CONST System::Word OCSP_TRUSTOTHER = System::Word(0x200);
static _DELPHI_CONST System::Word OCSP_RESPID_KEY = System::Word(0x400);
static _DELPHI_CONST System::Word OCSP_NOTIME = System::Word(0x800);
static _DELPHI_CONST System::Word OCSP_PARTIAL_CHAIN = System::Word(0x1000);
static _DELPHI_CONST System::Int8 OCSP_RESPONSE_STATUS_SUCCESSFUL = System::Int8(0x0);
static _DELPHI_CONST System::Int8 OCSP_RESPONSE_STATUS_MALFORMEDREQUEST = System::Int8(0x1);
static _DELPHI_CONST System::Int8 OCSP_RESPONSE_STATUS_INTERNALERROR = System::Int8(0x2);
static _DELPHI_CONST System::Int8 OCSP_RESPONSE_STATUS_TRYLATER = System::Int8(0x3);
static _DELPHI_CONST System::Int8 OCSP_RESPONSE_STATUS_SIGREQUIRED = System::Int8(0x5);
static _DELPHI_CONST System::Int8 OCSP_RESPONSE_STATUS_UNAUTHORIZED = System::Int8(0x6);
static _DELPHI_CONST System::Int8 V_OCSP_RESPID_NAME = System::Int8(0x0);
static _DELPHI_CONST System::Int8 V_OCSP_RESPID_KEY = System::Int8(0x1);
static _DELPHI_CONST System::Int8 V_OCSP_CERTSTATUS_GOOD = System::Int8(0x0);
static _DELPHI_CONST System::Int8 V_OCSP_CERTSTATUS_REVOKED = System::Int8(0x1);
static _DELPHI_CONST System::Int8 V_OCSP_CERTSTATUS_UNKNOWN = System::Int8(0x2);
#define PEM_STRING_OCSP_REQUEST L"OCSP REQUEST"
#define PEM_STRING_OCSP_RESPONSE L"OCSP RESPONSE"
static _DELPHI_CONST System::Int8 Ics_CERT_TRUST_NO_ERROR = System::Int8(0x0);
static _DELPHI_CONST System::Int8 Ics_CERT_TRUST_IS_NOT_TIME_VALID = System::Int8(0x1);
static _DELPHI_CONST System::Int8 Ics_CERT_TRUST_IS_NOT_TIME_NESTED = System::Int8(0x2);
static _DELPHI_CONST System::Int8 Ics_CERT_TRUST_IS_REVOKED = System::Int8(0x4);
static _DELPHI_CONST System::Int8 Ics_CERT_TRUST_IS_NOT_SIGNATURE_VALID = System::Int8(0x8);
static _DELPHI_CONST System::Int8 Ics_CERT_TRUST_IS_NOT_VALID_FOR_USAGE = System::Int8(0x10);
static _DELPHI_CONST System::Int8 Ics_CERT_TRUST_IS_UNTRUSTED_ROOT = System::Int8(0x20);
static _DELPHI_CONST System::Int8 Ics_CERT_TRUST_REVOCATION_STATUS_UNKNOWN = System::Int8(0x40);
static _DELPHI_CONST System::Byte Ics_CERT_TRUST_IS_CYCLIC = System::Byte(0x80);
static _DELPHI_CONST int Ics_CERT_TRUST_IS_OFFLINE_REVOCATION = int(0x1000000);
extern DELPHI_PACKAGE System::StaticArray<TEvpDigest, 9> DigestDispList;
static _DELPHI_CONST System::Int8 DigestListLitsLast = System::Int8(0x8);
extern DELPHI_PACKAGE System::StaticArray<System::WideChar *, 9> DigestListLits;
extern DELPHI_PACKAGE System::StaticArray<System::WideChar *, 15> EvpDigestLits;
static _DELPHI_CONST System::Int8 SslPrivKeyTypeLitsLast1 = System::Int8(0x9);
static _DELPHI_CONST System::Int8 SslPrivKeyTypeLitsLast2 = System::Int8(0xf);
extern DELPHI_PACKAGE System::StaticArray<System::WideChar *, 16> SslPrivKeyTypeLits;
extern DELPHI_PACKAGE System::StaticArray<System::WideChar *, 6> SslPrivKeyCipherLits;
#define SslCertFileOpenExts L"Certs *.pem;*.cer;*.crt;*.der;*.p12;*.pfx;*.p7*;*.spc|*.pe"\
	L"m;*.cer;*.crt;*.der;*.p12;*.pfx;*.p7*;*.spc|All Files *.*|"\
	L"*.*"
static _DELPHI_CONST System::WideChar IcsNULL = (System::WideChar)(0x0);
static _DELPHI_CONST System::WideChar IcsSTX = (System::WideChar)(0x2);
static _DELPHI_CONST System::WideChar IcsETX = (System::WideChar)(0x3);
static _DELPHI_CONST System::WideChar IcsEOT = (System::WideChar)(0x4);
static _DELPHI_CONST System::WideChar IcsBACKSPACE = (System::WideChar)(0x8);
static _DELPHI_CONST System::WideChar IcsTAB = (System::WideChar)(0x9);
static _DELPHI_CONST System::WideChar IcsLF = (System::WideChar)(0xa);
static _DELPHI_CONST System::WideChar IcsFF = (System::WideChar)(0xc);
static _DELPHI_CONST System::WideChar IcsCR = (System::WideChar)(0xd);
static _DELPHI_CONST System::WideChar IcsEOF = (System::WideChar)(0x1a);
static _DELPHI_CONST System::WideChar IcsESC = (System::WideChar)(0x1b);
static _DELPHI_CONST System::WideChar IcsFIELDSEP = (System::WideChar)(0x1c);
static _DELPHI_CONST System::WideChar IcsRECSEP = (System::WideChar)(0x1e);
static _DELPHI_CONST System::WideChar IcsBLANK = (System::WideChar)(0x20);
static _DELPHI_CONST System::WideChar IcsSQUOTE = (System::WideChar)(0x27);
static _DELPHI_CONST System::WideChar IcsDQUOTE = (System::WideChar)(0x22);
static _DELPHI_CONST System::WideChar IcsSPACE = (System::WideChar)(0x20);
static _DELPHI_CONST System::WideChar IcsHEX_PREFIX = (System::WideChar)(0x24);
#define IcsCRLF L"\r\n"
#define IcsDoubleCRLF L"\r\n\r\n"
static _DELPHI_CONST System::WideChar IcsCOLON = (System::WideChar)(0x3a);
static _DELPHI_CONST System::WideChar IcsCOMMA = (System::WideChar)(0x2c);
static _DELPHI_CONST System::WideChar IcsCURLYO = (System::WideChar)(0x7b);
static _DELPHI_CONST System::WideChar IcsCURLYC = (System::WideChar)(0x7d);
static _DELPHI_CONST System::WideChar IcsAmpersand = (System::WideChar)(0x26);
static _DELPHI_CONST System::Int8 IcsbNULL = System::Int8(0x0);
static _DELPHI_CONST System::Int8 IcsbSTX = System::Int8(0x2);
static _DELPHI_CONST System::Int8 IcsbETX = System::Int8(0x3);
static _DELPHI_CONST System::Int8 IcsbEOT = System::Int8(0x4);
static _DELPHI_CONST System::Int8 IcsbBACKSPACE = System::Int8(0x8);
static _DELPHI_CONST System::Int8 IcsbTAB = System::Int8(0x9);
static _DELPHI_CONST System::Int8 IcsbLF = System::Int8(0xa);
static _DELPHI_CONST System::Int8 IcsbFF = System::Int8(0xc);
static _DELPHI_CONST System::Int8 IcsbCR = System::Int8(0xd);
static _DELPHI_CONST System::Int8 IcsbEOF = System::Int8(0x1a);
static _DELPHI_CONST System::Int8 IcsbESC = System::Int8(0x1b);
static _DELPHI_CONST System::Int8 IcsbFIELDSEP = System::Int8(0x1c);
static _DELPHI_CONST System::Int8 IcsbRECSEP = System::Int8(0x1e);
static _DELPHI_CONST System::Int8 IcsbBLANK = System::Int8(0x20);
static _DELPHI_CONST System::Int8 IcsbSQUOTE = System::Int8(0x27);
static _DELPHI_CONST System::Int8 IcsbDQUOTE = System::Int8(0x22);
static _DELPHI_CONST System::Int8 IcsbSPACE = System::Int8(0x20);
extern DELPHI_PACKAGE System::LongWord TicksPerDay;
extern DELPHI_PACKAGE System::LongWord TicksPerHour;
extern DELPHI_PACKAGE System::LongWord TicksPerMinute;
extern DELPHI_PACKAGE System::LongWord TicksPerSecond;
extern DELPHI_PACKAGE System::LongWord TriggerDisabled;
extern DELPHI_PACKAGE System::LongWord TriggerImmediate;
extern DELPHI_PACKAGE System::TDateTime OneSecondDT;
extern DELPHI_PACKAGE System::TDateTime OneMinuteDT;
#define MinutesPerDay  (1.440000E+03)
#define ISOTimeMask L"hh:nn:ss"
#define ISOLongTimeMask L"hh:nn:ss:zzz"
#define ISODateMask L"yyyy-mm-dd"
#define ISODateTimeMask L"yyyy-mm-dd\"T\"hh:nn:ss"
#define ISODateLongTimeMask L"yyyy-mm-dd\"T\"hh:nn:ss.zzz"
#define DateAlphaMask L"dd-mmm-yyyy"
#define SDateMaskPacked L"yymmddhhnnss"
#define DateTimeAlphaMask L"dd-mmm-yyyy hh:nn:ss"
#define DateMmmMask L"dd mmm yyyy"
#define ACE_PREFIX L"xn--"
static _DELPHI_CONST System::Word IcsKBYTE = System::Word(0x400);
static _DELPHI_CONST int IcsMBYTE = int(0x100000);
static _DELPHI_CONST int IcsGBYTE = int(0x40000000);
#define sPathExtended L"\\\\?\\"
#define sPathExtendedUNC L"\\\\?\\UNC\\"
static _DELPHI_CONST System::Word IcsMaxPath = System::Word(0x104);
}	/* namespace Overbyteicstypes */
#if !defined(DELPHIHEADER_NO_IMPLICIT_NAMESPACE_USE) && !defined(NO_USING_NAMESPACE_OVERBYTEICSTYPES)
using namespace Overbyteicstypes;
#endif
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// OverbyteIcsTypesHPP

unit FMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdIOHandler,
  IdIOHandlerStack, IdSSL, IdSSLOpenSSL, IdBaseComponent,

  IdUDPClient, IdSNTP, IPPeerClient,
  Data.Bind.Components, Data.Bind.ObjectScope, REST.Types;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    btnAzureSample: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnAzureSampleClick(Sender: TObject);
  private
    { Private declarations }
    function GetRfcDate: string;
    function GetAuthSignature(Key, Verb, ResourceType, ResourceLink, RfcDate: string): string;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  System.DateUtils,
  Soap.EncdDecd,
  IdCoderMIME,
  IdGlobal,
  IdHashSHA,
  IdHMACSHA1;

{$R *.dfm}

function RFC1123TimeFormat(utcDateTime: TDateTime): string;
const
  ShortDayNamesEnglish :array[1..7] of string =
    ('Sun', 'Mon','Tue', 'Wed', 'Thu', 'Fri', 'Sat');
  ShortMonthNamesEnglish :array[1..12] of string = ('Jan', 'Feb','Mar', 'Apr',
     'May','Jun','Jul','Aug', 'Sep','Oct','Nov','Dec');
var
  day, month: string;
begin
  day := ShortDayNamesEnglish[DayOfWeek(utcDateTime)];
  month := ShortMonthNamesEnglish[MonthOf(utcDateTime)];
  result := day + ', ' + FormatDateTime('dd', utcDateTime) + ' ' +
    month + ' ' + FormatDateTime('yyyy hh:nn:ss', utcDateTime) + ' GMT';
end;

function CalculateHMACSHA256(Key, Data: string): string;
var
  Cypher: TIdHMACSHA256;
  HashedResult: TIdBytes;
begin
  LoadOpenSSLLibrary;
  if not TIdHashSHA256.IsAvailable then
    raise Exception.Create('SHA256 hashing is not available!');

  Cypher := TIdHMACSHA256.Create;
  try
    Cypher.Key := TIdBytes(DecodeBase64(Key));
    HashedResult := Cypher.HashValue(IndyTextEncoding_UTF8.GetBytes(Data));
    Result := TIdEncoderMIME.EncodeBytes(HashedResult);
  finally
    Cypher.Free;
  end;
end;

procedure TForm1.btnAzureSampleClick(Sender: TObject);
const
  SAMPLE_KEY = 'dsZQi3KtZmCv1ljt3VNWNm7sQUF1y5rJfC6kv5JiwvW0EndXdDku/dkKBp8/ufDToSxLzR4y+O/0H/t4bQtVNw==';
  EXPECTED_OUTCOME = 'c09PEVJrgp2uQRkr934kFbTqhByc7TVr3OHyqlu+c+c=';
var
  LAuthorization, LRfcDate, LSignature: string;
begin
  LRfcDate := 'Thu, 27 Apr 2017 00:51:12 GMT'; // Noramlly you'll want to call GetRfcDate() for this, and use the same RfcDate in your x-ms-date header.
  LSignature := GetAuthSignature(
    SAMPLE_KEY,
    'GET',
    'dbs',
    'dbs/ToDoList',
    LRfcDate
  );

  Memo1.Lines.Clear;
  Memo1.Lines.Add('EXPECTED SIGNATURE:');
  Memo1.Lines.Add(EXPECTED_OUTCOME);

  Memo1.Lines.Add('');
  Memo1.Lines.Add('GENERATED SIGNATURE:');
  Memo1.Lines.Add(LSignature);


  LAuthorization := 'type=master&ver=1.0&sig=' + LSignature;
  Memo1.Lines.Add('');
  Memo1.Lines.Add('GENERATED AUTHORIZATION HEADER VALUE (Not URI Encoded):');
  Memo1.Lines.Add(LAuthorization);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Memo1.Lines.Clear;
end;

function TForm1.GetAuthSignature(Key, Verb, ResourceType, ResourceLink, RfcDate: string): string;
var
  LPayload: string;
begin
  LPayload :=
    LowerCase(Verb, TLocaleOptions.loInvariantLocale) + Chr(10) +
    LowerCase(ResourceType, TLocaleOptions.loInvariantLocale) + Chr(10) +
    ResourceLink + Chr(10) +
    LowerCase(RfcDate, TLocaleOptions.loInvariantLocale) + Chr(10) +
    '' + Chr(10);

  Result := CalculateHMACSHA256(Key, LPayload);
end;

function TForm1.GetRfcDate: string;
var
  Utc: TDateTime;
  NTP: TIdSNTP;
begin
  NTP := TIdSNTP.Create(nil);
  try
    NTP.Host := 'time.windows.com';
    NTP.Port := 123;
    NTP.Connect;
    Utc := TTimeZone.Local.ToUniversalTime(NTP.DateTime);
    NTP.Disconnect;

    Result := RFC1123TimeFormat(Utc);
  finally
    NTP.Free;
  end;
end;

end.

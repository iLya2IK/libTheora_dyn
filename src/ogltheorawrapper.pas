{
 OGLTheoraWrapper:
   Wrapper for Theora library

   Copyright (c) 2022 by Ilya Medvedkov

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}

unit OGLTheoraWrapper;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, libTheora_dyn, OGLOGGWrapper, Graphics;

type

  TTheoraColorspace = (tcsUnspec, tcsITURec470M, tcsITURec470BG, tcsNSpaces);
  TTheoraPixelFormat = (tpf420, tpfRSVD, tpf422, tpf444);
  TTheoraColorFormat = (tcfRGB, tcfBGR, tcfRGBA, tcfBGRA);

  { ITheoraYUVbuffer }

  ITheoraYUVbuffer = interface(IUnknown)
  ['{2D43D7DB-F54D-4463-9B78-22BDC42A830D}']
  function Ref : pyuv_buffer;

  procedure Done;

  function GetYWidth : Integer;
  procedure SetYWidth(value : Integer);
  function GetYHeight : Integer;
  procedure SetYHeight(value : Integer);
  function GetYStride : Integer;
  procedure SetYStride(value : Integer);

  function GetUVWidth : Integer;
  procedure SetUVWidth(value : Integer);
  function GetUVHeight : Integer;
  procedure SetUVHeight(value : Integer);
  function GetUVStride : Integer;
  procedure SetUVStride(value : Integer);

  function GetYData : pointer;
  procedure SetYData(value : pointer);
  function GetUData : pointer;
  procedure SetUData(value : pointer);
  function GetVData : pointer;
  procedure SetVData(value : pointer);

  function GetOwnData: Boolean;
  procedure SetOwnData(value : Boolean);

  function ConvertFromRasterImage(chroma_format : TTheoraPixelFormat; w,
    h : integer; aData : TRasterImage) : Boolean;

  property OwnData : Boolean read GetOwnData write SetOwnData;

  property YWidth  : Integer read GetYWidth write SetYWidth;
  property YHeight : Integer read GetYHeight write SetYHeight;
  property YStride : Integer read GetYStride write SetYStride;
  property YData   : Pointer read GetYData write SetYData;

  property UVWidth  : Integer read GetUVWidth write SetUVWidth;
  property UVHeight : Integer read GetUVHeight write SetUVHeight;
  property UVStride : Integer read GetUVStride write SetUVStride;
  property UData   : Pointer read GetUData write SetUData;
  property VData   : Pointer read GetVData write SetVData;
  end;

  { ITheoraInfo }

  ITheoraInfo = interface(IUnknown)
  ['{9C865272-09FB-4D82-A13A-8D7B1F3C0D07}']
  function Ref : ptheora_info;

  procedure Init;
  procedure Done;

  function GetAspectDenominator : Cardinal;
  function GetAspectNumerator : Cardinal;
  function GetCodecSetup : pointer;
  function GetColorspace : TTheoraColorspace;
  function GetDropFrames : Boolean;
  function GetFPSDenominator : Cardinal;
  function GetFPSNumerator : Cardinal;
  function GetFrameHeight : Cardinal;
  function GetFrameWidth : Cardinal;
  function GetHeight : Cardinal;
  function GetKeyframeAuto : Boolean;
  function GetKeyframeAutoThreshold : Cardinal;
  function GetKeyframeDataTargetBitrate : Cardinal;
  function GetKeyframeFrequency : Cardinal;
  function GetKeyframeFrequencyForce : Cardinal;
  function GetKeyframeMindistance : Cardinal;
  function GetNoiseSensitivity : Integer;
  function GetOffsetX : Cardinal;
  function GetOffsetY : Cardinal;
  function GetPixelFormat : TTheoraPixelFormat;
  function GetQuality : Integer;
  function GetQuick : Boolean;
  function GetSharpness : Integer;
  function GetTargetBitrate : Integer;
  function GetWidth : Cardinal;

  function GetVersionMajor : byte;
  function GetVersionMinor : byte;
  function GetVersionSubminor : byte;
  procedure SetAspectDenominator(AValue : Cardinal);
  procedure SetAspectNumerator(AValue : Cardinal);
  procedure SetCodecSetup(AValue : pointer);
  procedure SetColorspace(AValue : TTheoraColorspace);
  procedure SetDropFrames(AValue : Boolean);
  procedure SetFPSDenominator(AValue : Cardinal);
  procedure SetFPSNumerator(AValue : Cardinal);
  procedure SetFrameHeight(AValue : Cardinal);
  procedure SetFrameWidth(AValue : Cardinal);
  procedure SetHeight(AValue : Cardinal);
  procedure SetKeyframeAuto(AValue : Boolean);
  procedure SetKeyframeAutoThreshold(AValue : Cardinal);
  procedure SetKeyframeDataTargetBitrate(AValue : Cardinal);
  procedure SetKeyframeFrequency(AValue : Cardinal);
  procedure SetKeyframeFrequencyForce(AValue : Cardinal);
  procedure SetKeyframeMindistance(AValue : Cardinal);
  procedure SetNoiseSensitivity(AValue : Integer);
  procedure SetOffsetX(AValue : Cardinal);
  procedure SetOffsetY(AValue : Cardinal);
  procedure SetPixelFormat(AValue : TTheoraPixelFormat);
  procedure SetQuality(AValue : Integer);
  procedure SetQuick(AValue : Boolean);
  procedure SetSharpness(AValue : Integer);
  procedure SetTargetBitrate(AValue : Integer);
  procedure SetWidth(AValue : Cardinal);

  property Width : Cardinal read GetWidth write SetWidth;
  property Height : Cardinal read GetHeight write SetHeight;
  property FrameWidth : Cardinal read GetFrameWidth write SetFrameWidth;
  property FrameHeight : Cardinal read GetFrameHeight write SetFrameHeight;
  property OffsetX : Cardinal read GetOffsetX write SetOffsetX;
  property OffsetY : Cardinal read GetOffsetY write SetOffsetY;
  property FPSNumerator : Cardinal read GetFPSNumerator write SetFPSNumerator;
  property FPSDenominator : Cardinal read GetFPSDenominator write SetFPSDenominator;
  property AspectNumerator : Cardinal read GetAspectNumerator write SetAspectNumerator;
  property AspectDenominator : Cardinal read GetAspectDenominator write SetAspectDenominator;
  property Colorspace : TTheoraColorspace read GetColorspace write SetColorspace;
  property TargetBitrate : Integer read GetTargetBitrate write SetTargetBitrate;
  property Quality : Integer read GetQuality write SetQuality;
  property Quick : Boolean read GetQuick write SetQuick;

  property DropFrames : Boolean read GetDropFrames write SetDropFrames;
  property KeyframeAuto : Boolean read GetKeyframeAuto write SetKeyframeAuto;
  property KeyframeFrequency : Cardinal read GetKeyframeFrequency write SetKeyframeFrequency;
  property KeyframeFrequencyForce : Cardinal read GetKeyframeFrequencyForce write SetKeyframeFrequencyForce;

  property KeyframeDataTargetBitrate : Cardinal read GetKeyframeDataTargetBitrate write SetKeyframeDataTargetBitrate;
  property KeyframeAutoThreshold : Cardinal read GetKeyframeAutoThreshold write SetKeyframeAutoThreshold;
  property KeyframeMindistance : Cardinal read GetKeyframeMindistance write SetKeyframeMindistance;
  property NoiseSensitivity : Integer read GetNoiseSensitivity write SetNoiseSensitivity;
  property Sharpness : Integer read GetSharpness write SetSharpness;

  property CodecSetup : pointer read GetCodecSetup write SetCodecSetup;

  property PixelFormat : TTheoraPixelFormat read GetPixelFormat write SetPixelFormat;

  function GranuleShift: integer;
  end;

  ITheoraState = interface(IUnknown)
  ['{A05124E4-F474-45DE-AAC9-8E3F300CE4B7}']
  function Ref : ptheora_state;

  procedure Init(inf : ITheoraInfo);
  procedure Done;

  function Info : ITheoraInfo;
  function GetGranulePos : Int64;
  procedure SetGranulePos(value : Int64);

  function GranuleFrame(granulepos: Int64): Int64;
  function GranuleTime(granulepos: Int64): double;

  property GranulePos : Int64 read GetGranulePos write SetGranulePos;
  end;    

  ITheoraEncoder = interface(ITheoraState)
  ['{01584DE9-B550-4B82-BBC8-505011AECD33}']
  procedure Header(op: IOGGPacket);
  procedure PacketOut(last_p: boolean; op: IOGGPacket);
  function  PacketOut(last_p: boolean): IOGGPacket;
  procedure YUVin(yuv: ITheoraYUVbuffer);
  procedure Comment(tc: IOGGComment; op: IOGGPacket);
  procedure Tables(op: IOGGPacket);

  function Control(req: integer; buf: pointer; buf_sz: qword): integer;

  procedure SaveDefHeadersToStream(oggs : IOGGStreamState; str : TStream);
  procedure SaveCustomHeadersToStream(oggs : IOGGStreamState; str : TStream;
    tc : IOGGComment);
  procedure SaveYUVBufferToStream(oggs : IOGGStreamState; str : TStream;
    buf : ITheoraYUVbuffer; is_last : Boolean);
  end;


  ITheoraDecoder = interface(ITheoraState)
  ['{EDCD1C8E-19F9-456F-ACB0-41CABFACD5AB}']
  procedure Header(cc: IOGGComment; op: IOGGPacket);
  procedure PacketIn(op: IOGGPacket);
  procedure YUVout(yuv: ITheoraYUVbuffer);
  end;

  { TTheoraYUVbuffer }

  TTheoraYUVbuffer = class(TInterfacedObject, ITheoraYUVbuffer)
  private
    FRef : yuv_buffer;
    FOwnData : Boolean;

    procedure Done;

    function GetYWidth : Integer;
    procedure SetYWidth(value : Integer);
    function GetYHeight : Integer;
    procedure SetYHeight(value : Integer);
    function GetYStride : Integer;
    procedure SetYStride(value : Integer);

    function GetUVWidth : Integer;
    procedure SetUVWidth(value : Integer);
    function GetUVHeight : Integer;
    procedure SetUVHeight(value : Integer);
    function GetUVStride : Integer;
    procedure SetUVStride(value : Integer);

    function GetYData : pointer;
    procedure SetYData(value : pointer);
    function GetUData : pointer;
    procedure SetUData(value : pointer);
    function GetVData : pointer;
    procedure SetVData(value : pointer);

    function GetOwnData: Boolean;
    procedure SetOwnData(value : Boolean);
  public
    function Ref : pyuv_buffer; inline;

    constructor Create(aOwnData : Boolean);
    destructor Destroy; override;

    function ConvertFromRasterImage(chroma_format : TTheoraPixelFormat; w,
      h : integer; aData : TRasterImage) : Boolean;
  end;

  { TTheoraComment }

  TTheoraComment = class(TInterfacedObject, IOGGComment)
  private
    FRef : theora_comment;
    procedure Init;
    procedure Done;
  public
    function Ref : Pointer; inline;

    constructor Create;
    destructor Destroy; override;

    procedure Add(const comment: String);
    procedure AddTag(const tag, value: String);
    function Query(const tag: String; index: integer): String;
    function QueryCount(const tag: String): integer;
  end;

  { TTheoraInfo }

  TTheoraInfo = class(TInterfacedObject, ITheoraInfo)
  private
    FRef : theora_info;
    procedure Init;
    procedure Done;

    function GetAspectDenominator : Cardinal;
    function GetAspectNumerator : Cardinal;
    function GetCodecSetup : pointer;
    function GetColorspace : TTheoraColorspace;
    function GetDropFrames : Boolean;
    function GetFPSDenominator : Cardinal;
    function GetFPSNumerator : Cardinal;
    function GetFrameHeight : Cardinal;
    function GetFrameWidth : Cardinal;
    function GetHeight : Cardinal;
    function GetKeyframeAuto : Boolean;
    function GetKeyframeAutoThreshold : Cardinal;
    function GetKeyframeDataTargetBitrate : Cardinal;
    function GetKeyframeFrequency : Cardinal;
    function GetKeyframeFrequencyForce : Cardinal;
    function GetKeyframeMindistance : Cardinal;
    function GetNoiseSensitivity : Integer;
    function GetOffsetX : Cardinal;
    function GetOffsetY : Cardinal;
    function GetPixelFormat : TTheoraPixelFormat;
    function GetQuality : Integer;
    function GetQuick : Boolean;
    function GetSharpness : Integer;
    function GetTargetBitrate : Integer;
    function GetWidth : Cardinal;

    procedure SetAspectDenominator(AValue : Cardinal);
    procedure SetAspectNumerator(AValue : Cardinal);
    procedure SetCodecSetup(AValue : pointer);
    procedure SetColorspace(AValue : TTheoraColorspace);
    procedure SetDropFrames(AValue : Boolean);
    procedure SetFPSDenominator(AValue : Cardinal);
    procedure SetFPSNumerator(AValue : Cardinal);
    procedure SetFrameHeight(AValue : Cardinal);
    procedure SetFrameWidth(AValue : Cardinal);
    procedure SetHeight(AValue : Cardinal);
    procedure SetKeyframeAuto(AValue : Boolean);
    procedure SetKeyframeAutoThreshold(AValue : Cardinal);
    procedure SetKeyframeDataTargetBitrate(AValue : Cardinal);
    procedure SetKeyframeFrequency(AValue : Cardinal);
    procedure SetKeyframeFrequencyForce(AValue : Cardinal);
    procedure SetKeyframeMindistance(AValue : Cardinal);
    procedure SetNoiseSensitivity(AValue : Integer);
    procedure SetOffsetX(AValue : Cardinal);
    procedure SetOffsetY(AValue : Cardinal);
    procedure SetPixelFormat(AValue : TTheoraPixelFormat);
    procedure SetQuality(AValue : Integer);
    procedure SetQuick(AValue : Boolean);
    procedure SetSharpness(AValue : Integer);
    procedure SetTargetBitrate(AValue : Integer);
    procedure SetWidth(AValue : Cardinal);
  public
    function Ref : ptheora_info; inline;

    constructor Create;
    destructor Destroy; override;

    function GetVersionMajor : byte;
    function GetVersionMinor : byte;
    function GetVersionSubminor : byte;

    function GranuleShift: integer;
  end;

  { TTheoraState }

  TTheoraState = class(TInterfacedObject, ITheoraState)
  private
    FRef  : theora_state;
    FInfo : ITheoraInfo;

    procedure Init(inf : ITheoraInfo); virtual;
    procedure Done;
    function GetGranulePos : Int64;
    procedure SetGranulePos(value : Int64);
  public
    function Ref : ptheora_state; inline;

    constructor Create(inf : ITheoraInfo);
    destructor Destroy; override;

    function Info : ITheoraInfo;

    function GranuleFrame(granulepos: Int64): Int64;
    function GranuleTime(granulepos: Int64): double;
  end;

  { TTheoraEncoder }

  TTheoraEncoder = class(TTheoraState, ITheoraEncoder)
  private
    procedure Init(inf : ITheoraInfo); override;
  public
    procedure Header(op: IOGGPacket);
    procedure PacketOut(last_p: boolean; op: IOGGPacket);
    function PacketOut(last_p: boolean): IOGGPacket;
    procedure YUVin(yuv: ITheoraYUVbuffer);
    procedure Comment(tc: IOGGComment; op: IOGGPacket);
    procedure Tables(op: IOGGPacket);

    function Control(req: integer; buf: pointer; buf_sz: qword): integer;

    procedure SaveDefHeadersToStream(oggs : IOGGStreamState; str : TStream);
    procedure SaveCustomHeadersToStream(oggs : IOGGStreamState; str : TStream;
      tc : IOGGComment);
    procedure SaveYUVBufferToStream(oggs : IOGGStreamState; str : TStream;
      buf : ITheoraYUVbuffer; is_last : Boolean);
  end;

  { TTheoraDecoder }

  TTheoraDecoder = class(TTheoraState, ITheoraDecoder)
  private
    procedure Init(inf : ITheoraInfo); override;
  public
    procedure Header(cc: IOGGComment; op: IOGGPacket);
    procedure PacketIn(op: IOGGPacket);
    procedure YUVout(yuv: ITheoraYUVbuffer);
  end;

  { TTheora }

  TTheora = class
  public
    class function NewComment : IOGGComment;
    class function NewEncoder(inf : ITheoraInfo) : ITheoraEncoder;
    class function NewDecoder(inf : ITheoraInfo) : ITheoraDecoder;
    class function NewInfo : ITheoraInfo;
    class function NewYUVBuffer(aOwnData : Boolean) : ITheoraYUVbuffer;

    class function IsHeader(op: IOGGPacket): Boolean;
    class function IsKeyframe(op: IOGGPacket): Boolean;

    class function TheoraLibsLoad(const aTheoraLibs : Array of String) : Boolean;
    class function TheoraLibsLoadDefault : Boolean;
    class function IsTheoraLibsLoaded : Boolean;
    class function TheoraLibsUnLoad : Boolean;

    class function Version : String;
    class function VersionNumber : Cardinal;
  end;

  { ETheoraException }

  ETheoraException = class(Exception)
  public
    constructor Create(R : Integer); overload;
    class function DefaultError : String; virtual;
  end;

  { ETheoraEncException }

  ETheoraEncException = class(ETheoraException)
  public
    class function DefaultError : String; override;
  end;

  { ETheoraDecException }

  ETheoraDecException = class(ETheoraException)
  public
    class function DefaultError : String; override;
  end;

implementation

const
  ERR_UNSPECIFIED     = 'Unspecified error';
  ERR_FAULT           = 'General failure';
  ERR_EINVAL          = 'Library encountered invalid internal data';
  ERR_DISABLED        = 'Requested action is disabled';
  ERR_BADHEADER       = 'Header packet was corrupt/invalid';
  ERR_NOTFORMAT       = 'Packet is not a theora packet';
  ERR_VERSION         = 'Bitstream version is not handled';
  ERR_IMPL            = 'Feature or action not implemented';
  ERR_BADPACKET       = 'Packet is corrupt';
  ERR_NEWPACKET       = 'Packet is an (ignorable) unhandled extension';
  ERR_DUPFRAME        = 'Packet is a dropped frame';

  ERR_ENC_UNSPECIFIED = 'Unspecified encoder error';
  ERR_ENC_COMPLETED = 'The encoding process has completed';
  ERR_ENC_NOT_READY = 'Encoder is not ready';
  ERR_ENC_PACK_NOT_READY = 'No internal storage exists OR no packet is ready';
  ERR_ENC_DIFFER    = 'The size of the given frame differs from those previously input';

  ERR_DEC_UNSPECIFIED = 'Unspecified decoder error';
  ERR_DEC_BADPACKET = 'Packet is corrupt. Packet does not contain encoded video data';

{ ETheoraDecException }

class function ETheoraDecException.DefaultError : String;
begin
  Result := ERR_DEC_UNSPECIFIED;
end;

{ ETheoraEncException }

class function ETheoraEncException.DefaultError : String;
begin
  Result := ERR_ENC_UNSPECIFIED;
end;

{ ETheoraException }

constructor ETheoraException.Create(R : Integer);
var S : String;
begin
  case R of
    OC_FAULT     : S := ERR_FAULT;
    OC_EINVAL    : S := ERR_EINVAL;
    OC_DISABLED  : S := ERR_DISABLED;
    OC_BADHEADER : S := ERR_BADHEADER;
    OC_NOTFORMAT : S := ERR_NOTFORMAT;
    OC_VERSION   : S := ERR_VERSION;
    OC_IMPL      : S := ERR_IMPL;
    OC_BADPACKET : S := ERR_BADPACKET;
    OC_NEWPACKET : S := ERR_NEWPACKET;
    OC_DUPFRAME  : S := ERR_DUPFRAME;
  else
    S := DefaultError;
  end;
  inherited Create(S);
end;

class function ETheoraException.DefaultError : String;
begin
  Result := ERR_UNSPECIFIED;
end;

{ TTheoraDecoder }

procedure TTheoraDecoder.Init(inf : ITheoraInfo);
var R : integer;
begin
  inherited Init(inf);
  R := theora_decode_init(@FRef, inf.Ref);
  if R = 0 then Exit else
     raise ETheoraDecException.Create(R);
end;

procedure TTheoraDecoder.Header(cc : IOGGComment; op : IOGGPacket);
var R : integer;
begin
  R := theora_decode_header(FInfo.Ref, cc.Ref, op.Ref);
  if R = 0 then Exit else
     raise ETheoraDecException.Create(R);
end;

procedure TTheoraDecoder.PacketIn(op : IOGGPacket);
var R : integer;
begin
  R := theora_decode_packetin(@FRef, op.Ref);
  if R = 0 then Exit else
  if R = OC_BADPACKET then raise ETheoraDecException.Create(ERR_DEC_BADPACKET) else
     raise ETheoraDecException.Create(R);
end;

procedure TTheoraDecoder.YUVout(yuv : ITheoraYUVbuffer);
var R : integer;
begin
  R := theora_decode_YUVout(@FRef, yuv.Ref);
  if R = 0 then Exit else
     raise ETheoraDecException.Create(R);
end;

{ TTheoraEncoder }

procedure TTheoraEncoder.Init(inf : ITheoraInfo);
var R : integer;
begin
  inherited Init(inf);
  R := theora_encode_init(@FRef, inf.Ref);
  if R = 0 then Exit else
     raise ETheoraEncException.Create(R);
end;

procedure TTheoraEncoder.Header(op : IOGGPacket);
var R : integer;
begin
  R := theora_encode_header(@FRef, op.Ref);
  if R = 0 then Exit else
     raise ETheoraEncException.Create(R);
end;

procedure TTheoraEncoder.PacketOut(last_p : boolean; op : IOGGPacket);
var R : integer;
begin
  R := theora_encode_packetout(@FRef, integer(last_p), op.Ref);
  if R = 1 then Exit else
  if R = -1 then raise ETheoraEncException.Create(ERR_ENC_COMPLETED) else
  if R = 0 then raise ETheoraEncException.Create(ERR_ENC_PACK_NOT_READY) else
     raise ETheoraEncException.Create(R);
end;

function TTheoraEncoder.PacketOut(last_p : boolean) : IOGGPacket;
begin
  Result := TOGG.NewPacket;
  PacketOut(last_p, Result);
end;

procedure TTheoraEncoder.YUVin(yuv : ITheoraYUVbuffer);
var R : integer;
begin
  R := theora_encode_YUVin(@FRef, yuv.Ref);
  if R = 0 then Exit else
  if R = -1 then raise ETheoraEncException.Create(ERR_ENC_DIFFER) else
  if R = OC_EINVAL then raise ETheoraEncException.Create(ERR_ENC_NOT_READY) else
     raise ETheoraEncException.Create(R);
end;

procedure TTheoraEncoder.Comment(tc : IOGGComment; op : IOGGPacket);
var R : integer;
begin
  R := theora_encode_comment(tc.Ref, op.Ref);
  if R = 0 then Exit else
     raise ETheoraEncException.Create(R);
end;

procedure TTheoraEncoder.Tables(op : IOGGPacket);
var R : integer;
begin
  R := theora_encode_tables(@FRef, op.Ref);
  if R = 0 then Exit else
     raise ETheoraEncException.Create(R);
end;

function TTheoraEncoder.Control(req : integer; buf : pointer; buf_sz : qword
  ) : integer;
begin
  Result := theora_control(@FRef, req, buf, buf_sz);
end;

procedure TTheoraEncoder.SaveDefHeadersToStream(oggs : IOGGStreamState;
  str : TStream);
var tc : IOGGComment;
begin
  tc := TTheora.NewComment;
  SaveCustomHeadersToStream(oggs, str, tc);
end;

procedure TTheoraEncoder.SaveCustomHeadersToStream(oggs : IOGGStreamState;
  str : TStream; tc : IOGGComment);
var op : IOGGPacket;
begin
  op := TOgg.NewPacket;
  Header(op);
  oggs.SavePacketToStream(str, op);
  Comment(tc, op);
  oggs.PacketIn(op);
  Tables(op);
  oggs.PacketIn(op);
  oggs.SavePacketToStream(str, op);
end;

procedure TTheoraEncoder.SaveYUVBufferToStream(oggs : IOGGStreamState;
  str : TStream; buf : ITheoraYUVbuffer; is_last : Boolean);
var op : IOGGPacket;
begin
  YUVin(buf);
  op := PacketOut(is_last);
  oggs.SavePacketToStream(str, op);
end;

{ TTheoraState }

procedure TTheoraState.Init(inf : ITheoraInfo);
begin
  FInfo := inf;
end;

procedure TTheoraState.Done;
begin
  FRef.i := nil; //to prevent call theora_info_clear by theora lib
  theora_clear(@FRef);
end;

function TTheoraState.GetGranulePos : Int64;
begin
  Result := FRef.granulepos;
end;

procedure TTheoraState.SetGranulePos(value : Int64);
begin
  FRef.granulepos := value;
end;

function TTheoraState.Ref : ptheora_state;
begin
  Result := @FRef;
end;

constructor TTheoraState.Create(inf : ITheoraInfo);
begin
  FillByte(FRef, Sizeof(FRef), 0);
  Init(inf);
end;

destructor TTheoraState.Destroy;
begin
  Done;
  inherited Destroy;
end;

function TTheoraState.Info : ITheoraInfo;
begin
  Result := FInfo;
end;

function TTheoraState.GranuleFrame(granulepos : Int64) : Int64;
begin
  Result := theora_granule_frame(@FRef, granulepos);
end;

function TTheoraState.GranuleTime(granulepos : Int64) : double;
begin
  Result := theora_granule_time(@FRef, granulepos);
end;

{ TTheoraComment }

procedure TTheoraComment.Init;
begin
  theora_comment_init(@FRef);
end;

procedure TTheoraComment.Done;
begin
  theora_comment_clear(@FRef);
end;

function TTheoraComment.Ref : Pointer;
begin
  Result := @FRef;
end;

constructor TTheoraComment.Create;
begin
  FillByte(FRef, Sizeof(FRef), 0);
  Init;
end;

destructor TTheoraComment.Destroy;
begin
  Done;
  inherited Destroy;
end;

procedure TTheoraComment.Add(const comment : String);
begin
  theora_comment_add(@FRef, pchar(comment));
end;

procedure TTheoraComment.AddTag(const tag, value : String);
begin
  theora_comment_add_tag(@FRef, pchar(tag), pchar(value));
end;

function TTheoraComment.Query(const tag : String; index : integer) : String;
begin
  Result := StrPas( theora_comment_query(@FRef, PChar(tag), index) );
end;

function TTheoraComment.QueryCount(const tag : String) : integer;
begin
  Result := theora_comment_query_count(@FRef, PChar(tag));
end;

{ TTheoraYUVbuffer }

procedure TTheoraYUVbuffer.Done;
begin
  if ITheoraYUVbuffer(Self).OwnData then
  begin
    if Assigned(FRef.y) then FreeMemAndNil(FRef.y);
    if Assigned(FRef.u) then FreeMemAndNil(FRef.u);
    if Assigned(FRef.v) then FreeMemAndNil(FRef.v);
  end;
end;

function TTheoraYUVbuffer.GetYWidth : Integer;
begin
  Result := FRef.y_width;
end;

procedure TTheoraYUVbuffer.SetYWidth(value : Integer);
begin
  FRef.y_width := value;
end;

function TTheoraYUVbuffer.GetYHeight : Integer;
begin
  Result := FRef.y_height;
end;

procedure TTheoraYUVbuffer.SetYHeight(value : Integer);
begin
  FRef.y_height := value;
end;

function TTheoraYUVbuffer.GetYStride : Integer;
begin
  Result := FRef.y_stride;
end;

procedure TTheoraYUVbuffer.SetYStride(value : Integer);
begin
  FRef.y_stride := value;
end;

function TTheoraYUVbuffer.GetUVWidth : Integer;
begin
  Result := FRef.uv_width;
end;

procedure TTheoraYUVbuffer.SetUVWidth(value : Integer);
begin
  FRef.uv_width := value;
end;

function TTheoraYUVbuffer.GetUVHeight : Integer;
begin
  Result := FRef.uv_height;
end;

procedure TTheoraYUVbuffer.SetUVHeight(value : Integer);
begin
  FRef.uv_height := value;
end;

function TTheoraYUVbuffer.GetUVStride : Integer;
begin
  Result := FRef.uv_stride;
end;

procedure TTheoraYUVbuffer.SetUVStride(value : Integer);
begin
  FRef.uv_stride := value;
end;

function TTheoraYUVbuffer.GetYData : pointer;
begin
  Result := FRef.y;
end;

procedure TTheoraYUVbuffer.SetYData(value : pointer);
begin
  FRef.y := value;
end;

function TTheoraYUVbuffer.GetUData : pointer;
begin
  Result := FRef.u;
end;

procedure TTheoraYUVbuffer.SetUData(value : pointer);
begin
  FRef.u := value;
end;

function TTheoraYUVbuffer.GetVData : pointer;
begin
  Result := FRef.v;
end;

procedure TTheoraYUVbuffer.SetVData(value : pointer);
begin
  FRef.v := value;
end;

function TTheoraYUVbuffer.GetOwnData : Boolean;
begin
  Result := FOwnData;
end;

procedure TTheoraYUVbuffer.SetOwnData(value : Boolean);
begin
  FOwnData := value;
end;

constructor TTheoraYUVbuffer.Create(aOwnData : Boolean);
begin
  FillByte(FRef, Sizeof(FRef), 0);
  FOwnData := aOwnData;
end;

destructor TTheoraYUVbuffer.Destroy;
begin
  Done;
  inherited Destroy;
end;

function TTheoraYUVbuffer.ConvertFromRasterImage(
  chroma_format : TTheoraPixelFormat; w, h : integer; aData : TRasterImage
  ) : Boolean;

function clamp(v : integer) : Byte;
begin
  if v < 0 then Exit(0);
  if v > 255 then Exit(255);
  Result := Byte(v);
end;

var
  x, y, x1, y1 : Cardinal;
  yuv_w, yuv_h : QWord;
  yuv_y, yuv_u, yuv_v : PByte;
  r0, b0, g0, r1, b1, g1, r2, g2, b2, r3, g3, b3 : Byte;
  rl, bl, sz : Byte;
  aBytes : PByte;
  input_format : TTheoraColorFormat;
begin
  if not (chroma_format in [tpf444, tpf422, tpf420]) then Exit(false);

  if aData.PixelFormat = pf24bit then input_format := tcfBGR else
  if aData.PixelFormat = pf32bit then input_format := tcfBGRA else
     Exit(false);

  { Must hold: yuv_w >= w }
  yuv_w := (w + 15) and not Cardinal(15);
  { Must hold: yuv_h >= h }
  yuv_h := (h + 15) and not Cardinal(15);

  case input_format of
    tcfBGR : begin
        bl := 0; rl := 2; sz := 3;
    end;
    tcfRGB : begin
        bl := 2; rl := 0; sz := 3;
    end;
    tcfBGRA : begin
        bl := 0; rl := 2; sz := 4;
    end;
    tcfRGBA : begin
        bl := 2; rl := 0; sz := 4;
    end;
  end;

  with ITheoraYUVbuffer(Self) do
  begin
    YWidth  := yuv_w;
    YHeight := yuv_h;
    YStride := yuv_w;

    if chroma_format = tpf444 then
      UVWidth := yuv_w else
      UVWidth := yuv_w shr 1;
    UVStride := UVWidth;
    if chroma_format = tpf420 then
      UVHeight := yuv_h shr 1 else
      UVHeight := yuv_h;

    yuv_y := AllocMem(YStride * YHeight);
    yuv_u := AllocMem(UVStride * UVHeight);
    yuv_v := AllocMem(UVStride * UVHeight);

    YData := yuv_y;
    UData := yuv_u;
    VData := yuv_v;

    {This ignores gamma and RGB primary/whitepoint differences.
      It also isn't terribly fast (though a decent compiler will
      strength-reduce the division to a multiplication).}

    if (chroma_format = tpf420) then
    begin
        y := 0;
        while y < h do
        begin
            y1 := y + Integer( (y + 1) < h );
            x := 0;
            while x < w do
            begin
                x1 := x + Integer((x + 1) < w);
                aBytes := aData.ScanLine[y];
                r0 := aBytes[sz * x + rl];
                g0 := aBytes[sz * x + 1];
                b0 := aBytes[sz * x + bl];
                r1 := aBytes[sz * x1 + rl];
                g1 := aBytes[sz * x1 + 1];
                b1 := aBytes[sz * x1 + bl];
                aBytes := aData.ScanLine[y1];
                r2 := aBytes[sz * x + rl];
                g2 := aBytes[sz * x + 1];
                b2 := aBytes[sz * x + bl];
                r3 := aBytes[sz * x1 + rl];
                g3 := aBytes[sz * x1 + 1];
                b3 := aBytes[sz * x1 + bl];

                yuv_y[x  + y * yuv_w]  := clamp((65481*r0+128553*g0+24966*b0+4207500) div 255000);
                yuv_y[x1 + y * yuv_w]  := clamp((65481*r1+128553*g1+24966*b1+4207500) div 255000);
                yuv_y[x  + y1 * yuv_w] := clamp((65481*r2+128553*g2+24966*b2+4207500) div 255000);
                yuv_y[x1 + y1 * yuv_w] := clamp((65481*r3+128553*g3+24966*b3+4207500) div 255000);

                yuv_u[(x shr 1) + (y shr 1) * UVStride] :=
                    clamp( ((-33488*r0-65744*g0+99232*b0+29032005) div 4 +
                            (-33488*r1-65744*g1+99232*b1+29032005) div 4 +
                            (-33488*r2-65744*g2+99232*b2+29032005) div 4 +
                            (-33488*r3-65744*g3+99232*b3+29032005) div 4) div 225930);
                yuv_v[(x shr 1) + (y shr 1) * UVStride] :=
                    clamp( ((157024*r0-131488*g0-25536*b0+45940035) div 4 +
                            (157024*r1-131488*g1-25536*b1+45940035) div 4 +
                            (157024*r2-131488*g2-25536*b2+45940035) div 4 +
                            (157024*r3-131488*g3-25536*b3+45940035) div 4) div 357510);
                inc(x, 2);
            end;
            Inc(y, 2);
        end;
    end
    else
    if (chroma_format = tpf444) then
    begin
        for y := 0 to (h-1) do
        begin
            for x := 0 to (w-1) do
            begin
                aBytes := aData.ScanLine[y];
                r0 := aBytes[sz * x + rl];
                g0 := aBytes[sz * x + 1];
                b0 := aBytes[sz * x + bl];

                yuv_y[x + y * yuv_w] := clamp((65481*r0+128553*g0+24966*b0+4207500)   div 255000);
                yuv_u[x + y * yuv_w] := clamp((-33488*r0-65744*g0+99232*b0+29032005)  div 225930);
                yuv_v[x + y * yuv_w] := clamp((157024*r0-131488*g0-25536*b0+45940035) div 357510);
            end;
        end;
    end
    else      { TH_PF_422 }
    begin
        y := 0;
        while y < h do
        begin
            for x := 0 to (w-1) do
            begin
                x1 := x + integer((x+1)<w);
                aBytes := aData.ScanLine[y];
                r0 := aBytes[sz * x + rl];
                g0 := aBytes[sz * x + 1];
                b0 := aBytes[sz * x + bl];
                r1 := aBytes[sz * x1 + rl];
                g1 := aBytes[sz * x1 + 1];
                b1 := aBytes[sz * x1 + bl];

                yuv_y[x  + y * yuv_w] := clamp((65481*r0+128553*g0+24966*b0+4207500) div 255000);
                yuv_y[x1 + y * yuv_w] := clamp((65481*r1+128553*g1+24966*b1+4207500) div 255000);

                yuv_u[(x shr 1) + y * UVStride] :=
                    clamp( ((-33488*r0-65744*g0+99232*b0+29032005) div 2 +
                            (-33488*r1-65744*g1+99232*b1+29032005) div 2) div 225930);
                yuv_v[(x shr 1) + y * UVStride] :=
                    clamp( ((157024*r0-131488*g0-25536*b0+45940035) div 2 +
                            (157024*r1-131488*g1-25536*b1+45940035) div 2) div 357510);
            end;
            Inc(y);
        end;
    end;
  end;
  Result := True;
end;

function TTheoraYUVbuffer.Ref : pyuv_buffer;
begin
  Result := @FRef;
end;

{ TTheoraInfo }

procedure TTheoraInfo.Init;
begin
  theora_info_init(@FRef);
end;

procedure TTheoraInfo.Done;
begin
  theora_info_clear(@FRef);
end;

function TTheoraInfo.GetAspectDenominator : Cardinal;
begin
  Result := FRef.aspect_denominator;
end;

function TTheoraInfo.GetAspectNumerator : Cardinal;
begin
  Result := FRef.aspect_numerator;
end;

function TTheoraInfo.GetCodecSetup : pointer;
begin
  Result := FRef.codec_setup;
end;

function TTheoraInfo.GetColorspace : TTheoraColorspace;
begin
  Result := TTheoraColorspace(FRef.colorspace);
end;

function TTheoraInfo.GetDropFrames : Boolean;
begin
  Result := FRef.dropframes_p > 0;
end;

function TTheoraInfo.GetFPSDenominator : Cardinal;
begin
  Result := FRef.fps_denominator;
end;

function TTheoraInfo.GetFPSNumerator : Cardinal;
begin
  Result := FRef.fps_numerator;
end;

function TTheoraInfo.GetFrameHeight : Cardinal;
begin
  Result := FRef.frame_height;
end;

function TTheoraInfo.GetFrameWidth : Cardinal;
begin
  Result := FRef.frame_width;
end;

function TTheoraInfo.GetHeight : Cardinal;
begin
  Result := FRef.height;
end;

function TTheoraInfo.GetKeyframeAuto : Boolean;
begin
  Result := FRef.keyframe_auto_p > 0;
end;

function TTheoraInfo.GetKeyframeAutoThreshold : Cardinal;
begin
  Result := FRef.keyframe_auto_threshold;
end;

function TTheoraInfo.GetKeyframeDataTargetBitrate : Cardinal;
begin
  Result := FRef.keyframe_data_target_bitrate;
end;

function TTheoraInfo.GetKeyframeFrequency : Cardinal;
begin
  Result := FRef.keyframe_frequency;
end;

function TTheoraInfo.GetKeyframeFrequencyForce : Cardinal;
begin
  Result := FRef.keyframe_frequency_force;
end;

function TTheoraInfo.GetKeyframeMindistance : Cardinal;
begin
  Result := FRef.keyframe_mindistance;
end;

function TTheoraInfo.GetNoiseSensitivity : Integer;
begin
  Result := FRef.noise_sensitivity;
end;

function TTheoraInfo.GetOffsetX : Cardinal;
begin
  Result := FRef.offset_x;
end;

function TTheoraInfo.GetOffsetY : Cardinal;
begin
  Result := FRef.offset_y;
end;

function TTheoraInfo.GetPixelFormat : TTheoraPixelFormat;
begin
  Result := TTheoraPixelFormat(FRef.pixelformat);
end;

function TTheoraInfo.GetQuality : Integer;
begin
  Result := FRef.quality;
end;

function TTheoraInfo.GetQuick : Boolean;
begin
  Result := FRef.quick_p > 0;
end;

function TTheoraInfo.GetSharpness : Integer;
begin
  Result := FRef.sharpness;
end;

function TTheoraInfo.GetTargetBitrate : Integer;
begin
  Result := FRef.target_bitrate;
end;

function TTheoraInfo.GetWidth : Cardinal;
begin
  Result := FRef.width;
end;

procedure TTheoraInfo.SetAspectDenominator(AValue : Cardinal);
begin
  FRef.aspect_denominator := AValue;
end;

procedure TTheoraInfo.SetAspectNumerator(AValue : Cardinal);
begin
  FRef.aspect_numerator := AValue;
end;

procedure TTheoraInfo.SetCodecSetup(AValue : pointer);
begin
  FRef.codec_setup := AValue;
end;

procedure TTheoraInfo.SetColorspace(AValue : TTheoraColorspace);
begin
  FRef.colorspace := integer(AValue);
end;

procedure TTheoraInfo.SetDropFrames(AValue : Boolean);
begin
  FRef.dropframes_p := integer(AValue);
end;

procedure TTheoraInfo.SetFPSDenominator(AValue : Cardinal);
begin
  FRef.fps_denominator := AValue;
end;

procedure TTheoraInfo.SetFPSNumerator(AValue : Cardinal);
begin
  FRef.fps_numerator := AValue;
end;

procedure TTheoraInfo.SetFrameHeight(AValue : Cardinal);
begin
  FRef.frame_height := AValue;
end;

procedure TTheoraInfo.SetFrameWidth(AValue : Cardinal);
begin
  FRef.frame_width := AValue;
end;

procedure TTheoraInfo.SetHeight(AValue : Cardinal);
begin
  FRef.height := AValue;
end;

procedure TTheoraInfo.SetKeyframeAuto(AValue : Boolean);
begin
  FRef.keyframe_auto_p := integer(AValue);
end;

procedure TTheoraInfo.SetKeyframeAutoThreshold(AValue : Cardinal);
begin
  FRef.keyframe_auto_threshold := AValue;
end;

procedure TTheoraInfo.SetKeyframeDataTargetBitrate(AValue : Cardinal);
begin
  FRef.keyframe_data_target_bitrate := AValue;
end;

procedure TTheoraInfo.SetKeyframeFrequency(AValue : Cardinal);
begin
  FRef.keyframe_frequency := AValue;
end;

procedure TTheoraInfo.SetKeyframeFrequencyForce(AValue : Cardinal);
begin
  FRef.keyframe_frequency_force := AValue;
end;

procedure TTheoraInfo.SetKeyframeMindistance(AValue : Cardinal);
begin
  FRef.keyframe_mindistance := AValue;
end;

procedure TTheoraInfo.SetNoiseSensitivity(AValue : Integer);
begin
  FRef.noise_sensitivity := AValue;
end;

procedure TTheoraInfo.SetOffsetX(AValue : Cardinal);
begin
  FRef.offset_x := AValue;
end;

procedure TTheoraInfo.SetOffsetY(AValue : Cardinal);
begin
  FRef.offset_y := AValue;
end;

procedure TTheoraInfo.SetPixelFormat(AValue : TTheoraPixelFormat);
begin
  FRef.pixelformat := integer(AValue);
end;

procedure TTheoraInfo.SetQuality(AValue : Integer);
begin
  FRef.quality := AValue;
end;

procedure TTheoraInfo.SetQuick(AValue : Boolean);
begin
  FRef.quick_p := integer(AValue);
end;

procedure TTheoraInfo.SetSharpness(AValue : Integer);
begin
  FRef.sharpness := AValue;
end;

procedure TTheoraInfo.SetTargetBitrate(AValue : Integer);
begin
  FRef.target_bitrate := AValue;
end;

procedure TTheoraInfo.SetWidth(AValue : Cardinal);
begin
  FRef.width := AValue;
end;

function TTheoraInfo.Ref : ptheora_info;
begin
  Result := @FRef;
end;

constructor TTheoraInfo.Create;
begin
  FillByte(FRef, Sizeof(FRef), 0);
  Init;
end;

destructor TTheoraInfo.Destroy;
begin
  Done;
  inherited Destroy;
end;

function TTheoraInfo.GetVersionMajor : byte;
begin
  Result := FRef.version_major;
end;

function TTheoraInfo.GetVersionMinor : byte;
begin
  Result := FRef.version_minor;
end;

function TTheoraInfo.GetVersionSubminor : byte;
begin
  Result := FRef.version_subminor;
end;

function TTheoraInfo.GranuleShift : integer;
begin
  Result := theora_granule_shift(@FRef);
end;

{ TTheora }

class function TTheora.NewComment : IOGGComment;
begin
  Result := TTheoraComment.Create as IOGGComment;
end;

class function TTheora.NewEncoder(inf : ITheoraInfo) : ITheoraEncoder;
begin
  Result := TTheoraEncoder.Create(inf) as ITheoraEncoder;
end;

class function TTheora.NewDecoder(inf : ITheoraInfo) : ITheoraDecoder;
begin
  Result := TTheoraDecoder.Create(inf) as ITheoraDecoder;
end;

class function TTheora.NewInfo : ITheoraInfo;
begin
  Result := TTheoraInfo.Create as ITheoraInfo;
end;

class function TTheora.NewYUVBuffer(aOwnData : Boolean) : ITheoraYUVbuffer;
begin
  Result := TTheoraYUVbuffer.Create(aOwnData) as ITheoraYUVbuffer;
end;

class function TTheora.IsHeader(op : IOGGPacket) : Boolean;
begin
  Result := theora_packet_isheader(op.Ref) > 0;
end;

class function TTheora.IsKeyframe(op : IOGGPacket) : Boolean;
begin
  Result := theora_packet_iskeyframe(op.Ref) > 0;
end;

class function TTheora.TheoraLibsLoad(const aTheoraLibs : array of String
  ) : Boolean;
begin
  Result := InitTheoraInterface(aTheoraLibs);
end;

class function TTheora.TheoraLibsLoadDefault : Boolean;
begin
  Result := InitTheoraInterface(TheoraDLL);
end;

class function TTheora.IsTheoraLibsLoaded : Boolean;
begin
  Result := IsTheoraloaded;
end;

class function TTheora.TheoraLibsUnLoad : Boolean;
begin
  Result := DestroyTheoraInterface;
end;

class function TTheora.Version : String;
begin
  Result := StrPas(theora_version_string);
end;

class function TTheora.VersionNumber : Cardinal;
begin
  Result := theora_version_number;
end;


end.
 

(******************************************************************************)
(*                               libTheora_dyn                                *)
(*                  free pascal wrapper around Theora library                 *)
(*                           https://www.theora.org/                          *)
(*                                                                            *)
(* Copyright (c) 2022 Ilya Medvedkov                                          *)
(******************************************************************************)
(*                                                                            *)
(* This source  is free software;  you can redistribute  it and/or modify  it *)
(* under the terms of the  GNU Lesser General Public License  as published by *)
(* the Free Software Foundation; either version 3 of the License (LGPL v3).   *)
(*                                                                            *)
(* This code is distributed in the  hope that it will  be useful, but WITHOUT *)
(* ANY  WARRANTY;  without even  the implied  warranty of MERCHANTABILITY  or *)
(* FITNESS FOR A PARTICULAR PURPOSE.                                          *)
(* See the GNU Lesser General Public License for more details.                *)
(*                                                                            *)
(* A copy of the GNU Lesser General Public License is available on the World  *)
(* Wide Web at <https://www.gnu.org/licenses/lgpl-3.0.html>.                  *)
(*                                                                            *)
(******************************************************************************)

unit libTheora_dyn;

{$mode objfpc}{$H+}

{$packrecords c}

interface

uses dynlibs, SysUtils, libOGG_dynlite, ctypes;

const
{$if defined(UNIX) and not defined(darwin)}
  TheoraDLL : Array [0..2] of String = ('libtheora.so',
                                        'libtheoraenc.so',
                                        'libtheoradec.so');
{$ELSE}
{$ifdef WINDOWS}
  TheoraDLL : Array [0..2] of String = ('theora.dll',
                                        'theoraenc.dll',
                                        'theoradec.dll');
{$endif}
{$endif}

type
  yuv_buffer = record
      y_width   : cint;    { Width of the Y' luminance plane }
      y_height  : cint;    { Height of the luminance plane }
      y_stride  : cint;    { Offset in bytes between successive rows }

      uv_width  : cint;    { Width of the Cb and Cr chroma planes }
      uv_height : cint;    { Height of the chroma planes }
      uv_stride : cint;    { Offset between successive chroma rows }
      y         : pcuchar;      { Pointer to start of luminance data }
      u         : pcuchar;      { Pointer to start of Cb data }
      v         : pcuchar;      { Pointer to start of Cr data }
  end;
  pyuv_buffer = ^yuv_buffer;

  theora_info = record
    width	     : ogg_uint32_t; { encoded frame width  }
    height	     : ogg_uint32_t; { encoded frame height }
    frame_width	     : ogg_uint32_t; { display frame width  }
    frame_height     : ogg_uint32_t; { display frame height }
    offset_x	     : ogg_uint32_t; { horizontal offset of the displayed frame }
    offset_y	     : ogg_uint32_t; { vertical offset of the displayed frame }
    fps_numerator     : ogg_uint32_t;  { frame rate numerator }
    fps_denominator    : ogg_uint32_t; { frame rate denominator }
    aspect_numerator   : ogg_uint32_t; { pixel aspect ratio numerator }
    aspect_denominator : ogg_uint32_t; { pixel aspect ratio denominator }
    colorspace         : cint; { colorspace }
    target_bitrate     : cint; { nominal bitrate in bits per second }
    quality            : cint; { Nominal quality setting, 0-63 }
    quick_p            : cint; { Quick encode/decode }

    { decode only }
    version_major : byte;
    version_minor : byte;
    version_subminor : byte;

    codec_setup : pointer;

    { encode only }
    dropframes_p : cint;
    keyframe_auto_p : cint;
    keyframe_frequency : ogg_uint32_t;
    keyframe_frequency_force : ogg_uint32_t;  { also used for decode init to
                                                get granpos shift correct }
    keyframe_data_target_bitrate : ogg_uint32_t;
    keyframe_auto_threshold : ogg_int32_t;
    keyframe_mindistance : ogg_uint32_t;
    noise_sensitivity : ogg_int32_t;
    sharpness : ogg_int32_t;

    pixelformat : cint;	{ chroma subsampling mode to expect }
  end;
  ptheora_info = ^theora_info;

  theora_state = record
    i : ptheora_info;
    granulepos : ogg_int64_t;
    internal_encode : pointer;
    internal_decode : pointer;
  end;
  ptheora_state = ^theora_state;

  theora_comment = record
    user_comments : ^pcchar;        { An array of comment string vectors }
    comment_lengths : Pcint;        { An array of corresponding string vector lengths in bytes }
    comments : cint;                { The total number of comment string vectors }
    vendor : pcchar;                { The vendor string identifying the encoder, null terminated }
  end;
  ptheora_comment = ^theora_comment;

const
// theora_colorspace
  OC_CS_UNSPECIFIED = Byte(0);    { The colorspace is unknown or unspecified }
  OC_CS_ITU_REC_470M = Byte(1);   { This is the best option for 'NTSC' content }
  OC_CS_ITU_REC_470BG = Byte(2);  { This is the best option for 'PAL' content }
  OC_CS_NSPACES = Byte(3);        { This marks the end of the defined colorspaces }

// theora_pixelformat
  OC_PF_420 = Byte(0);    { Chroma subsampling by 2 in each direction (4:2:0) }
  OC_PF_RSVD = Byte(1);   { Reserved value }
  OC_PF_422 = Byte(2);    { Horizonatal chroma subsampling by 2 (4:2:2) }
  OC_PF_444 = Byte(3);     { No chroma subsampling at all (4:4:4) }

  TH_DECCTL_GET_PPLEVEL_MAX              = 1;
  TH_DECCTL_SET_PPLEVEL                  = 3;
  TH_ENCCTL_SET_KEYFRAME_FREQUENCY_FORCE = 4;
  TH_DECCTL_SET_GRANPOS                  = 5;
  TH_ENCCTL_SET_QUANT_PARAMS             = 2;
  TH_ENCCTL_SET_VP3_COMPATIBLE           = 10;
  TH_ENCCTL_GET_SPLEVEL_MAX              = 12;
  TH_ENCCTL_SET_SPLEVEL                  = 14;


  OC_FAULT      = -1;       { General failure }
  OC_EINVAL     = -10;      { Library encountered invalid internal data }
  OC_DISABLED   = -11;      { Requested action is disabled }
  OC_BADHEADER  = -20;      { Header packet was corrupt/invalid }
  OC_NOTFORMAT  = -21;      { Packet is not a theora packet }
  OC_VERSION    = -22;      { Bitstream version is not handled }
  OC_IMPL       = -23;      { Feature or action not implemented }
  OC_BADPACKET  = -24;      { Packet is corrupt }
  OC_NEWPACKET  = -25;      { Packet is an (ignorable) unhandled extension }
  OC_DUPFRAME   = 1;        { Packet is a dropped frame }

function theora_version_string(): pchar;
function theora_version_number(): ogg_uint32_t;
function theora_encode_init(th: ptheora_state; ti: ptheora_info): cint;
function theora_encode_YUVin(t: ptheora_state; yuv: pyuv_buffer): cint;
function theora_encode_packetout(t: ptheora_state; last_p: cint; op: pogg_packet): cint;
function theora_encode_header(t: ptheora_state; op: pogg_packet): cint;
function theora_encode_comment(tc: ptheora_comment; op: pogg_packet): cint;
function theora_encode_tables(t: ptheora_state; op: pogg_packet): cint;
function theora_decode_header(ci: ptheora_info; cc: ptheora_comment; op: pogg_packet): cint;
function theora_decode_init(th: ptheora_state; c: ptheora_info): cint;
function theora_decode_packetin(th: ptheora_state; op: pogg_packet): cint;
function theora_decode_YUVout(th: ptheora_state; yuv: pyuv_buffer): cint;
function theora_packet_isheader(op: pogg_packet): cint;
function theora_packet_iskeyframe(op: pogg_packet): cint;
function theora_granule_shift(ti: ptheora_info): cint;
function theora_granule_frame(th: ptheora_state; granulepos: ogg_int64_t): ogg_int64_t;
function theora_granule_time(th: ptheora_state; granulepos: ogg_int64_t): double;
procedure theora_info_init(c: ptheora_info);
procedure theora_info_clear(c: ptheora_info);
procedure theora_clear(t: ptheora_state);
procedure theora_comment_init(tc: ptheora_comment);
procedure theora_comment_add(tc: ptheora_comment; comment: pchar);
procedure theora_comment_add_tag(tc: ptheora_comment; tag: pchar; value: pchar);
function theora_comment_query(tc: ptheora_comment; tag: pchar; count: cint): pchar;
function theora_comment_query_count(tc: ptheora_comment; tag: pchar): cint;
procedure theora_comment_clear(tc: ptheora_comment);
function theora_control(th: ptheora_state; req: cint; buf: pointer; buf_sz: csize_t): cint;

function IsTheoraloaded: boolean;
function InitTheoraInterface(const aLibs : array of String): boolean; overload;
function DestroyTheoraInterface: boolean;

implementation

var
  Theoraloaded: boolean = False;
  TheoraLib: Array of HModule;
resourcestring
  SFailedToLoadTheora = 'Failed to load Theora library';

type
  p_theora_version_string = function(): pchar; cdecl;
  p_theora_version_number = function(): ogg_uint32_t; cdecl;
  p_theora_encode_init = function(th: ptheora_state; ti: ptheora_info): cint; cdecl;
  p_theora_encode_YUVin = function(t: ptheora_state; yuv: pyuv_buffer): cint; cdecl;
  p_theora_encode_packetout = function(t: ptheora_state; last_p: cint; op: pogg_packet): cint; cdecl;
  p_theora_encode_header = function(t: ptheora_state; op: pogg_packet): cint; cdecl;
  p_theora_encode_comment = function(tc: ptheora_comment; op: pogg_packet): cint; cdecl;
  p_theora_encode_tables = function(t: ptheora_state; op: pogg_packet): cint; cdecl;
  p_theora_decode_header = function(ci: ptheora_info; cc: ptheora_comment; op: pogg_packet): cint; cdecl;
  p_theora_decode_init = function(th: ptheora_state; c: ptheora_info): cint; cdecl;
  p_theora_decode_packetin = function(th: ptheora_state; op: pogg_packet): cint; cdecl;
  p_theora_decode_YUVout = function(th: ptheora_state; yuv: pyuv_buffer): cint; cdecl;
  p_theora_packet_isheader = function(op: pogg_packet): cint; cdecl;
  p_theora_packet_iskeyframe = function(op: pogg_packet): cint; cdecl;
  p_theora_granule_shift = function(ti: ptheora_info): cint; cdecl;
  p_theora_granule_frame = function(th: ptheora_state; granulepos: ogg_int64_t): ogg_int64_t; cdecl;
  p_theora_granule_time = function(th: ptheora_state; granulepos: ogg_int64_t): double; cdecl;
  p_theora_info_init = procedure(c: ptheora_info); cdecl;
  p_theora_info_clear = procedure(c: ptheora_info); cdecl;
  p_theora_clear = procedure(t: ptheora_state); cdecl;
  p_theora_comment_init = procedure(tc: ptheora_comment); cdecl;
  p_theora_comment_add = procedure(tc: ptheora_comment; comment: pchar); cdecl;
  p_theora_comment_add_tag = procedure(tc: ptheora_comment; tag: pchar; value: pchar); cdecl;
  p_theora_comment_query = function(tc: ptheora_comment; tag: pchar; count: cint): pchar; cdecl;
  p_theora_comment_query_count = function(tc: ptheora_comment; tag: pchar): cint; cdecl;
  p_theora_comment_clear = procedure(tc: ptheora_comment); cdecl;
  p_theora_control = function(th: ptheora_state; req: cint; buf: pointer; buf_sz: csize_t): cint; cdecl;

var
  _theora_version_string: p_theora_version_string = nil;
  _theora_version_number: p_theora_version_number = nil;
  _theora_encode_init: p_theora_encode_init = nil;
  _theora_encode_YUVin: p_theora_encode_YUVin = nil;
  _theora_encode_packetout: p_theora_encode_packetout = nil;
  _theora_encode_header: p_theora_encode_header = nil;
  _theora_encode_comment: p_theora_encode_comment = nil;
  _theora_encode_tables: p_theora_encode_tables = nil;
  _theora_decode_header: p_theora_decode_header = nil;
  _theora_decode_init: p_theora_decode_init = nil;
  _theora_decode_packetin: p_theora_decode_packetin = nil;
  _theora_decode_YUVout: p_theora_decode_YUVout = nil;
  _theora_packet_isheader: p_theora_packet_isheader = nil;
  _theora_packet_iskeyframe: p_theora_packet_iskeyframe = nil;
  _theora_granule_shift: p_theora_granule_shift = nil;
  _theora_granule_frame: p_theora_granule_frame = nil;
  _theora_granule_time: p_theora_granule_time = nil;
  _theora_info_init: p_theora_info_init = nil;
  _theora_info_clear: p_theora_info_clear = nil;
  _theora_clear: p_theora_clear = nil;
  _theora_comment_init: p_theora_comment_init = nil;
  _theora_comment_add: p_theora_comment_add = nil;
  _theora_comment_add_tag: p_theora_comment_add_tag = nil;
  _theora_comment_query: p_theora_comment_query = nil;
  _theora_comment_query_count: p_theora_comment_query_count = nil;
  _theora_comment_clear: p_theora_comment_clear = nil;
  _theora_control: p_theora_control = nil;

{$IFNDEF WINDOWS}
{ Try to load all library versions until you find or run out }
procedure LoadLibUnix(const aLibs : array of String);
var i : cint;
begin
  for i := 0 to High(aLibs) do
    TheoraLib[i] := LoadLibrary(aLibs[i]);
end;

{$ELSE WINDOWS}
procedure LoadLibsWin(const aLibs : array of String);
var i : cint;
begin
  for i := 0 to High(aOGGLibs) do
    TheoraLib[i] := LoadLibrary(aOGGLibs[i]);
end;

{$ENDIF WINDOWS}

function IsTheoraloaded: boolean;
begin
  Result := Theoraloaded;
end;

procedure UnloadLibraries;
var i : cint;
begin
  Theoraloaded := False;
  for i := 0 to High(TheoraLib) do
  if TheoraLib[i] <> NilHandle then
  begin
    FreeLibrary(TheoraLib[i]);
    TheoraLib[i] := NilHandle;
  end;
end;

function LoadLibraries(const aLibs : array of String): boolean;
var i : cint;
begin
  SetLength(TheoraLib, Length(aLibs));
  Result := False;
  {$IFDEF WINDOWS}
  LoadLibsWin(aLibs);
  {$ELSE}
  LoadLibUnix(aLibs);
  {$ENDIF}
  Result := false;
  for i := 0 to High(aLibs) do
  if TheoraLib[i] <> NilHandle then
     Result := true;
end;

function GetProcAddr(const module: Array of HModule; const ProcName: string): Pointer;
var i : cint;
begin
  for i := Low(module) to High(module) do
  if module[i] <> NilHandle then
  begin
    Result := GetProcAddress(module[i], PChar(ProcName));
    if Assigned(Result) then Exit;
  end;
end;

procedure LoadTheoraEntryPoints;
begin
  _theora_version_string := p_theora_version_string(GetProcAddr(TheoraLib, 'theora_version_string'));
  _theora_version_number := p_theora_version_number(GetProcAddr(TheoraLib, 'theora_version_number'));
  _theora_encode_init := p_theora_encode_init(GetProcAddr(TheoraLib, 'theora_encode_init'));
  _theora_encode_YUVin := p_theora_encode_YUVin(GetProcAddr(TheoraLib, 'theora_encode_YUVin'));
  _theora_encode_packetout := p_theora_encode_packetout(GetProcAddr(TheoraLib, 'theora_encode_packetout'));
  _theora_encode_header := p_theora_encode_header(GetProcAddr(TheoraLib, 'theora_encode_header'));
  _theora_encode_comment := p_theora_encode_comment(GetProcAddr(TheoraLib, 'theora_encode_comment'));
  _theora_encode_tables := p_theora_encode_tables(GetProcAddr(TheoraLib, 'theora_encode_tables'));
  _theora_decode_header := p_theora_decode_header(GetProcAddr(TheoraLib, 'theora_decode_header'));
  _theora_decode_init := p_theora_decode_init(GetProcAddr(TheoraLib, 'theora_decode_init'));
  _theora_decode_packetin := p_theora_decode_packetin(GetProcAddr(TheoraLib, 'theora_decode_packetin'));
  _theora_decode_YUVout := p_theora_decode_YUVout(GetProcAddr(TheoraLib, 'theora_decode_YUVout'));
  _theora_packet_isheader := p_theora_packet_isheader(GetProcAddr(TheoraLib, 'theora_packet_isheader'));
  _theora_packet_iskeyframe := p_theora_packet_iskeyframe(GetProcAddr(TheoraLib, 'theora_packet_iskeyframe'));
  _theora_granule_shift := p_theora_granule_shift(GetProcAddr(TheoraLib, 'theora_granule_shift'));
  _theora_granule_frame := p_theora_granule_frame(GetProcAddr(TheoraLib, 'theora_granule_frame'));
  _theora_granule_time := p_theora_granule_time(GetProcAddr(TheoraLib, 'theora_granule_time'));
  _theora_info_init := p_theora_info_init(GetProcAddr(TheoraLib, 'theora_info_init'));
  _theora_info_clear := p_theora_info_clear(GetProcAddr(TheoraLib, 'theora_info_clear'));
  _theora_clear := p_theora_clear(GetProcAddr(TheoraLib, 'theora_clear'));
  _theora_comment_init := p_theora_comment_init(GetProcAddr(TheoraLib, 'theora_comment_init'));
  _theora_comment_add := p_theora_comment_add(GetProcAddr(TheoraLib, 'theora_comment_add'));
  _theora_comment_add_tag := p_theora_comment_add_tag(GetProcAddr(TheoraLib, 'theora_comment_add_tag'));
  _theora_comment_query := p_theora_comment_query(GetProcAddr(TheoraLib, 'theora_comment_query'));
  _theora_comment_query_count := p_theora_comment_query_count(GetProcAddr(TheoraLib, 'theora_comment_query_count'));
  _theora_comment_clear := p_theora_comment_clear(GetProcAddr(TheoraLib, 'theora_comment_clear'));
  _theora_control := p_theora_control(GetProcAddr(TheoraLib, 'theora_control'));
end;

procedure ClearTheoraEntryPoints;
begin
  _theora_version_string := nil;
  _theora_version_number := nil;
  _theora_encode_init := nil;
  _theora_encode_YUVin := nil;
  _theora_encode_packetout := nil;
  _theora_encode_header := nil;
  _theora_encode_comment := nil;
  _theora_encode_tables := nil;
  _theora_decode_header := nil;
  _theora_decode_init := nil;
  _theora_decode_packetin := nil;
  _theora_decode_YUVout := nil;
  _theora_packet_isheader := nil;
  _theora_packet_iskeyframe := nil;
  _theora_granule_shift := nil;
  _theora_granule_frame := nil;
  _theora_granule_time := nil;
  _theora_info_init := nil;
  _theora_info_clear := nil;
  _theora_clear := nil;
  _theora_comment_init := nil;
  _theora_comment_add := nil;
  _theora_comment_add_tag := nil;
  _theora_comment_query := nil;
  _theora_comment_query_count := nil;
  _theora_comment_clear := nil;
  _theora_control := nil;
end;

function InitTheoraInterface(const aLibs : array of String) : boolean;
begin
  Result := IsTheoraloaded;
  if Result then
    exit;
  Result := LoadLibraries(aLibs);
  if not Result then
  begin
    UnloadLibraries;
    Exit;
  end;
  LoadTheoraEntryPoints;
  Theoraloaded := True;
  Result := True;
end;

function DestroyTheoraInterface: boolean;
begin
  Result := not IsTheoraloaded;
  if Result then
    exit;
  ClearTheoraEntryPoints;
  UnloadLibraries;
  Result := True;
end;

function theora_version_string(): pchar;
begin
  if Assigned(_theora_version_string) then
    Result := _theora_version_string()
  else
    Result := nil;
end;

function theora_version_number(): ogg_uint32_t;
begin
  if Assigned(_theora_version_number) then
    Result := _theora_version_number()
  else
    Result := 0;
end;

function theora_encode_init(th: ptheora_state; ti: ptheora_info): cint;
begin
  if Assigned(_theora_encode_init) then
    Result := _theora_encode_init(th, ti)
  else
    Result := 0;
end;

function theora_encode_YUVin(t: ptheora_state; yuv: pyuv_buffer): cint;
begin
  if Assigned(_theora_encode_YUVin) then
    Result := _theora_encode_YUVin(t, yuv)
  else
    Result := 0;
end;

function theora_encode_packetout(t: ptheora_state; last_p: cint; op: pogg_packet): cint;
begin
  if Assigned(_theora_encode_packetout) then
    Result := _theora_encode_packetout(t, last_p, op)
  else
    Result := 0;
end;

function theora_encode_header(t: ptheora_state; op: pogg_packet): cint;
begin
  if Assigned(_theora_encode_header) then
    Result := _theora_encode_header(t, op)
  else
    Result := 0;
end;

function theora_encode_comment(tc: ptheora_comment; op: pogg_packet): cint;
begin
  if Assigned(_theora_encode_comment) then
    Result := _theora_encode_comment(tc, op)
  else
    Result := 0;
end;

function theora_encode_tables(t: ptheora_state; op: pogg_packet): cint;
begin
  if Assigned(_theora_encode_tables) then
    Result := _theora_encode_tables(t, op)
  else
    Result := 0;
end;

function theora_decode_header(ci: ptheora_info; cc: ptheora_comment; op: pogg_packet): cint;
begin
  if Assigned(_theora_decode_header) then
    Result := _theora_decode_header(ci, cc, op)
  else
    Result := 0;
end;

function theora_decode_init(th: ptheora_state; c: ptheora_info): cint;
begin
  if Assigned(_theora_decode_init) then
    Result := _theora_decode_init(th, c)
  else
    Result := 0;
end;

function theora_decode_packetin(th: ptheora_state; op: pogg_packet): cint;
begin
  if Assigned(_theora_decode_packetin) then
    Result := _theora_decode_packetin(th, op)
  else
    Result := 0;
end;

function theora_decode_YUVout(th: ptheora_state; yuv: pyuv_buffer): cint;
begin
  if Assigned(_theora_decode_YUVout) then
    Result := _theora_decode_YUVout(th, yuv)
  else
    Result := 0;
end;

function theora_packet_isheader(op: pogg_packet): cint;
begin
  if Assigned(_theora_packet_isheader) then
    Result := _theora_packet_isheader(op)
  else
    Result := 0;
end;

function theora_packet_iskeyframe(op: pogg_packet): cint;
begin
  if Assigned(_theora_packet_iskeyframe) then
    Result := _theora_packet_iskeyframe(op)
  else
    Result := 0;
end;

function theora_granule_shift(ti: ptheora_info): cint;
begin
  if Assigned(_theora_granule_shift) then
    Result := _theora_granule_shift(ti)
  else
    Result := 0;
end;

function theora_granule_frame(th: ptheora_state; granulepos: ogg_int64_t): ogg_int64_t;
begin
  if Assigned(_theora_granule_frame) then
    Result := _theora_granule_frame(th, granulepos)
  else
    Result := 0;
end;

function theora_granule_time(th: ptheora_state; granulepos: ogg_int64_t): double;
begin
  if Assigned(_theora_granule_time) then
    Result := _theora_granule_time(th, granulepos)
  else
    Result := 0;
end;

procedure theora_info_init(c: ptheora_info);
begin
  if Assigned(_theora_info_init) then
    _theora_info_init(c);
end;

procedure theora_info_clear(c: ptheora_info);
begin
  if Assigned(_theora_info_clear) then
    _theora_info_clear(c);
end;

procedure theora_clear(t: ptheora_state);
begin
  if Assigned(_theora_clear) then
    _theora_clear(t);
end;

procedure theora_comment_init(tc: ptheora_comment);
begin
  if Assigned(_theora_comment_init) then
    _theora_comment_init(tc);
end;

procedure theora_comment_add(tc: ptheora_comment; comment: pchar);
begin
  if Assigned(_theora_comment_add) then
    _theora_comment_add(tc, comment);
end;

procedure theora_comment_add_tag(tc: ptheora_comment; tag: pchar; value: pchar);
begin
  if Assigned(_theora_comment_add_tag) then
    _theora_comment_add_tag(tc, tag, value);
end;

function theora_comment_query(tc: ptheora_comment; tag: pchar; count: cint): pchar;
begin
  if Assigned(_theora_comment_query) then
    Result := _theora_comment_query(tc, tag, count)
  else
    Result := nil;
end;

function theora_comment_query_count(tc: ptheora_comment; tag: pchar): cint;
begin
  if Assigned(_theora_comment_query_count) then
    Result := _theora_comment_query_count(tc, tag)
  else
    Result := 0;
end;

procedure theora_comment_clear(tc: ptheora_comment);
begin
  if Assigned(_theora_comment_clear) then
    _theora_comment_clear(tc);
end;

function theora_control(th: ptheora_state; req: cint; buf: pointer; buf_sz: csize_t): cint;
begin
  if Assigned(_theora_control) then
    Result := _theora_control(th, req, buf, buf_sz)
  else
    Result := 0;
end;

end.


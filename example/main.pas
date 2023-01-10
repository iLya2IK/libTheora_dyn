unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, EditBtn, StdCtrls,
  ComCtrls, Spin, ExtCtrls, ValEdit,
  FPReadPNG,
  OGLOGGWrapper, OGLTheoraWrapper,
  ECommonObjs, kcThreadPool;

type

  TFrameState = (frIdle, frDecoding, frIdleDecoded, frEncoding, frIdleEncoded, frFailed);

  { TThreadedFrame }

  TThreadedFrame = class(TThreadSafeObject)
  private
    FFileName : String;
    FFrameID : integer;
    FState : TFrameState;

    FYUVBuffer : ITheoraYUVbuffer;
    function GetFrameID : integer;
    function GetState : TFrameState;
    procedure SetState(AValue : TFrameState);
  public
    constructor Create(const aFileName : String; aFrameID : Integer);
    destructor Destroy; override;

    property FileName : String read FFileName;
    property FrameID : integer read GetFrameID;
    property State : TFrameState read GetState write SetState;
    property YUVBuffer : ITheoraYUVbuffer read FYUVBuffer;
  end;

  { TThreadedFrames }

  TThreadedFrames = class
  private
    FFrames : Array of TThreadedFrame;
    FOnLog : TThreadMethod;
    FPos : TThreadInteger;
    FLog : TThreadStringList;
    procedure SetOnLog(AValue : TThreadMethod);
  public
    constructor Create(aCount : Integer);
    destructor Destroy; override;

    function Count : Integer;
    function Status : Integer;
    procedure SetStatus(aValue : Integer);
    procedure AddLog(const Str: String);

    function  GetFrame(index : integer) : TThreadedFrame;
    procedure SetFrame(index : integer; fr : TThreadedFrame);

    property Log : TThreadStringList read FLog;
    property OnLog : TThreadMethod read FOnLog write SetOnLog;
  end;

  { TTheoraThreadedEncoder }

  TTheoraThreadedEncoder = class(TJob)
  private
    FOnProgress : TThreadMethod;
    FOnStop : TThreadMethod;
    FWorking : Boolean;
    FFrames : TThreadedFrames;
    FCurFrame : Integer;
    FInfo : ITheoraInfo;
    FEnc : ITheoraEncoder;
    FOGGStr : IOGGStreamState;
    FFileName : String;
    FError : String;
    FVL : TStringList;
    procedure SetOnProgress(AValue : TThreadMethod);
    procedure SetOnStop(AValue : TThreadMethod);
  public
    constructor Create(fr : TThreadedFrames;
      const aFN : String;
      VL : TStringList;
      aInfo : ITheoraInfo);
    destructor Destroy; override;
    procedure Execute; override;

    property OnProgress : TThreadMethod read FOnProgress write SetOnProgress;
    property OnStop : TThreadMethod read FOnStop write SetOnStop;
  end;

  { TThreadedPngDecoder }

  TThreadedPngDecoder = class(TJob)
  private
    FFrame  : TThreadedFrame;
    FChroma : TTheoraPixelFormat;
  public
    constructor Create(fr : TThreadedFrame; chroma : TTheoraPixelFormat);
    procedure Execute; override;
  end;

  { TMyPngReader }

  TMyPngReader = class(TFPReaderPNG)
  public
    class function InternalSize(Str:TStream): TPoint; override;
  end;

  { TForm1 }

  TForm1 = class(TForm)
    BitrateEdit : TSpinEdit;
    Button1 : TButton;
    CurDirEdit : TDirectoryEdit;
    ImagesList : TListBox;
    Label1 : TLabel;
    Label10 : TLabel;
    Label2 : TLabel;
    Label3 : TLabel;
    Label4 : TLabel;
    Label5 : TLabel;
    Label6 : TLabel;
    Label7 : TLabel;
    Label8 : TLabel;
    Label9 : TLabel;
    Memo1 : TMemo;
    OutFileEdit : TFileNameEdit;
    Panel1 : TPanel;
    Panel2 : TPanel;
    Panel3 : TPanel;
    Panel4 : TPanel;
    PixelFormatCBox : TComboBox;
    ProgressBar1 : TProgressBar;
    QualityEdit : TTrackBar;
    SamplingEdit : TSpinEdit;
    ScrollBox1 : TScrollBox;
    SpinEdit2 : TSpinEdit;
    ValueListEditor1 : TValueListEditor;
    procedure Button1Click(Sender : TObject);
    procedure CurDirEditChange(Sender : TObject);
    procedure CurDirEditEditingDone(Sender : TObject);
    procedure FormCreate(Sender : TObject);
    procedure FormDestroy(Sender : TObject);
    procedure FormShow(Sender : TObject);
  private
    function WorkingPath : String;
    function OutputFilename : String;
    function PixelFormat : TTheoraPixelFormat;
    function Quality : Integer;
    function Bitrate : Integer;
    function Sampling : Integer;

    procedure StartConvertion;
    procedure RebuildFileList;
    procedure ProgressChanged;
    procedure StopConvertion;
    procedure OnLog;
  public

  end;

var
  Form1 : TForm1;

implementation

var vFrames : TThreadedFrames;
    vThreadPool : TThreadPool;

{$R *.lfm}

{ TMyPngReader }

class function TMyPngReader.InternalSize(Str : TStream) : TPoint;
begin
  Result := inherited InternalSize(Str);
end;

{ TForm1 }

procedure TForm1.Button1Click(Sender : TObject);
begin
  Panel1.Enabled := false;
  Panel4.Enabled := false;
  Button1.Enabled := false;
  Memo1.Lines.Clear;
  StartConvertion;
  if not Assigned(vFrames) then
  begin
    Panel1.Enabled := true;
    Panel4.Enabled := true;
    Button1.Enabled := true;
  end;
end;

procedure TForm1.CurDirEditChange(Sender : TObject);
begin
  RebuildFileList;
end;

procedure TForm1.CurDirEditEditingDone(Sender : TObject);
begin
  RebuildFileList;
end;

procedure TForm1.FormCreate(Sender : TObject);
begin
  TOGG.OGGLibsLoadDefault;
  TTheora.TheoraLibsLoadDefault;
end;

procedure TForm1.FormDestroy(Sender : TObject);
begin
  if Assigned(vThreadPool) then
    vThreadPool.Free;
  if Assigned(vFrames) then
    vFrames.Free;

  TOGG.OGGLibsUnLoad;
  TTheora.TheoraLibsUnLoad;
end;

procedure TForm1.FormShow(Sender : TObject);
begin
  RebuildFileList;
end;

function TForm1.WorkingPath : String;
begin
  Result := CurDirEdit.Directory;
  if length(Result) > 0 then
  begin
    if Result[Length(Result)] <> DirectorySeparator then
    begin
      Result := Result + DirectorySeparator;
    end;
  end;
end;

function TForm1.OutputFilename : String;
begin
  Result := OutFileEdit.Text;
end;

function TForm1.PixelFormat : TTheoraPixelFormat;
begin
  case PixelFormatCBox.ItemIndex of
  0 : Result := tpf444;
  1 : Result := tpf422;
  2 : Result := tpf420;
  end;
end;

function TForm1.Quality : Integer;
begin
  Result := QualityEdit.Position;
end;

function TForm1.Bitrate : Integer;
begin
  Result := BitrateEdit.Value;
end;

function TForm1.Sampling : Integer;
begin
  Result := SamplingEdit.Value;
end;

procedure TForm1.StartConvertion;
var SL : TStringList;
    Fr : TThreadedFrame;
    DJ : TThreadedPngDecoder;
    EJ : TTheoraThreadedEncoder;
    TI : ITheoraInfo;
    FS : TFileStream;
    i : integer;
    wh : TPoint;

    discrete_delta : integer;
    video_fps_denominator : integer;
    video_aspect_numerator,
    video_aspect_denominator,
    video_quality, video_rate : integer;
    chroma_format : TTheoraPixelFormat;
    video_fps_numerator : integer;
begin
  if Assigned(vFrames) then FreeAndNil( vFrames );
  if not Assigned(vThreadPool) then begin
    vThreadPool := TThreadPool.Create(4);
  end;
  vThreadPool.Running := false;


  SL := TStringList.Create;
  try
    SL.Assign(ImagesList.Items);
    if SL.Count > 0 then
    begin
      FS := TFileStream.Create(SL[0], fmOpenRead);
      try
        wh := TMyPngReader.InternalSize(FS);
      finally
        FS.Free;
      end;

      if wh.x > 0 then
      begin
        TI := TTheora.NewInfo;

        TI.Width := ((wh.x + 15) shr 4) shl 4;
        TI.Height := ((wh.y + 15) shr 4) shl 4;
        TI.FrameWidth := wh.x;
        TI.FrameHeight := wh.y;
        TI.OffsetX := 0;
        TI.OffsetY := 0;

        discrete_delta := Sampling;
        video_fps_denominator := 1;
        video_aspect_numerator := 0;
        video_aspect_denominator := 0;
        video_quality := Quality * 63 div 10;
        chroma_format := PixelFormat;
        video_fps_numerator := 1000 div discrete_delta;
        video_rate := Bitrate * 1000;

        TI.FPSNumerator := video_fps_numerator;
        TI.FPSDenominator := video_fps_denominator;
        TI.AspectNumerator := video_aspect_numerator;
        TI.AspectDenominator := video_aspect_denominator;
        TI.Colorspace := tcsUnspec;
        TI.PixelFormat := chroma_format;
        TI.TargetBitrate := video_rate;
        TI.Quality := video_quality;

        TI.DropFrames := false;
        TI.Quick := true;
        TI.KeyframeAuto := true;
        TI.KeyframeFrequency := 32768;
        TI.KeyframeFrequencyForce :=32768;
        TI.KeyframeDataTargetBitrate := round(video_rate*1.5);
        TI.KeyframeAutoThreshold := 80;
        TI.KeyframeMindistance := 8;
        TI.NoiseSensitivity :=1;

        vFrames := TThreadedFrames.Create(SL.Count);
        vFrames.OnLog := @OnLog;
        for i := 0 to SL.Count-1 do
        begin
          Fr := TThreadedFrame.Create(SL[i], i);
          vFrames.SetFrame(i, Fr);
        end;
      end;
    end;
  finally
    SL.Free;
  end;

  if Assigned(vFrames) then
  begin
    EJ := TTheoraThreadedEncoder.Create(vFrames, OutputFilename,
                                        ValueListEditor1.Strings, TI);
    EJ.OnProgress := @ProgressChanged;
    EJ.OnStop := @StopConvertion;
    vThreadPool.Add(EJ);
    for i := 0 to vFrames.Count-1 do
    begin
      DJ := TThreadedPngDecoder.Create(vFrames.GetFrame(i), chroma_format);
      vThreadPool.Add(DJ);
    end;
    vThreadPool.Running := true;
  end;
end;

procedure TForm1.RebuildFileList;
var
  SR : TSearchRec;
  SL : TStringList;
begin
  if DirectoryExists(WorkingPath) then
  begin
    SL := TStringList.Create;
    try
      If FindFirst(WorkingPath + '*.png',faArchive,SR)=0 then
      begin
        Repeat
          SL.Add(WorkingPath + SR.Name);
        Until FindNext(SR) <> 0;
        FindClose(SR);
      end;
      SL.Sort;
      ImagesList.Items.Assign(SL);
    finally
      SL.Free;
    end;
  end;
end;

procedure TForm1.ProgressChanged;
begin
  ProgressBar1.Position := vFrames.Status;
end;

procedure TForm1.StopConvertion;
begin
  Button1.Enabled := true;
  Panel1.Enabled := true;
  Panel4.Enabled := true;
end;

procedure TForm1.OnLog;
var i : integer;
begin
  vFrames.Log.Lock;
  try
    for i := 0 to vFrames.Log.Count-1 do
    begin
      Memo1.Lines.Add(vFrames.Log[i]);
    end;
    vFrames.Log.Clear;
  finally
    vFrames.Log.UnLock;
  end;
end;

{ TThreadedPngDecoder }

constructor TThreadedPngDecoder.Create(fr : TThreadedFrame;
  chroma : TTheoraPixelFormat);
begin
  inherited Create;
  FFrame := fr;
  FChroma := chroma;
end;

procedure TThreadedPngDecoder.Execute;
var png : TPortableNetworkGraphic;
begin
  FFrame.State := frDecoding;

  png := TPortableNetworkGraphic.Create;
  try
    try
      png.LoadFromFile(FFrame.FileName);

      if FFrame.YUVBuffer.ConvertFromRasterImage(FChroma,
                                                 png.Width,
                                                 png.Height,
                                                 png) then
         FFrame.State := frIdleDecoded
      else
         FFrame.State := frFailed;
    except
      on e : Exception do FFrame.State := frFailed;
    end;
  finally
    png.Free;
  end;
end;

{ TTheoraThreadedEncoder }

procedure TTheoraThreadedEncoder.SetOnProgress(AValue : TThreadMethod);
begin
  if FOnProgress = AValue then Exit;
  FOnProgress := AValue;
end;

procedure TTheoraThreadedEncoder.SetOnStop(AValue : TThreadMethod);
begin
  if FOnStop = AValue then Exit;
  FOnStop := AValue;
end;

constructor TTheoraThreadedEncoder.Create(fr : TThreadedFrames;
  const aFN : String; VL : TStringList; aInfo : ITheoraInfo);
begin
  inherited Create;
  FError := '';
  FCurFrame := 0;
  FWorking := true;
  FFrames := fr;
  FInfo := aInfo;
  FFileName := aFN;
  FOGGStr := TOGG.NewStream(0);
  FEnc := TTheora.NewEncoder(aInfo);
  FVL := TStringList.Create;
  FVL.Assign(VL);
end;

destructor TTheoraThreadedEncoder.Destroy;
begin
  FVL.Free;
  inherited Destroy;
end;

procedure TTheoraThreadedEncoder.Execute;
var FS : TFileStream;
    Frame : TThreadedFrame;
    tc : IOGGComment;
    i : integer;
begin
  FS := TFileStream.Create(FFileName, fmOpenWrite or fmCreate);
  try
    try
      tc := TTheora.NewComment;
      for i := 0 to FVL.Count-1 do
        tc.AddTag(FVL.Names[i], FVL.ValueFromIndex[i]);
      FEnc.SaveCustomHeadersToStream(FOGGStr, FS, tc);

      while FWorking do
      begin
        if FCurFrame >= FFrames.Count then
        begin
          FError := 'Encoding completed successfully';
          FWorking := false;
          break;
        end;

        Frame := FFrames.GetFrame(FCurFrame);

        if Frame.State = frIdleDecoded then
        begin
          Frame.State := frEncoding;

          FEnc.SaveYUVBufferToStream(FOGGStr, FS,
                                     Frame.FYUVBuffer,
                                     FCurFrame = (FFrames.Count-1));

          Frame.State := frIdleEncoded;
          Inc(FCurFrame);

          FFrames.SetStatus(FCurFrame * 100 div FFrames.Count);

          if assigned(FOnProgress) then
            TThread.Synchronize(nil, FOnProgress);

          FFrames.AddLog('Frame finished ' + inttostr(FCurFrame));

          Sleep(1);
        end else
        if Frame.State = frFailed then
        begin
          FError := 'Failed frame';
          FWorking := false;
          break;
        end else
          Sleep(2);
      end;
    except
      on e : Exception do FError := e.ToString;
    end;
  finally
    FS.Free;
  end;

  if FError <> '' then
    FFrames.AddLog(FError);

  if assigned(FOnStop) then
    TThread.Synchronize(nil, FOnStop);
end;

{ TThreadedFrames }

procedure TThreadedFrames.SetOnLog(AValue : TThreadMethod);
begin
  if FOnLog = AValue then Exit;
  FOnLog := AValue;
end;

procedure TThreadedFrames.AddLog(const Str : String);
begin
  FLog.Add(Str);
  if Assigned(FOnLog) then
    TThread.Synchronize(nil, FOnLog);
end;

constructor TThreadedFrames.Create(aCount : Integer);
var i : integer;
begin
  FLog := TThreadStringList.Create;
  FPos := TThreadInteger.Create(0);
  SetLength(FFrames, aCount);
  For i := 0 to high(FFrames) do
     FFrames[i] := nil;
end;

destructor TThreadedFrames.Destroy;
var i : integer;
begin
  For i := 0 to high(FFrames) do
  if Assigned(FFrames[i]) then
     FreeAndNil( FFrames[i] );
  FPos.Free;
  FLog.Free;
  inherited Destroy;
end;

function TThreadedFrames.Count : Integer;
begin
  Result := Length(FFrames);
end;

function TThreadedFrames.Status : Integer;
begin
  Result := FPos.Value;
end;

procedure TThreadedFrames.SetStatus(aValue : Integer);
begin
  FPos.Value := aValue;
end;

function TThreadedFrames.GetFrame(index : integer) : TThreadedFrame;
begin
  Result := FFrames[index];
end;

procedure TThreadedFrames.SetFrame(index : integer; fr : TThreadedFrame);
begin
  FFrames[index] := fr;
end;

{ TThreadedFrame }

function TThreadedFrame.GetFrameID : integer;
begin
  Lock;
  try
    Result := FFrameID;
  finally
    UnLock;
  end;
end;

function TThreadedFrame.GetState : TFrameState;
begin
  Lock;
  try
    Result := FState;
  finally
    UnLock;
  end;
end;

procedure TThreadedFrame.SetState(AValue : TFrameState);
begin
  Lock;
  try
    FState := AValue;
  finally
    UnLock;
  end;
end;

constructor TThreadedFrame.Create(const aFileName : String; aFrameID : Integer);
begin
  inherited Create;
  FFileName := aFileName;
  FFrameID := aFrameID;
  FState := frIdle;
  FYUVBuffer := TTheora.NewYUVBuffer(true);
end;

destructor TThreadedFrame.Destroy;
begin
  inherited Destroy;
end;

end.


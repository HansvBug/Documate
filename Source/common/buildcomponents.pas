unit BuildComponents;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, StdCtrls, ExtCtrls, Grids, Buttons;

type
  PtrItemObject = ^ItemObjectData; // Only used for disposing pointer data from TStringGrid
  ItemObjectData = record
    Id_table         : Integer;  // ID column database table ITEMS. NOT used
    Guid             : String;
    Level            : Integer;
    Name             : String;
    Parent_guid      : array of String;
    MemoNew          : String;
    MemoCurrent      : String;
    Action           : String;
  end;

  { TBuildComponents }

  TBuildComponents = class(TObject)
    private
      FColCount: Integer;
      _panel : TPanel;
      _splitter : TSplitter;

      procedure SetArrays;
      procedure BuildBodyPanelsAndSplitters(aParentSingle, aParentMultiple: Pointer);
      procedure BuildHeaderPanels;
      procedure BuildSearchPanels;
      procedure BuildDataPanels;
      procedure BuildStringGrids;
      procedure BuildLabelHeaderPanels;
      procedure BuildBitButtonsAdd;

      function CreatePanel(aName : String; aParent : TWinControl; aWidth : Integer) : TPanel;
      function CreateSplitter(aName : String; aParent : TWinControl) : TSplitter;
      function CreateStringGrid(aName : String; aParent : TWinControl) : TStringGrid;
      function CreateLabel(aName : String; aParent : TWinControl) : TLabel;
      function CreateBitButton(aName : String; aParent : TWinControl) : TBitBtn;
      procedure RemovePointerdata(aParent : Pointer);
    public
      allSplitters : array of TSplitter;
      AllPanels : Array of TPanel;
      AllStringGrids : array of TStringGrid;
      AllLabels : array of TLabel;
      AllBitButtonsAdd : array of TBitBtn;


      constructor Create(ColCount: Integer ); overload; { The correct number of components is created using ColCount. }
      destructor  Destroy; override;

      function BuildAllComponents(aParentSingleColumn, aParentMultipleColumns: Pointer
        ): Boolean;
      procedure RemoveOwnComponents(aParent : Pointer);
  end;


implementation

{ TBuildComponent }

procedure TBuildComponents.SetArrays;
begin
  Setlength(AllPanels, FColCount);  // allPanels
  Setlength(allSplitters, FColCount);
end;

procedure TBuildComponents.BuildBodyPanelsAndSplitters(aParentSingle,
  aParentMultiple: Pointer);
var
  i : Integer;
  aControlSingle, aControlMultiple : TWinControl;
begin
  if aParentSingle <> nil then begin
    aControlSingle :=  TWinControl(aParentSingle);
    if aControlSingle.Name = 'sbxLeft' then begin
        allPanels[0] := CreatePanel('PanelBody_' + IntToStr(1), aControlSingle, 200);
        allPanels[0].Align := alClient;
        allPanels[0].BorderStyle := bsSingle;
        //allPanels[0].Color := clSkyBlue;
    end;
  end;

  if aParentMultiple <> nil then begin
    aControlMultiple :=  TWinControl(aParentMultiple);
    if aControlMultiple.Name = 'sbxMain' then begin
      for i := 1 to FColCount-1 do begin
        allPanels[i] := CreatePanel('PanelBody_' + IntToStr(i+1), aControlMultiple, 200);
        allPanels[i].AnchorSide[akLeft].Control := aControlMultiple;
        allPanels[i].Align := alLeft;
        allPanels[i].BorderStyle := bsSingle;

        if i = FColCount-1 then begin // build 1 splitter less and align the last panel allClient
          allPanels[i].Align := alClient;
          break;
        end;

        allSplitters[i] := CreateSplitter('Splitter_' + IntToStr(i+1), aControlMultiple);
        allSplitters[i].Align := alLeft;
        allSplitters[i].AnchorSide[akLeft].Control := allPanels[i];
      end;
    end;
  end;
end;

procedure TBuildComponents.BuildHeaderPanels;
var
  i, newPanelNumber, allPanelsSize : Integer;
  newPanels : array of TPanel = nil;
begin
  newPanelNumber := 1;
  for i := 0 to Length(allPanels)-1 do begin
    if Pos('PanelBody_' + IntToSTr(i+1), allpanels[i].Name) > 0 then begin
      SetLength(newPanels, newPanelNumber);
      newPanels[newPanelNumber-1] := CreatePanel('PanelHeader_' + IntToStr(newPanelNumber), allPanels[i], 50);
      newPanels[newPanelNumber-1].Align := alTop;
      newPanels[newPanelNumber-1].Caption := '';  // not used
      inc(newPanelNumber);
    end;
  end;

  // keep 1 array with panels
  for i := 0 to Length(newPanels)-1 do begin
    allPanelsSize := Length(allPanels);
    SetLength(allPanels, allPanelsSize+1);
    allPanels[allPanelsSize] := newPanels[i];
    inc(allPanelsSize);
  end;
end;

procedure TBuildComponents.BuildSearchPanels;
var
  i, newPanelNumber, allPanelsSize : Integer;
  newPanels : array of TPanel = nil;
begin
  //create search panels
  newPanelNumber := 1;

  for i := 0 to Length(allPanels)-1 do begin
    if Pos('PanelBody_' + IntToSTr(i+1), allpanels[i].Name) > 0 then begin
      SetLength(newPanels, newPanelNumber);
      newPanels[newPanelNumber-1] := CreatePanel('PanelSearch_' + IntToStr(newPanelNumber), allPanels[i], 50);
      newPanels[newPanelNumber-1].Align := alBottom;
        //newPanels[newPanelNumber-1].Caption := 'Search '+ IntToStr(newPanelNumber);
      newPanels[newPanelNumber-1].Caption := '';  // Not used
      inc(newPanelNumber);
    end;
  end;

  // keep 1 array with panels
  for i := 0 to Length(newPanels)-1 do begin
    allPanelsSize := Length(allPanels);
    SetLength(allPanels, allPanelsSize+1);
    allPanels[allPanelsSize] := newPanels[i];
    inc(allPanelsSize);
  end;
end;

procedure TBuildComponents.BuildDataPanels;
var
  i, newPanelNumber, allPanelsSize : Integer;
  newPanels : array of TPanel;
begin
  newPanelNumber := 1;

  for i := 0 to Length(allPanels)-1 do begin
    if Pos('PanelBody_' + IntToSTr(i+1), allpanels[i].Name) > 0 then begin
      SetLength({%H-}newPanels, newPanelNumber);{%H+}
      newPanels[newPanelNumber-1] := CreatePanel('PanelData_' + IntToStr(newPanelNumber), allPanels[i], 50);
      newPanels[newPanelNumber-1].Align := alClient;
      // newPanels[newPanelNumber-1].Caption := 'PanelData_ '+ IntToStr(newPanelNumber);
      newPanels[newPanelNumber-1].Caption := '';
      inc(newPanelNumber);
    end;
  end;

  // keep 1 array with panels
  for i := 0 to Length(newPanels)-1 do begin
    allPanelsSize := Length(allPanels);
    SetLength(allPanels, allPanelsSize+1);
    allPanels[allPanelsSize] := newPanels[i];
    inc(allPanelsSize);
  end;
end;

procedure TBuildComponents.BuildStringGrids;
var
  i, newStringGrid : Integer;
begin
  newStringGrid := 1;

  for i := 0 to Length(allPanels)-1 do begin
    if Pos('PanelData_', allpanels[i].Name) > 0 then begin
      SetLength(AllStringGrids, newStringGrid);
      AllStringGrids[newStringGrid-1] := CreateStringGrid('STRINGGRID_' + IntToStr(newStringGrid), allPanels[i]);
      AllStringGrids[newStringGrid-1].Align := alClient;
      Inc(newStringGrid);
    end;
  end;
end;

procedure TBuildComponents.BuildLabelHeaderPanels;
var
  i, counter : Integer;
  compNumber : Integer;
begin
  counter := Length(AllLabels);
  compNumber := 1;
  for i := 0 to Length(allPanels)-1 do begin
    if Pos('PanelHeader_', allpanels[i].Name) > 0 then begin
      Inc(counter);
      SetLength(AllLabels, counter);
      AllLabels[counter-1] := CreateLabel('LabelHeaderColumnName_' + IntToStr(compNumber), allPanels[i]);
      Inc(compNumber);
    end;
  end;
end;

procedure TBuildComponents.BuildBitButtonsAdd;
var
  i, counter : Integer;
  compNumber : Integer;
begin
  counter := Length(AllBitButtonsAdd);
  compNumber := 1;

  for i := 0 to Length(allPanels)-1 do begin
    if Pos('PanelHeader_', allpanels[i].Name) > 0 then begin
      Inc(counter);
      SetLength(AllBitButtonsAdd, counter);
      AllBitButtonsAdd[counter-1] := CreateBitButton('BitButtonAdd_' + IntToStr(compNumber), allPanels[i]);
      AllBitButtonsAdd[counter-1].Left := 10;
      AllBitButtonsAdd[counter-1].Caption := '+';
      AllBitButtonsAdd[counter-1].Visible := False;

      //AllBitButtonsAdd[counter-1].Images := DataModule1.ImageList1;
      AllBitButtonsAdd[counter-1].ImageIndex := 4;
      Inc(compNumber);
    end;
  end;
end;

function TBuildComponents.CreatePanel(aName: String; aParent: TWinControl;
  aWidth: Integer): TPanel;
begin
  _panel := TPanel.Create(aParent);
  _panel.Parent := aParent;
  _panel.Name := aName;
  _panel.Width := aWidth;
  _panel.FullRepaint := False;  // Should avoid flickering.
  _panel.ParentBackground := False;
  _panel.DoubleBuffered := True;
  _panel.Left := 9999;  // Necessary because otherwise the splitter will be on the left of the panel instead of on the right
                        // https://forum.lazarus.freepascal.org/index.php?action=post;topic=62608.0;last_msg=473575
  _panel.BevelInner := bvNone;
  _panel.BevelOuter := bvNone;  // bvRaised
  _panel.Constraints.MinWidth := 25;

  result := _panel;
end;

function TBuildComponents.CreateSplitter(aName: String; aParent: TWinControl
  ): TSplitter;
begin
  _splitter := TSplitter.Create(aParent);
  _splitter.Parent := aParent;
  _splitter.Name := aName;
  _splitter.Width := 8;
  _splitter.Left := 9999;
  _splitter.Beveled := True;

  result := _splitter;
end;

function TBuildComponents.CreateStringGrid(aName: String; aParent: TWinControl
  ): TStringGrid;
var
  Column   : TGridColumn;
  _stringGrid : TStringGrid;
begin
  _stringGrid := TStringGrid.Create(aParent);
  _stringGrid.Parent := aParent;
  _stringGrid.Name := aName;
  _stringGrid.Width := 10;
  _stringGrid.Align := alClient;

  _stringgrid.AutoAdvance := aaRight;
  _stringGrid.AutoFillColumns := true;
  _stringGrid.DefaultColWidth := 20;
  _stringGrid.RowCount := 1;
  _stringGrid.ScrollBars := ssBoth;
  _stringgrid.TitleStyle := tsNative;
  _stringGrid.TabAdvance := aaRightDown;

  _stringGrid.Options := _stringGrid.Options + [goEditing, goAutoAddRows, goTabs, goHeaderHotTracking, goTruncCellHints, goCellHints];
  _stringGrid.Options := _stringGrid.Options - [goRangeSelect];

  _stringGrid.ShowHint:= True; // combined with goTruncCellHints, goCellHints. Then every cell shows its valus in a hint.


  Column := TGridColumn.Create(_stringGrid.Columns);
  Column.Title.Caption := 'Parent';
  Column.ButtonStyle := cbsCheckboxColumn;


  Column := TGridColumn.Create(_stringGrid.Columns);
  Column.Title.Caption := 'Child';
  Column.ButtonStyle := cbsCheckboxColumn;

  Column := TGridColumn.Create(_stringGrid.Columns);
  Column.Title.Caption := '';
  Column.Width := 100;
  Column.Title.Font.Bold:= True;

  _stringGrid.Columns[0].Visible := False;  // Parent   avoid showing the column title when creating a new file.
  _stringGrid.Columns[1].Visible := False;  // Child    avoid showing the column title when creating a new file.

{
  _stringgrid.AutoAdvance := aaRight;
  //_stringgrid.AutoEdit := True;
  _stringGrid.AutoFillColumns := true;
  //_stringGrid.ColumnClickSorts := True; { #todo -o- : Sorten aanzetten zodra de selectie kleuren meer gaan tijdens het sorteren. }
  _stringGrid.DefaultColWidth := 20;  // Set the columns to 20 so the indicator columns will be small.
  _stringgrid.Flat := True;
  _stringGrid.RowCount := 1;   // start with 1 row
  _stringgrid.ShowHint := True;
  _stringGrid.TabAdvance := aaRightDown;
  _stringgrid.TitleStyle := tsNative;

  Column := TGridColumn.Create(_stringGrid.Columns);
  Column.Title.Caption := 'Parent';
  Column.ButtonStyle := cbsCheckboxColumn;

  Column := TGridColumn.Create(_stringGrid.Columns);
  Column.Title.Caption := 'Child';
  Column.ButtonStyle := cbsCheckboxColumn;

  Column := TGridColumn.Create(_stringGrid.Columns);
  Column.Title.Caption := 'Item';
  Column.Width := 100;

  _stringGrid.Columns[0].Visible := False;  // Parent
  _stringGrid.Columns[1].Visible := False;  // Child
  _stringGrid.Columns[2].Visible := True;   // Item

  _stringGrid.Cells[1,0] := '0';  // "uncheck" parent checkbox cell
  _stringGrid.Cells[2,0] := '0';  // "uncheck" child checkbox cell

  _stringGrid.Options := _stringGrid.Options + [goColSizing, goDblClickAutoSize, goHeaderHotTracking, goTabs]; // goTabs = met TAB binnen de stringgrid door de rijen scrollen. (Kan dan niet met een tab naar een andere stringgrid).
  _stringGrid.Options := _stringGrid.Options - [goRangeSelect, goEditing, goAutoAddRows];
 }
  result := _stringGrid;
end;

function TBuildComponents.CreateLabel(aName: String; aParent: TWinControl
  ): TLabel;
var
  _label : TLabel;
begin
  _label := TLabel.Create(aParent);
  _label.Parent := aParent;
  _label.Visible := True;
  _label.Name := aName;
  _label.Left := aParent.Left + 20;
  _label.Top := aParent.Top + 5;
  _label.Anchors := [TAnchorKind.akLeft, TAnchorKind.akTop];
  _label.Font.Color := clBlack;
  _label.Caption := '';

  result := _label;
end;

function TBuildComponents.CreateBitButton(aName: String; aParent: TWinControl
  ): TBitBtn;
var
  _bitButton : TBitBtn;
begin
  _bitButton := TBitBtn.Create(aParent);
  _bitButton.Parent := aParent;
  _bitButton.Name := aName;
  _bitButton.Height := 22;
  _bitButton.Top := aParent.Height - _bitButton.Height -5;  // div is an integer division.
  _bitButton.Width := 25;
  _bitButton.Anchors := [TAnchorKind.akBottom, TAnchorKind.akLeft ]; // TAnchorKind.akRight
  _bitButton.ShowHint:= True;

  result := _bitButton;
end;

procedure TBuildComponents.RemovePointerdata(aParent: Pointer);
var
  i, j, k, c, r : Integer;
  aControl :  TWinControl;
  _stringGrid : TStringGrid;
  _panel1, _panel2 : TPanel;
begin
  aControl :=  TWinControl(aParent);

  for i := aControl.ControlCount-1 downto 0  do begin
    if aControl.Controls[i] is TPanel then begin
      _panel1 := TPanel(aControl.Controls[i]);
      if _panel1.Name.Contains('PanelBody_') then begin
        for j:= 0 to _panel1.ControlCount -1 do begin
          if _panel1.Controls[j] is TPanel then begin
            _panel2 := TPanel(_panel1.Controls[j]);
            if _panel2.Name.Contains('PanelData_') then begin
              for k:= 0 to _panel2.ControlCount -1 do begin
                if _panel2.Controls[k] is TStringGrid then begin
                  // remove the pointer object data.
                  _stringGrid := TStringGrid(_panel2.Controls[k]);

                  for r := _stringGrid.RowCount-1 downto 0 do begin
                    for c := 0 to _stringGrid.ColCount -1 do begin
                      if PtrItemObject(_stringGrid.Objects[c,r]) <> nil then begin
                        Dispose(PtrItemObject(_stringGrid.Objects[c,r]));
                        break;
                      end;
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

constructor TBuildComponents.Create(ColCount: Integer);
begin
  inherited Create;

  FColCount := ColCount;
end;

destructor TBuildComponents.Destroy;
begin
  //...
  inherited Destroy;
end;

function TBuildComponents.BuildAllComponents(aParentSingleColumn,
  aParentMultipleColumns: Pointer): Boolean;
begin
  try
    SetArrays;
    BuildBodyPanelsAndSplitters(aParentSingleColumn, aParentMultipleColumns);
    BuildHeaderPanels;
    BuildBitButtonsAdd;
    BuildLabelHeaderPanels;
    BuildSearchPanels;
    BuildDataPanels;
    BuildStringGrids;
    Result := True;
  except on E:Exception do
    begin
      Result := False;
      { #todo : Logging }
    end;
  end;
end;

procedure TBuildComponents.RemoveOwnComponents(aParent: Pointer);
var
  i : Integer;
  aControl : TWinControl;
  _panel1 : TPanel;
begin
  if aParent = nil then exit;

  aControl :=  TWinControl(aParent);

  // First remove the pointers to the item data.
  RemovePointerdata(aParent);

  // Remove the Panels. Because the panels are the parent of all child components, all childs are automatically deleted.
  for i := aControl.ControlCount-1 downto 0  do begin
    if aControl.Controls[i] is TPanel then begin
      _panel1 := TPanel(aControl.Controls[i]);
      if _panel1.Name.Contains('PanelBody_') then begin
        _panel1.Free;
      end;
    end
    else if aControl.Controls[i] is TSplitter then begin
      aControl.Controls[i].Free;
    end;
  end;
end;


end.


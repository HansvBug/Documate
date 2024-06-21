unit StringGridFabric;

{ This will have to be done completely again. All actions start with a change to Checkedparents and/or CheckedChilds. }

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, Grids;

Type

 PStringToLong = ^TStringToLong;
 TStringToLong = record
   sgName: String;
   Row : Integer;
   TextToLong: Boolean;
 end;

 PSgDuplicateText = ^TSgDuplicateText;
 TSgDuplicateText = record
   sgName: String;
   HasDuplicateText : Boolean;
 end;

 PCheckBoxCellPosition = ^TCheckBoxCellPosition;
 TCheckBoxCellPosition = record
   Col: Integer;
   Row: Integer;
   Level : Integer;   { #todo : Kan waarschijnlijk weg }
   Name : String;
   aGridPtr : Pointer;
   aGuid  : String;
   Parent_guid : Array of string;
   Action : String;
   CbIsChecked : Boolean;
   CbParentMultipleCheck : Boolean;
   MustSave : Boolean;  { #todo : Kan waarschijnlijk weg }
   Cansave : Boolean;   { #todo : Kan waarschijnlijk weg }
   Success : Boolean;
   AllSGrids : Pointer; { #todo : Kan waarschijnlijk weg }
   sgName : String;
   RowObject : Pointer;
 end;

 PItemList = ^TItemList;
 TItemList = record
   aGuid  : String;
   Parent_guid : Array of string;
   Action : String;
 end;

 PtrItemObject = ^TItemObjectData;
 TItemObjectData = record
   Id_table         : Integer;  // ID column database table ITEMS. NOT used
   Guid             : String;
   Level            : Integer;
   Name             : String;
   Parent_guid      : array of String;
   MemoNew          : String;
   MemoCurrent      : String;
   Action           : String;
   GridObject       : Pointer;
   sgCol,
   sgRow            : Integer;
   MustSave         : Boolean;
 end;
 AllItemsObjectData = array of TItemObjectData;

 PStringGridSelect = ^TStringGridSelect;
 TStringGridSelect = record
   aCol,
   aRow,
   aLevel : Integer;
   sgarray : Array of TObject;
   AllowCellSelectColor : Boolean;
   RectLeft,
   RectTop,
   RectRight,
   RectBottom : Integer;
   Guid: String;
   sgName : String;
 end;

 { TStringGridFab }

 TStringGridFab = class(TObject)
   private
     FACol: integer;
     FACow: integer;
     FARow: integer;
     FMultipleParentsChecked: Boolean;
     FMustSave: Boolean;
     FParentAndChildInOneSg: Boolean;
     FStringToLong : array of TStringToLong;
     FSgDuplicateText : array of TSgDuplicateText;
     FTextIsToLong: Boolean;
     FDupText : Boolean;
     CheckedParentCells: array of TCheckBoxCellPosition;
     CheckedChildCells: array of TCheckBoxCellPosition;
     ChildCellsOfSelection: array of TCheckBoxCellPosition;
     ClickedCell: array of TCheckBoxCellPosition;
     FSelectedItemGuid : String;

     function CheckCelllength(const aText: String): Boolean;
     function CheckCellEntrylength(anObj: TObject; ARow: Integer): Boolean;
     function HasColumnDuplicates(const sgObject: TObject): Boolean;
     function FoundAnyDuplicates(anObj: TObject): Boolean;
     procedure CheckForparentChildtogether;

     function DoesParentGuidExist(aGuid: string): Boolean;
     function DoesChildGuidExist(aGuid: string): Boolean;
     procedure AlterCheckedParents(cbToggled: Pointer);
     procedure UpdateSgObject(cbToggled: Pointer);
     procedure UpdateCheckedChild(cbToggled: Pointer);
     procedure RetrieveChilds(aParentGuid: String);
     procedure CheckChild(cbToggled: Pointer);
     procedure CheckChild;
     procedure AlterCheckedChilds(cbToggled: Pointer);
     procedure RemoveUnCheckedChildsFromSg(cbToggled: Pointer);
     procedure RemoveUnCheckedChildsFromList;
     procedure ResetCheckedParents;

     const
       { (p)arent (a)ction }
       //paDelete = 'Delete';
       paUnCheckParent = 'UnCheck parent';

       { (c)hild(a)ction }
       caInsert= 'Insert';
       caExisting = 'Existing';
       caExistingDelete = 'Existing Delete';
       caExistingUncheck = 'Existing Uncheck';

   public
     AllStringGrids : array of TStringGrid; // FOUT; later bekijken hoe dit anders kan.  wordt gebuikt bij toggle stringgrid
     SaveList : array of TItemList;
     DeleteList : array of TItemList;  // used when an item is deleted. This stored the relations which must be deleted.

     constructor Create; overload;
     destructor  Destroy; override;
     procedure ActivateStringGridCell(const sgObject: TObject; ViaAddButton: Boolean
       );
     procedure StringGridOnPrepareCanvas(const sgObject: TObject; const aCol,
       aRow: Integer; ShowRelationColor: Boolean);
     procedure StringGridOnSelectCell(Sender: TObject; sgSelect: Pointer);
     procedure StringGridOnDrawCell(Sender: TObject; sgSelect: Pointer);
     function ValidateCellEntry(sgObject: TObject; aText: string; ARow: Integer): Boolean;
     function ValidateDupText(sgObject: TObject): Boolean;

     procedure SetParent(cbToggled: Pointer);
     procedure SetChild(cbToggled: Pointer);

     procedure UnCheckChild(ParentGuid: String);
     function GetChildsToUncheck: AllItemsObjectData;
     procedure CleanUpCheckedParents;
     function CanSave : Boolean;
     procedure CheckForChanges;
     procedure ResetAll;
     procedure PrepareCloseDb;
     procedure PrepareSaveList;
     //procedure AddToDeleteList(aGuid: String);

     //procedure DebugCtrl;

     property ARow: integer read FARow write FARow;
     property ACol: integer read FACol write FACow;
     property MultipleParentsChecked : Boolean read FMultipleParentsChecked write FMultipleParentsChecked;
     property MustSave : Boolean read FMustSave write FMustSave;
     property ParentAndChildInOneSg : Boolean read FParentAndChildInOneSg write FParentAndChildInOneSg;
 end;

 const
   MaxTextLength= 1000;

implementation


{ TStringGridFab }

function TStringGridFab.CheckCellEntrylength(anObj: TObject; ARow: Integer
  ): Boolean;
var  { #todo : Almost the same procedure as: FoundAnyDuplicates }
  i : Integer;
  ToLong :Boolean;
  ItemExists: Boolean;
  gridname: String;
begin
  if FStringToLong = nil then begin
    setLength(FStringToLong, 0);
  end;

  ItemExists := False;
  ToLong := False;
  gridname := TStringGrid(anObj).Name;

  if FTextIsToLong then begin  // Add record when text is to long is true
    for i:= 0 to length(FStringToLong)-1 do begin
      if (FStringToLong[i].sgName = gridname) and (FStringToLong[i].Row = aRow) then begin
        ItemExists := True;
        break;
      end;
    end;

    if not ItemExists then
    begin
      setLength(FStringToLong, Length(FStringToLong) +1);
      FStringToLong[High(FStringToLong)].sgName := gridname;
      FStringToLong[High(FStringToLong)].Row := aRow;
      FStringToLong[High(FStringToLong)].TextToLong := FTextIsToLong;
    end;
  end
  else begin  // Delete record when text is to long is false
    if Length(FStringToLong) >= 1 then begin
      for i:= Length(FStringToLong)-1 downto 0 do begin
        if (FStringToLong[i].sgName = gridname) and
           (FStringToLong[i].TextToLong) and
           (FStringToLong[i].Row = aRow) then begin
          delete(FStringToLong,i,1);
          break;
        end;
      end;
    end;
  end;

  if FStringToLong = nil then begin
    ToLong := False;
  end
  else begin
    for i:= 0 to length(FStringToLong) -1 do begin
      if FStringToLong[i].TextToLong then begin
        ToLong := True;
        Break;
      end;
    end;
  end;

  Result := ToLong;
end;

constructor TStringGridFab.Create;
begin
  inherited Create;
  MultipleParentsChecked := False;
  //...
end;

destructor TStringGridFab.Destroy;
begin
  //...
  inherited Destroy;
end;

procedure TStringGridFab.ActivateStringGridCell(const sgObject: TObject; ViaAddButton : Boolean);
var
  _sg : TStringGrid;
  i: Integer;
begin
  if sgObject = nil then exit;

  _sg := TStringgrid(sgObject);
  _sg.BeginUpdate;

  i:= _sg.RowCount;

  // "uncheck" checkbox cells

  // Go to the new empty cell
  _sg.Row := _sg.RowCount-1;  // Selects the row
  _sg.Col := 3;

  if ViaAddButton then begin
    _sg.Cells[1,_sg.RowCount-1] := '0';
    _sg.Cells[2,_sg.RowCount-1] := '0';
  end
  else begin  // Arrow key
    _sg.Cells[1,_sg.RowCount] := '0';
    _sg.Cells[2,_sg.RowCount] := '0';
  end;

  // show the cursor in the newly added cell.
  _sg.SetFocus;
  _sg.EditorMode:=true;
  _sg.EndUpdate(true);
end;

procedure TStringGridFab.StringGridOnPrepareCanvas(const sgObject: TObject;
  const aCol, aRow: Integer; ShowRelationColor: Boolean);
var
  _sg : TStringGrid;
  i, r, counter: Integer;
  s: string;
begin
  if sgObject = nil then exit;

  _sg := TStringgrid(sgObject);

  // Duplicate text, then then warning color
  for i := 0 to _sg.RowCount-1 do begin
   if (i <> aRow) and (_sg.Cells[3, aRow] <> '') then begin
     if _sg.Cells[3, i] = _sg.Cells[3, aRow] then begin
       _sg.Canvas.Brush.Color := clRed;  { #todo : User should be able to select a color,  make an option }
       Break;
     end;
   end;
  end;


  // Check entry length (max 1000)
  if length(_sg.Cells[aCol, aRow]) > MaxTextLength then begin
    _sg.Canvas.Brush.Color := clFuchsia;
  end;

  // Parent color
  s := _sg.Cells[aCol, aRow];
  if (s = '1') and (aCol = 1) then begin
    if not MultipleParentsChecked then
      _sg.Canvas.Brush.Color := clGreen { #todo : User should be able to select a color,  make an option }
    else
      _sg.Canvas.Brush.Color := clRed;
  end;

  // Child color
  s := _sg.Cells[aCol, aRow];
  if (s = '1') and (aCol = 2) then begin
    _sg.Canvas.Brush.Color := clLime; { #todo : User should be able to select a color,  make an option }
  end;

  // one or more child(s) selected and then a parent in the same lavel is checked (= is wrong)
  if ParentAndChildInOneSg then begin
    counter := 0;
    s := _sg.Cells[aCol, aRow];
    if (s = '1') and (aCol = 1) then begin
      for i := 0 to _sg.RowCount-1 do begin
          if _sg.Cells[2, i] = '1' then begin
            inc(Counter);
          end;
      end;
      if Counter >= 1 then begin
        _sg.Canvas.Brush.Color := clFuchsia;
      end;
    end;
  end;

  // Color the child records
  if ShowRelationColor then begin
    for r := 0 to _sg.Row-1 do begin
      for i := Length(ChildCellsOfSelection)-1 downto 0 do begin
        if (ChildCellsOfSelection <> nil) and (TStringGrid(ChildCellsOfSelection[i].aGridPtr) = _sg) then begin
          if (ChildCellsOfSelection[i].Row = aRow) and (ChildCellsOfSelection[i].Col = aCol) then begin
            _sg.Canvas.Brush.Color := clAqua;
            break;
          end;
        end;
      end;
    end;
  end;
end;

procedure TStringGridFab.StringGridOnSelectCell(Sender: TObject;
  sgSelect: Pointer);
var
  _stringGrid : TStringgrid;
  lRec : TStringGridSelect;
  pItem : PtrItemObject;
  i, j, r, c, counter : Integer;
  Parent_Guids : array of string;
begin
  _stringGrid := TStringgrid(sender);

  lRec := TStringGridSelect(PStringGridSelect(sgSelect)^);

  // Get the selected cell, gets a different color then de relation color
  SetLength(ClickedCell, 1);
  ClickedCell[0].Col := lRec.aCol;
  ClickedCell[0].Row := lRec.aRow;
  ClickedCell[0].aGridPtr := _stringGrid;
  if PtrItemObject(_stringGrid.Objects[lRec.acol, lRec.aRow]) <> nil then begin
    pItem := PtrItemObject(_stringGrid.Objects[lRec.aCol, lRec.aRow]);
    ClickedCell[0].aGuid := pItem^.Guid;
  end;
  ClickedCell[0].Name := _stringGrid.Cells[lRec.aCol, lRec.aRow];
  ClickedCell[0].Level := lRec.aLevel;
  ClickedCell[0].sgName := _stringGrid.Name;

  if Lrec.AllowCellSelectColor then begin
   // FAllowCellSelectColor := True;
    if lRec.aCol = 3 then begin
      Parent_Guids := pItem^.Parent_guid;
      FSelectedItemGuid := pItem^.Guid;

      // Mark all related cells to the right of the selected cell
      //ChildCellsOfSelection

      counter := 0;
      SetLength(ChildCellsOfSelection, counter);

      for i := 0 to Length(lrec.sgarray)-1 do begin
        for r := 0 to TStringGrid(lrec.sgarray[i]).RowCount-1 do begin
          for c := 0 to TStringGrid(lrec.sgarray[i]).ColCount-1 do begin
            pItem := PtrItemObject(TStringGrid(lrec.sgarray[i]).Objects[c,r]);
            if (pItem <> Nil) and (pItem^.Parent_guid <> nil) then begin
              for j := 0 to Length(pItem^.Parent_guid)-1 do begin
                if pItem^.Parent_guid[j] = FSelectedItemGuid then begin
                  Setlength(ChildCellsOfSelection, Length(ChildCellsOfSelection)+1);

                  ChildCellsOfSelection[counter].aGridPtr := TStringGrid(lrec.sgarray[i]);
                  ChildCellsOfSelection[counter].Col := c;
                  ChildCellsOfSelection[counter].Row := r;

                  Inc(counter);
                end;
              end;
            end;
          end;
        end;
      end;

    //Mark related cells to the left of the selected cell
      for i := Length(lrec.sgarray) - ClickedCell[0].Level downto 0 do begin
        for r := 0 to TStringGrid(lrec.sgarray[i]).RowCount-1 do begin
          for c := 0 to TStringGrid(lrec.sgarray[i]).ColCount - 1 do begin
            pItem := PtrItemObject(TStringGrid(lrec.sgarray[i]).Objects[c,r]);
            if pItem <> Nil then begin
              for j := 0 to Length(Parent_Guids)-1 do begin
                if Parent_Guids[j] = pItem^.Guid then begin
                  Setlength(ChildCellsOfSelection, Length(ChildCellsOfSelection)+1);
                  ChildCellsOfSelection[counter].aGridPtr := TStringGrid(lrec.sgarray[i]);
                  ChildCellsOfSelection[counter].Col := c;
                  ChildCellsOfSelection[counter].Row := r;
                  Inc(counter);
                end;
              end;
            end;
          end;
        end;
      end;


    end;
  end
  else begin
    ChildCellsOfSelection := nil;
  end;

  // Color the related cells


  for i := 0 to Length(lrec.sgarray)-1 do begin
    if lrec.sgarray[i] = sender then begin
      lrec.sgarray[i] := sender;  // is gewijzigd na een het verwijderenvan 1 rij. repaint werkt dan niet. aalntl rijen in lrec.sgarray[i] is niet meer de werkelijkheid
    end
    else begin
      TStringGrid(lrec.sgarray[i]).Repaint;  // trigger onpreparecanvas
    end;
  end;
end;

procedure TStringGridFab.StringGridOnDrawCell(Sender: TObject; sgSelect: Pointer
  );
var
  lRec : TStringGridSelect;
  _stringGrid : TStringgrid;
  aRect : TRect;
begin
  // Color the selected cell
  lRec := TStringGridSelect(PStringGridSelect(sgSelect)^);
  _stringGrid := TStringgrid(sender);

  aRect.Left := lRec.RectLeft;
  aRect.Top := lRec.RectTop;
  aRect.Right := lRec.RectRight;
  aRect.Bottom := lRec.RectBottom;

  if lRec.sgName = _stringGrid.Name then begin
    if lRec.Guid = ClickedCell[0].aGuid then begin
      if (lRec.aCol = ClickedCell[0].Col) and (lRec.aRow = ClickedCell[0].Row) and (lRec.sgName = ClickedCell[0].sgName) then begin
        if lRec.AllowCellSelectColor then begin
          _stringGrid.Canvas.Brush.Color := clTeal;
          _stringGrid.Canvas.Font.Color := clLime;
        end
        else begin
          _stringGrid.Canvas.Brush.Color := clWhite;
          _stringGrid.Canvas.Font.Color := clBlack;
        end;
        _stringGrid.Canvas.FillRect( aRect );
        _stringGrid.Canvas.TextRect( aRect, aRect.Left+2, aRect.Top+2, _stringGrid.Cells[lRec.aCol, lRec.aRow]);
      end;
    end;
  end;
end;

function TStringGridFab.HasColumnDuplicates(const sgObject: TObject): Boolean;
var
  _sg : TStringGrid;
  sl: TStringList;
  i, Counter: Integer;
begin
  { #todo : De stringlist kan lang worden. Wellicht is het beter om deze functie te vervangen door één functie die het antal voorkomens van 1 teskt opzoekt/telt. }
  if sgObject = nil then exit;
  _sg := TStringgrid(sgObject);
  Counter := 0;

  sl:= TStringList.Create;
  sl.Sorted := True;
  sl.Duplicates := dupIgnore;

  for i:=1 to _sg.RowCount-1 do begin
    if _sg.Cells[3,i] <> '' then begin  // Alleen gevulde regels toevoegen aan de stringlist. (de eventueel laatste lege regel overslaan).
      sl.Add(_sg.Cells[3,i]);
      Inc(Counter);
    end;
  end;

  //if _sg.RowCount-1 = sl.Count then begin
  if Counter = sl.Count then begin
    Result := False;
  end
  else begin
    Result := true;
  end;

  sl.Free;
end;

function TStringGridFab.FoundAnyDuplicates(anObj: TObject): Boolean;
var  { #todo : Almost the same procedure as: CheckCellEntrylength }
  i : Integer;
  Duplicate :Boolean;
  gridname: String;
begin
  if FSgDuplicateText = nil then begin
    setLength(FSgDuplicateText, 0);
  end;

  Duplicate := False;
  gridname := TStringGrid(anObj).Name;

  if FDupText then begin  // Add record when text is to long is true
    setLength(FSgDuplicateText, Length(FSgDuplicateText) +1);
    FSgDuplicateText[High(FSgDuplicateText)].sgName := gridname;
    FSgDuplicateText[High(FSgDuplicateText)].HasDuplicateText := FDupText;
  end
  else begin  // Delete all record of a stringgrid when found duplicates witin 1 stringgrid is false.
    if Length(FSgDuplicateText) >= 1 then begin
      for i:= Length(FSgDuplicateText)-1 downto 0 do begin
        if (FSgDuplicateText[i].sgName = gridname) and (FSgDuplicateText[i].HasDuplicateText) then begin
          delete(FSgDuplicateText,i,1);
        end;
      end;
    end;
  end;

  if FSgDuplicateText = nil then begin
    Duplicate := False;
  end
  else begin
    for i:= 0 to length(FSgDuplicateText) -1 do begin
      if FSgDuplicateText[i].HasDuplicateText then begin
        Duplicate := True;
        Break;
      end;
    end;
  end;




  Result := Duplicate;
end;

procedure TStringGridFab.CheckForparentChildtogether;
var
  iP, iC : Integer;
begin
  ParentAndChildInOneSg := False;

  for iP:=0 to Length(CheckedParentCells)-1 do begin
    for iC:=0 to length(CheckedChildCells)-1 do begin
      if (CheckedParentCells[iP].sgName = CheckedChildCells[iC].sgName) and
         (CheckedParentCells[iP].sgName <> '') and (CheckedChildCells[iC].sgName <> '') then begin
        ParentAndChildInOneSg := True;
        break;
      end;
    end;
  end;
end;

function TStringGridFab.DoesParentGuidExist(aGuid: string): Boolean;
var
  i : Integer;
begin
  if (CheckedParentCells = nil) or (length(CheckedParentCells) = 0) Then
    Result := False
  else begin
    Result := False;
    for i:=0 to length(CheckedParentCells)-1 do begin
      if aGuid = CheckedParentCells[i].aGuid then begin
        Result := True;
        break;
      end;
    end;
  end;
end;

function TStringGridFab.DoesChildGuidExist(aGuid: string): Boolean;
var
  i : Integer;
begin
  if (CheckedChildCells = nil) or (length(CheckedChildCells) = 0) Then
    Result := False
  else begin
    Result := False;
    for i:=0 to length(CheckedChildCells)-1 do begin
      if aGuid = CheckedChildCells[i].aGuid then begin
        Result := True;
        break;
      end;
    end;
  end;
end;

procedure TStringGridFab.AlterCheckedParents(cbToggled: Pointer);
var
  i: Integer;
begin
  // Organize the checked parent cells
  // parent is checked
  if (PCheckBoxCellPosition(cbToggled)^.Col = 1) and (PCheckBoxCellPosition(cbToggled)^.CbIsChecked) then begin
    if CheckedParentCells = Nil Then
      Setlength(CheckedParentCells, 0);

    if not DoesParentGuidExist(PCheckBoxCellPosition(cbToggled)^.aGuid) then begin
      Setlength(CheckedParentCells, Length(CheckedParentCells)+1);
      CheckedParentCells[Length(CheckedParentCells)-1].aGuid := PCheckBoxCellPosition(cbToggled)^.aGuid;
      CheckedParentCells[Length(CheckedParentCells)-1].aGridPtr := PCheckBoxCellPosition(cbToggled)^.aGridPtr;
      CheckedParentCells[Length(CheckedParentCells)-1].sgName := TStringgrid(PCheckBoxCellPosition(cbToggled)^.aGridPtr).Name; // makkelijker leesbaar als gecontroleerd wordt in wlke grid de parent zit dan de pointer
    end;
  end
  // uncheck a parent
  else if (PCheckBoxCellPosition(cbToggled)^.Col = 1) and (not PCheckBoxCellPosition(cbToggled)^.CbIsChecked) then begin
    if DoesParentGuidExist(PCheckBoxCellPosition(cbToggled)^.aGuid) then begin
      for i:= Length(CheckedParentCells)-1 downto 0 do begin
        if CheckedParentCells[i].aGuid = PCheckBoxCellPosition(cbToggled)^.aGuid then begin
          CheckedParentCells[i].Action := paUnCheckParent;
          //Delete(CheckedParentCells,i,1);
        end;
      end;
    end
    else begin
      { #todo : Insert a warning message }
      // something went wrong. parent guid doesnt exist anymore.
    end;
  end;
end;

procedure TStringGridFab.UpdateSgObject(cbToggled: Pointer);
var
  PGuid : String;
  i, j, c, r: Integer;
  Pobj :  PtrItemObject;
begin
  if (PCheckBoxCellPosition(cbToggled)^.Col = 1) and (not PCheckBoxCellPosition(cbToggled)^.CbIsChecked) then begin
    pGuid := PCheckBoxCellPosition(cbToggled)^.aGuid;

    for i:=0 to length(AllStringGrids)-1 do begin
      for r:=0 to AllStringGrids[i].RowCount -1 do begin
        for c:=0 to AllStringGrids[i].ColCount -1 do begin
          if PtrItemObject(TstringGrid(AllStringGrids[i]).Objects[c,r]) <> nil then begin
            Pobj :=  PtrItemObject(TstringGrid(AllStringGrids[i]).Objects[c,r]);
            for j:= length(Pobj^.Parent_guid)-1 downto 0 do begin
              if Pobj^.Parent_guid[j] = PGuid then begin
                AllStringGrids[i].Cells[2,r] := '0'; // uncheck
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TStringGridFab.UpdateCheckedChild(cbToggled: Pointer);
var
  PGuid : String;
  i: Integer;
begin
  // if parent = unchecked then maintain the checkedchild list
  if (PCheckBoxCellPosition(cbToggled)^.Col = 1) and (not PCheckBoxCellPosition(cbToggled)^.CbIsChecked) then begin
    pGuid := PCheckBoxCellPosition(cbToggled)^.aGuid;
    for i:= length(CheckedChildCells)-1 downto 0 do begin
      if CheckedChildCells[i].Parent_guid[0] = pGuid then begin

        if CheckedChildCells[i].Action = caInsert then begin
          Delete(CheckedChildCells, i, 1); // delete is een checked cell nadat de oorspronkelijke childs behorende bij een aangevinkte paren al zijn ingelezen kan dus direct weer weg uit de lijst.
        end
        else if CheckedChildCells[i].Action = caExisting then begin
          // an existing unchanged child then remove from the list
          CheckedChildCells[i].Action := caExistingUncheck;  // moet dit niet existing uncheck worden?
        end;

      end;
    end;
  end;
end;

procedure TStringGridFab.RetrieveChilds(aParentGuid: String);
var
  i,j, c,r, counter : Integer;
  Pobj :  PtrItemObject;
begin
  Counter := Length(CheckedChildCells);
  for i:= 0 to length(AllStringGrids)-1 do begin
    for r:=0 to AllStringGrids[i].RowCount -1 do begin
      for c:=0 to AllStringGrids[i].ColCount -1 do begin
        // haal de parent guid uit het object
        if PtrItemObject(TstringGrid(AllStringGrids[i]).Objects[c,r]) <> nil then begin
          Pobj :=  PtrItemObject(TstringGrid(AllStringGrids[i]).Objects[c,r]);
          if length(Pobj^.Parent_guid) > 0 then begin

            for j:= 0 to length(Pobj^.Parent_guid)-1 do begin
              if Pobj^.Parent_guid[j] = aParentGuid then begin
                Setlength(CheckedChildCells, Counter+1);
                CheckedChildCells[Counter].aGuid := Pobj^.Guid;
                if Pobj^.Action = 'Read' then begin
                  CheckedChildCells[Counter].Action := caExisting;
                end
                else begin
                  CheckedChildCells[Counter].Action := Pobj^.Action;
                end;

                //CheckedChildCells[Counter].Row := Pobj^.sgRow;
                Setlength(CheckedChildCells[Counter].Parent_guid, 1);
                CheckedChildCells[Counter].Parent_guid[0] := Pobj^.Parent_guid[j];
                CheckedChildCells[Counter].aGridPtr := AllStringGrids[i];
                Inc(Counter);
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TStringGridFab.CheckChild(cbToggled: Pointer);
var
  i, j, c,r : Integer;
  pItem : PtrItemObject;
  PGuid : string;
  _sg: TStringGrid;
begin
  if CheckedChildCells = nil then begin
    for i:=0 to length(AllStringGrids)-1 do begin
      for r:=0 to AllStringGrids[i].RowCount-1 do begin
        AllStringGrids[i].Cells[2,r] := '0';
      end;
    end;

    exit;
  end;

  if PCheckBoxCellPosition(cbToggled)^.CbIsChecked then begin

    for i:=0 to length(CheckedChildCells)-1 do begin
  //    if (CheckedChildCells[i].Action <> caRemove) and
  //       (CheckedChildCells[i].Action <> caExistingDelete) then begin
        _sg := TStringGrid(CheckedChildCells[i].aGridPtr);
        for j:=0 to length(AllStringGrids)-1 do begin
          if AllStringGrids[j] = _sg then begin
            for r:=0 to _sg.RowCount-1 do begin
              for c:=0 to _sg.ColCount -1 do begin
                if PtrItemObject(_sg.Objects[c,r]) <> nil then begin
                  pItem := PtrItemObject(_sg.Objects[c,r]);

                  if CheckedChildCells[i].aGuid = PtrItemObject(_sg.Objects[c,r])^.Guid then begin
                    if (CheckedChildCells[i].Action <> caExistingDelete) and (CheckedChildCells[i].Action <> caExistingUncheck) then begin
                      AllStringGrids[j].Cells[c-1,r] := '1';

                    end;
                  end;
                end;
              end;
            end;
          end;
        end;
    end;

  end
  else begin
    PGuid := PCheckBoxCellPosition(cbToggled)^.aGuid;
    for i:=0 to length(CheckedChildCells)-1 do begin
      _sg := TStringGrid(CheckedChildCells[i].aGridPtr);
      for j:=0 to length(AllStringGrids)-1 do begin
        if AllStringGrids[j] = _sg then begin
          for r:=0 to _sg.RowCount-1 do begin
            for c:=0 to _sg.ColCount -1 do begin
              if PtrItemObject(_sg.Objects[c,r]) <> nil then begin
                pItem := PtrItemObject(_sg.Objects[c,r]);
                if PGuid = CheckedChildCells[i].Parent_guid[0] then begin
                  if CheckedChildCells[i].aGuid = pItem^.Guid then begin
                    AllStringGrids[j].Cells[c-1,r] := '0';
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

procedure TStringGridFab.CheckChild;
var
  i,j, c,r : Integer;
  _sg: TStringGrid;
begin

  for i:=0 to length(CheckedChildCells)-1 do begin
//    if (CheckedChildCells[i].Action <> caRemove) and
//       (CheckedChildCells[i].Action <> caExistingDelete) then begin
      _sg := TStringGrid(CheckedChildCells[i].aGridPtr);
      for j:=0 to length(AllStringGrids)-1 do begin
        if AllStringGrids[j] = _sg then begin
          for r:=0 to _sg.RowCount-1 do begin
            for c:=0 to _sg.ColCount -1 do begin
              if PtrItemObject(_sg.Objects[c,r]) <> nil then begin

                if CheckedChildCells[i].aGuid = PtrItemObject(_sg.Objects[c,r])^.Guid then begin
                  if (CheckedChildCells[i].Action <> caExistingDelete) and (CheckedChildCells[i].Action <> caExistingUncheck) then begin
                    AllStringGrids[j].Cells[c-1,r] := '1';

                  end;
                end;
              end;
            end;
          end;
        end;
      end;
  end;
end;

procedure TStringGridFab.AlterCheckedChilds(cbToggled: Pointer);
var
  i, j: Integer;
  pCbPos : PCheckBoxCellPosition;
begin
  pCbPos := PCheckBoxCellPosition(cbToggled);

  if (PCheckBoxCellPosition(cbToggled)^.Col = 2) and (PCheckBoxCellPosition(cbToggled)^.CbIsChecked) then begin
    if CheckedChildCells = Nil Then
      Setlength(CheckedChildCells, 0);

    // add child to the array
    if not DoesChildGuidExist(PCheckBoxCellPosition(cbToggled)^.aGuid) then begin
      for i:= 0 to length(CheckedParentCells)-1 do begin
        Setlength(CheckedChildCells, Length(CheckedChildCells)+1);
        CheckedChildCells[Length(CheckedChildCells)-1].aGuid := PCheckBoxCellPosition(cbToggled)^.aGuid;
        CheckedChildCells[Length(CheckedChildCells)-1].Action := caInsert;
        Setlength(CheckedChildCells[Length(CheckedChildCells)-1].Parent_guid, 1);
        CheckedChildCells[Length(CheckedChildCells)-1].Parent_guid[0] := CheckedParentCells[i].aGuid;
        // add to sgObject
        setlength(PtrItemObject(pCbPos^.RowObject)^.Parent_guid , Length(PtrItemObject(pCbPos^.RowObject)^.Parent_guid)+1);
        PtrItemObject(pCbPos^.RowObject)^.Parent_guid[Length(PtrItemObject(pCbPos^.RowObject)^.Parent_guid)-1] := CheckedParentCells[i].aGuid;
        PtrItemObject(pCbPos^.RowObject)^.Action := caInsert;

        CheckedChildCells[Length(CheckedChildCells)-1].sgName := TStringGrid(pCbPos^.aGridPtr).Name; // used in CheckForparentChildtogether
      end;
    end
    else begin
      // child is in the array....
    end;
  end
  else if (PCheckBoxCellPosition(cbToggled)^.Col = 2) and (not PCheckBoxCellPosition(cbToggled)^.CbIsChecked) then begin
    if DoesChildGuidExist(PCheckBoxCellPosition(cbToggled)^.aGuid) then begin

      for i:= Length(CheckedChildCells)-1 downto 0 do begin
        if CheckedChildCells[i].aGuid = PCheckBoxCellPosition(cbToggled)^.aGuid then begin
          if CheckedChildCells[i].Action = caInsert then begin
            //sg object actie moet dan terug naar read
            pCbPos := PCheckBoxCellPosition(cbToggled);


             setlength(PtrItemObject(pCbPos^.RowObject)^.Parent_guid , Length(PtrItemObject(pCbPos^.RowObject)^.Parent_guid)+1);
            for j:= length(PtrItemObject(pCbPos^.RowObject)^.Parent_guid)-1 downto 0 do begin
              if PtrItemObject(pCbPos^.RowObject)^.Parent_guid[j] = CheckedChildCells[i].Parent_guid[0] then begin
                Delete(PtrItemObject(pCbPos^.RowObject)^.Parent_guid,j,1);
              end;
            end;

            PtrItemObject(pCbPos^.RowObject)^.Action := 'Read';

            Delete(CheckedChildCells, i, 1); // insert is een checked cell nadat de oorspronkelijke childs behorende bij een aangevinkte paren al zijn ingelezen kan dus direct weer weg uit de lijst.
            break;
          end
          else if CheckedChildCells[i].Action = caExisting then begin
            CheckedChildCells[i].Action := caExistingDelete;
            break;
          end;
        end;
      end;

    end
    else begin
      { #todo : Insert a warning message }
      // something went wrong. child guid doesnt exist anymore.
    end;
  end;
end;

procedure TStringGridFab.CleanUpCheckedParents;
var
  i,j, r : Integer;
begin
  if Length(CheckedParentCells) >0 then begin
    for i:= length(CheckedParentCells)-1 downto 0 do begin
      if CheckedParentCells[i].Action = paUnCheckParent then begin
        for j:= length(CheckedChildCells)-1 downto 0 do begin
          if CheckedParentCells[i].aGuid = CheckedChildCells[j].Parent_guid[0] then
            Delete(CheckedChildCells, j, 1);
        end;
        delete(CheckedParentCells, i, 1);
      end;
    end;
  end
  else begin
    SetLength(CheckedChildCells, 0);

    for i:=0 to Length(AllStringGrids)-1 do begin
      for r:=0 to AllStringGrids[i].RowCount -1 do begin
        AllStringGrids[i].Cells[2,r] := '0';
      end;
    end;
  end;
end;

function TStringGridFab.CanSave: Boolean;
begin
  CheckForChanges;

  if (length(CheckedChildCells) > 0) and (length(CheckedParentCells)=1) then
    Result := True
  else
    Result := False;
end;

procedure TStringGridFab.CheckForChanges;
var
  i : Integer;
begin
  for i:=0 to length(CheckedChildCells)-1 do begin
    if (CheckedChildCells[i].Action = caInsert) or (CheckedChildCells[i].Action = caExistingDelete) then
      MustSave := True
    else
      MustSave := False;
  end;
end;

procedure TStringGridFab.ResetAll;
var
  i, r  : Integer;
begin
  SetLength(CheckedParentCells, 0);
  SetLength(CheckedChildCells, 0);

  for i:=0 to Length(AllStringGrids)-1 do begin
    for r:=0 to AllStringGrids[i].RowCount-1 do begin
      AllStringGrids[i].Cells[1,r] := '0';
      AllStringGrids[i].Cells[2,r] := '0';
    end;
  end;
end;

procedure TStringGridFab.PrepareCloseDb;
begin
  SetLength(CheckedParentCells, 0);
  SetLength(CheckedChildCells, 0);
  SetLength(AllStringGrids, 0);
end;

procedure TStringGridFab.PrepareSaveList;
var
  i, Counter: Integer;
begin
  SetLength(SaveList, 0);
  Counter :=1;
  for i:= 0 to length(CheckedChildCells)-1 do begin
    if (CheckedChildCells[i].Action = caInsert) or (CheckedChildCells[i].Action = caExistingDelete) then begin
      setlength(SaveList, Counter);
      SaveList[Counter-1].aGuid := CheckedChildCells[i].aGuid;
      SaveList[Counter-1].Parent_guid := CheckedChildCells[i].Parent_guid;
      SaveList[Counter-1].Action := CheckedChildCells[i].Action;
      Inc(Counter);
    end;
  end;
end;

{procedure TStringGridFab.AddToDeleteList(aGuid: String);
var
  i,j, c,r : Integer;
  pItem : PtrItemObject;
  tmp: string;
begin
  if DeleteList = nil then
    setlength(DeleteList, 0);

  for i:=0 to Length(AllStringGrids)-1 do begin
    for r:=0 to AllStringGrids[i].RowCount -1 do begin
      for c:=0 to AllStringGrids[i].ColCount -1 do begin
        pItem := PtrItemObject(AllStringGrids[i].Objects[c,r]);
        if pItem <> nil then begin
          if pItem^.Guid = aGuid then begin
            setlength(DeleteList, Length(DeleteList)+1);
            DeleteList[Length(DeleteList)-1].aGuid := pItem^.Guid;
             DeleteList[Length(DeleteList)-1].Action := 'Delete';
         end;



        end;
      end;
    end;
  end;
  tmp:='';
end;}

procedure TStringGridFab.RemoveUnCheckedChildsFromSg(cbToggled: Pointer);
var
  i,j,k, c, r : Integer;
  pItem : PtrItemObject;
  PGuid : String;
  tmpCounter : Integer;
begin
  tmpCounter := 1;
  PGuid := PCheckBoxCellPosition(cbToggled)^.aGuid;  // the unchecked cell

  { #todo : Kan versnelt worden door level te gaan gebruiken. Nu wordt van elke stringgrid elke rij en kolom bekeken }
  for i:=0 to length(AllStringGrids)-1 do begin
    for r:=0 to AllStringGrids[i].RowCount-1 do begin
      for c:=0 to AllStringGrids[i].ColCount -1 do begin
        pItem := PtrItemObject(AllStringGrids[i].Objects[c,r]);
        if pItem <> nil then begin
          if pItem^.Guid = PGuid then begin
            for k:= length(pItem^.Parent_guid)-1 downto 0 do begin
              for j:=0 to Length(CheckedChildCells)-1 do begin
                if CheckedChildCells[j].Parent_guid[0] = pItem^.Parent_guid[k] then begin
                  if CheckedChildCells[j].Action = caExistingDelete then begin
                    Delete(pItem^.Parent_guid, k, 1);
                    CheckedChildCells[j].Name := '???_' + IntToStr(tmpCounter);
                    Inc(tmpCounter);
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

procedure TStringGridFab.RemoveUnCheckedChildsFromList;
var
  i : Integer;
begin
  for i:=length(CheckedChildCells)-1 downto 0 do begin
    if CheckedChildCells[i].Action = caExistingUncheck then begin
      Delete(CheckedChildCells,i,1);
    end;
  end;
end;

procedure TStringGridFab.ResetCheckedParents;
var
  i,c,r : Integer;
  PGuid : string;
  Pobj :  PtrItemObject;
begin
  // check a parent, chack a new child, check an other parent, uncheck this last parent. The extra checked child must stay checked. (that does this procedure)
  for i:=0 to length(AllStringGrids)-1 do begin
    for r:=0 to AllStringGrids[i].RowCount-1 do begin
      if AllStringGrids[i].Cells[1,r] = '1' then begin
        for c:=0 to AllStringGrids[i].ColCount -1 do begin
          Pobj := PtrItemObject(TstringGrid(AllStringGrids[i]).Objects[c,r]);
          if Pobj <> nil then begin
            PGuid := Pobj^.Guid;
          end;
        end;
      end;
    end;
  end;

  RetrieveChilds(PGuid);
  CheckChild;
end;

function TStringGridFab.CheckCelllength(const aText: String): Boolean; //inline;
begin
  if length(aText) < MaxTextLength then
    Result := False
  else
    Result := True;
end;

function TStringGridFab.ValidateCellEntry(sgObject: TObject; aText: string; ARow: Integer): Boolean;
begin
  FTextIsToLong := CheckCelllength(aText);
  Result := CheckCellEntrylength(sgObject, ARow);
end;

function TStringGridFab.ValidateDupText(sgObject: TObject): Boolean;
begin
  FDupText := HasColumnDuplicates(sgObject);
  Result :=  FoundAnyDuplicates(sgObject);
end;

procedure TStringGridFab.SetParent(cbToggled: Pointer);
begin
  AlterCheckedParents(cbToggled);  // Add or flag the parent cell in the checkedparentcells array.
  UpdateSgObject(cbToggled);  // update the stringgrid object
  UpdateCheckedChild(cbToggled); // remove childs of unchecked parents

  if PCheckBoxCellPosition(cbToggled)^.CbIsChecked Then begin
    RetrieveChilds(PCheckBoxCellPosition(cbToggled)^.aGuid);
  end;

  CheckChild(cbToggled);
  if not PCheckBoxCellPosition(cbToggled)^.CbIsChecked Then begin
    ResetCheckedParents; // set the childs of a remaining checked parent
  end;

  CleanUpCheckedParents;

  if Length(CheckedParentCells) <= 1 then
    MultipleParentsChecked := False
  else if Length(CheckedParentCells) > 1 then
    MultipleParentsChecked := true;
end;

procedure TStringGridFab.SetChild(cbToggled: Pointer);
begin
  AlterCheckedChilds(cbToggled);
  RemoveUnCheckedChildsFromSg(cbToggled); // Remove unchecked childs from the sg object
  RemoveUnCheckedChildsFromList;
  CheckForparentChildtogether;
end;

procedure TStringGridFab.UnCheckChild(ParentGuid: String);
var
  i, j, c,r : Integer;
  Pobj :  PtrItemObject;
begin
  for i:=0 to length(AllStringGrids)-1 do begin
    for r:=0 to AllStringGrids[i].RowCount-1 do begin
      for c:=0 to AllStringGrids[i].ColCount -1 do begin
        Pobj := PtrItemObject(TstringGrid(AllStringGrids[i]).Objects[c,r]);
        if Pobj <> nil then begin
          if Pobj^.Parent_guid <> nil then begin
            for j:= length(Pobj^.Parent_guid)-1 downto 0 do begin
              if (Pobj^.Parent_guid[j] = ParentGuid) and (Pobj^.action ='Insert') Then begin
                delete(Pobj^.Parent_guid, j, 1);

                TstringGrid(AllStringGrids[i]).Objects[c,r] :=  TObject(Pobj);
                AllStringGrids[i].Cells[c-1,r] := '0';
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

{procedure TStringGridFab.AlterParentGuid(SelectedChilds: Pointer);
var
  c,r, i, j,k,  p: Integer;
  _sg: TStringgrid;
  Pobj :  PtrItemObject;
begin
  for i:=0 to length(AllItemsObjectData(SelectedChilds))-1 do begin
    _sg := TStringGrid(AllItemsObjectData(SelectedChilds)[i].GridObject);
    for j:=0 to length(AllStringGrids)-1 do begin
      if AllStringGrids[j] = _sg then begin
        for r:=0 to _sg.RowCount-1 do begin
          for c:=0 to _sg.ColCount -1 do begin
            Pobj :=  PtrItemObject(TstringGrid(AllStringGrids[i]).Objects[c,r]);
            if Pobj <> nil then begin
              for k:=0 to Length(AllItemsObjectData(SelectedChilds))-1 do begin
                setLength(Pobj^.Parent_guid, Length(Pobj^.Parent_guid)+1);

                if AllItemsObjectData(SelectedChilds)[k].Parent_guid[0] <> '' then begin
                  if AllItemsObjectData(SelectedChilds)[k].Action = CheckedChild then
                    Pobj^.Parent_guid[ Length(Pobj^.Parent_guid)-1 ] := AllItemsObjectData(SelectedChilds)[k].Parent_guid[0]
                  else // uncheck
                    for p:= length(Pobj^.Parent_guid)-1 downto 0 do begin
                      if Pobj^.Parent_guid[p] = AllItemsObjectData(SelectedChilds)[k].Parent_guid[0] then
                        delete(Pobj^.Parent_guid,i,1);
                    end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end; }

function TStringGridFab.GetChildsToUncheck: AllItemsObjectData;
var
  i: Integer;
  iod : AllItemsObjectData = nil;
begin
  for i:= 0 to Length(CheckedChildCells)-1 do begin
    setlength(iod, Length(iod)+1);
    iod[Length(iod)-1].Guid := CheckedChildCells[i].aGuid;
    iod[Length(iod)-1].Action := CheckedChildCells[i].Action;
  end;
  Result :=  iod;
end;

{
procedure TStringGridFab.DebugCtrl;
var
  i : Integer;
  tmp: string;
begin
  i:= Length(CheckedChildCells);
  tmp := '';
end;
}


end.



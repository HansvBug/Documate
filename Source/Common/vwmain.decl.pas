unit vwmain.decl;

{$mode ObjFPC}{$H+}

interface

uses
  classes, sysUtils,
  obs_prosu, vwmain.types,
  AppDbCreate, AppDbOpen, BuildComponents, AppDbMaintainItems, StringGridFabric;

  const
  Application_name = 'Documate';
  Application_version = '0.3.0.0';
  Application_buildddate = '05-04-2024';
  Application_databaseVersion = '1';

  { string guids for interfaces used in project }
  SGUIDIView = '{36FA1780-2BB3-4207-99E5-0961BA75B7B0}';
  SGUIDIPresenter = '{48C70B90-A10A-4691-B8E8-JL6JFF35B7DD}';
  SGUIDITransactionManager = '{259E7374-453B-4829-B4D3-41EF99517B76}';
  SGUIDISettings = '{89E73826-E4FF-401B-AA13-2D58A6455D07}';
  SGUIDILogging = '{00DEC400-7DDF-4748-9AFB-5AE4D74A610B}';
  // TODO: Add all other units.

  { (g)et (s)tatic (t)exts region consts, carry a 'PStaticTextsAll' record in 'Userdata' }
  gstAll = 0;

{$region Provider reason}
  { (p)rovider (r)eason extensions to consts in obs_prosu }
  { notifications for this reason carries a 'PStaticTextsAll' record in 'Userdata' }
  prStaticTexts = prUser + 1;
  { notifications for this reason carries a 'PStatusbarPanelText' record in 'Userdata' }
  prStatusBarPanelText = prUser + 2;
  { notifications for this reason carries a 'PDirectories' record in 'Userdata' & an object in 'aNotifyClass' }
  prCreateDirs = prUser + 3;

  prReadsettings = prUser + 4;
  prUpdateSettings = prUser + 5;
  prReadFormState = prUser + 6;
  prCreateDbFile = prUser + 7;
  prOpenDbFile = prUser + 8;
  prGetAllItems = prUser + 9;
  prClearMainView = pruser + 10;
  prCreateAppDbMaintainer =  pruser + 11;
  prSgHeaderFontStyle = pruser + 12;
  prSgRemoveEmptyRows = pruser + 13;
  prSgAddRow = pruser + 14;
  prSgAdjust = pruser + 15;
  prBitBtnShow = pruser + 16;
  prAddNewItem = pruser + 17;
  prUpdateItem = pruser + 18;
  prDeleteItem = pruser + 19;
  prSaveChanges = pruser + 20;
  prPmiStatus = pruser + 21;
  prCheckboxToggled = pruser + 22;
  prSgPrepareCanvas = pruser + 23;
  prEnableSaveButton = pruser + 24;
  prCheckBoxParent = pruser + 25;
  prGetColumnNames = pruser + 26;
  prSaveColumnNames = pruser + 27;

{$endregion Provider reason}

  { (m)odification (s)tates }
  msCreateDir = 101;
  msReadSettings = 102;
  msUpdateSettings = 103;
  msReadFormState = 104;
  msStoreFormState = 105;
  msCreateDbFile = 106;
  msOpenDbFilePrepareView = 107;
  msOpenDbFileGetData = 108;
  msCreateAppDbReference = 109;
  msAddNewItem = 110;
  msUpdateItem = 111;
  msDeleteItem = 112;
  msSaveChanges = 113;
  msCheckboxToggled = 114;
  msGetColumnnames = 115;


  { (a)pplication (d)irectories }
  adSettings = 'Settings';
  adLogging  = 'Logging';
  adDatabase = 'Database';

  { (a)pplication (m)essages }
  amSucces = 'Success';
  amFailed = 'Failed';

  { (a)pplication (f)iles }
  afSettings = 'Settings.cfg';
  afLogging = 'Logging.log';

  { (f)orm (n)ame }
  fnMain = 'Form_Main';
  fnConfigure = 'Form_Configure';

  { (l)anguage }
  lEN = 'EN';
  lNL = 'NL';

  { (s)tringgrid (s)tate }
  ssRead = 'ReadOnly';
  ssModify = 'ModifyItems';
  ssModifyRelations = 'ModifyRelations';

  { (I)tem (A)ction }
  iaCreate = 'Create';  // Item Action = Create
  iaRead = 'Read';      // Item Action = Read
  iaUpdate = 'Update';  // Item Action = Update
  iaDelete = 'Delete';  // Item Action = Delete


type
  { alias from /super/ vwmain.types }
  //PStaticTextsAll = vwmain.types.PStaticTextsAll;
  TStaticTextsAll = vwmain.types.TStaticTextsAll;
  TStatusbarPanelText = vwmain.types.TStatusbarPanelText;
  TTransaction = vwmain.types.TTransaction;
  TDirectoriesRec = vwmain.types.TDirectoriesRec;
  PDirectoriesRec = vwmain.types.PDirectoriesRec;
  TSettingsRec = vwmain.types.TSettingsRec;
  TCreDbFileRec = vwmain.types.TCreDbFileRec;
  TCreateAppdatabase = AppDbCreate.TCreateAppdatabase;
  TOpenDbFilePrepareViewRec = vwmain.types.TOpenDbFilePrepareViewRec;
  TOpenAppdatabase = AppDbOpen.TOpenAppdatabase;
  TBuildComponents = BuildComponents.TBuildComponents;
  TAppDbMaintainItems = AppDbMaintainItems.TAppDbMaintainItems;
  TStringGridFab = StringGridFabric.TStringGridFab;

  TOpenDbFileGetDataRec = vwmain.types.TOpenDbFileGetDataRec;
  TClearPtrData = vwmain.types.TClearPtrData;
  TStringGridRec = vwmain.types.TStringGridRec;
  PStringGridRec = vwmain.types.PStringGridRec;
  TBitBtnRec = vwmain.types.TBitBtnRec;
  TSaveBtn = vwmain.types.TSaveBtn;
  PSaveBtn = vwmain.types.PSaveBtn;
  PBitBtnRec = vwmain.types.PBitBtnRec;
  TItemObjectData = vwmain.types.TItemObjectData;
  PtrItemObject = vwmain.types.PtrItemObject;
  POpenDbFilePrepareViewRec = vwmain.types.POpenDbFilePrepareViewRec;
  TPmiVisibility = vwmain.types.TPmiVisibility;
  TSaveChangesRec = vwmain.types.TSaveChangesRec;
  PSaveChangesRec = vwmain.types.PSaveChangesRec;
//  TPrepSgCanvas = vwmain.types.TPrepSgCanvas;
//  PPrepSgCanvas = vwmain.types.PPrepSgCanvas;
  TCheckBoxCellPosition = vwmain.types.TCheckBoxCellPosition;
  PCheckBoxCellPosition = vwmain.types.PCheckBoxCellPosition;
  TStringGridSelect = vwmain.types.TStringGridSelect;
  PStringGridSelect = vwmain.types.PStringGridSelect;

  TGetColumnNameRec = vwmain.types.TGetColumnNameRec;
  PGetColumnNameRec = vwmain.types.PGetColumnNameRec;
  AllColumnNames = vwmain.types.AllColumnNames;
  AllItemsObjectData = vwmain.types.AllItemsObjectData;

  // Logging type, information, warning,error, debug.
  TLoggingAction = (
    laInformation,  // The logged text will get a Information Label.
    laWarning,      // The logged text will get a Warning Label.
    laError,        // The logged text will get a Error Label
    laDebug)        // The logged text will get a Debug Label
    ;

implementation

end.


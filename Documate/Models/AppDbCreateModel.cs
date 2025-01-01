using Documate.Library;
using System.Data;
using System.Data.SQLite;
using System.Globalization;
using System.Windows.Forms;

namespace Documate.Models
{
    public class AppDbCreateModel: AppDbModel, IAppDbCreateModel
    {
        private bool _canContinue;

        #region SQL strings
        private readonly string creTblSetmeta = "CREATE TABLE IF NOT EXISTS " + SettingsMeta + " (" +
                "ID                 INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE        ," +
                "GUID               VARCHAR(50)                                              ," +
                "KEY                VARCHAR(50)  UNIQUE                                      ," +
                "VALUE              VARCHAR(255))";

        private readonly string creTblItems = "create table if not exists " + Items + " (" +
                "ID              INTEGER      NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, " +
                "GUID            VARCHAR(50)  UNIQUE                                   , " +
                "LEVEL	         INTEGER                                               , " +
                "NAME            VARCHAR(1000)                                         , " +
                "DATE_CREATED    DATE                                                  , " +
                "DATE_ALTERED    DATE                                                  , " +
                "CREATED_BY      VARCHAR(100)                                          , " +
                "ALTERED_BY      VARCHAR(100));";

        private readonly string creTblItemsMemo = "create table if not exists " + ItemsMemo + " (" +
                "ID              INTEGER      NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, " +
                "GUID            VARCHAR(50)  UNIQUE                                   , " +
                "MEMO            VARCHAR(10000)                                        , " +
                "GUID_PARENT     VARCHAR(50)                                           , " +
                "DATE_CREATED    DATE                                                  , " +
                "DATE_ALTERED    DATE                                                  , " +
                "CREATED_BY      VARCHAR(100)                                          , " +
                "ALTERED_BY      VARCHAR(100));";

        private readonly string creTblRelItems = "create table if not exists " + RelItems + " (" +
                "ID              INTEGER      NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, " +
                "GUID            VARCHAR(50)  UNIQUE                                   , " +
                "GUID_LEVEL_A    VARCHAR(50)                                           , " +
                "GUID_LEVEL_B    VARCHAR(50)                                           , " +
                "DATE_CREATED    DATE                                                  , " +
                "DATE_ALTERED    DATE                                                  , " +
                "CREATED_BY      VARCHAR(100)                                          , " +
                "ALTERED_BY      VARCHAR(100));";

        #endregion SQL strings

        // Nu nog als voorbeeld handaven. database krijgt een default waarde. dat is nodig voor de DI.
        public AppDbCreateModel(IAppSettings appSettings, LoggingModel loggingModel, string databaseName = "DefaultDatabaseName") : base(appSettings, loggingModel)  // Call the base class constructor
        {
            _dbVersion = _appSettings.DatabaseVersion;
            base.DatabaseName = databaseName;  // TODO not used. Remove.
        }

        public void CloseDatabaseConnection()
        {
            if (this.DbConnection != null && this.DbConnection.State != ConnectionState.Closed)
            {
                this.DbConnection.Close();
            }
        }
        public bool CreateAppDbFile(string databaseLocationName)
        {
            if (!string.IsNullOrEmpty(databaseLocationName))
            {
                DeleteExistingFile(databaseLocationName);

                base.DbConnection = new SQLiteConnection("Data Source=" + databaseLocationName);  // TODO; This should be in a different location that is more generic

                this.DbLocation = Path.GetDirectoryName(databaseLocationName);
                this.DatabaseFileName = Path.GetFileNameWithoutExtension(databaseLocationName);
                
                if (Path.Exists(DbLocation))
                {
                    if (CheckDatabaseFile(databaseLocationName))  // Creates an empty database file.
                    {
                        if (_canContinue)
                        {
                            if (!Error) { SqliteAutoVacuum();  }
                            if (!Error) { SqliteJournalMode(); }
                            if (!Error) { CreateTable(creTblSetmeta, SettingsMeta, base._dbVersion.ToString()); }
                            if (!Error) { InsertMeta(base._dbVersion.ToString()); }
                        }

                        if (!Error)
                        {
                            CreateAllTables();
                        }
                    }
                    else { Error = true; }
                }
                else { Error = true; }
            }
            else { Error = true; }

            if (!Error)
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        public void InsertMeta(string key, string value)
        {
            if (!Error)
            {
                string insertSQL = string.Format("INSERT INTO {0} (GUID, KEY, VALUE) VALUES(@GUID, @KEY, @VALUE)", SettingsMeta);

                if (DbConnection != null && this.DbConnection.State == ConnectionState.Closed)
                {
                    OpenDbConnection();
                }

                SQLiteCommand command = new(insertSQL, this.DbConnection);
                try
                {
                    command.Parameters.Add(new SQLiteParameter("@GUID", Guid.NewGuid().ToString()));
                    command.Parameters.Add(new SQLiteParameter("@KEY", key));
                    command.Parameters.Add(new SQLiteParameter("@VALUE", value));
                    command.Prepare();

                    command.ExecuteNonQuery();
                    _loggingModel.WriteToLog(Common.LogAction.INFORMATION, string.Format(LocalizationHelper.GetString("TableIsUpdated", LocalizationPaths.AppDbCreate), SettingsMeta));
                }
                catch (SQLiteException ex)
                {
                    _loggingModel.WriteToLog(Common.LogAction.ERROR, string.Format(LocalizationHelper.GetString("FailedToInsertDataIntoTabel", LocalizationPaths.AppDbCreate), SettingsMeta));
                    _loggingModel.WriteToLog(Common.LogAction.ERROR, LocalizationHelper.GetString("Notification", LocalizationPaths.General));
                    _loggingModel.WriteToLog(Common.LogAction.ERROR, ex.Message);

                    Error = true;
                    this.ErrorMessage = string.Format("Het invoeren van gegevens in de tabel {0} is mislukt.", SettingsMeta);
                }
                finally
                {
                    command.Dispose();
                    this.DbConnection?.Close();
                }
            }
            else
            {
                _loggingModel.WriteToLog(Common.LogAction.ERROR, string.Format(LocalizationHelper.GetString("FailedToInsertDataIntoTabel", LocalizationPaths.AppDbCreate), SettingsMeta));
            }

            // if insert meta is faulted...
            if (Error)
            {
                MessageBox.Show(string.Format(LocalizationHelper.GetString("FailedToInsertDataIntoTabel", LocalizationPaths.AppDbCreate), SettingsMeta),
                    LocalizationHelper.GetString("Error", LocalizationPaths.General), MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private bool CheckDatabaseFile(string dbFileName)
        {
            try
            {
                // Only with a first install. (Unless a user removed the database file).
                if (!File.Exists(dbFileName))
                {
                    SQLiteConnection.CreateFile(dbFileName); // The creation of a new empty database file.

                    _loggingModel.WriteToLog(
                        Common.LogAction.INFORMATION,
                        $"{LocalizationHelper.GetString("EmptyDbFileCreated", LocalizationPaths.AppDbCreate)} ({dbFileName}).");
                    _canContinue = true;
                }
                else
                {
                    _loggingModel.WriteToLog(
                        Common.LogAction.INFORMATION,
                        $"{LocalizationHelper.GetString("FailedToCreateDbFile", LocalizationPaths.AppDbCreate)} ({dbFileName}).");
                    _loggingModel.WriteToLog(Common.LogAction.INFORMATION, LocalizationHelper.GetString("DbFileAlreadyExists", LocalizationPaths.AppDbCreate));
                    _canContinue = false;
                }

                return true;
            }
            catch (IOException ex)
            {
                _loggingModel.WriteToLog(
                        Common.LogAction.INFORMATION,
                        $"{LocalizationHelper.GetString("FailedToCreateDbFile", LocalizationPaths.AppDbCreate)} ({dbFileName}).");
                _loggingModel.WriteToLog(Common.LogAction.ERROR, LocalizationHelper.GetString("Notification", LocalizationPaths.General));
                _loggingModel.WriteToLog(Common.LogAction.ERROR, ex.Message);

                MessageBox.Show(LocalizationHelper.GetString("UnexpectedErrorCreDbFile", LocalizationPaths.AppDbCreate), LocalizationHelper.GetString("Error", LocalizationPaths.General), MessageBoxButtons.OK, MessageBoxIcon.Error);
                return false;
            }
            catch (Exception ex)
            {
                _loggingModel.WriteToLog(
                        Common.LogAction.INFORMATION,
                        $"{LocalizationHelper.GetString("FailedToCreateDbFile", LocalizationPaths.AppDbCreate)} ({dbFileName}).");
                _loggingModel.WriteToLog(Common.LogAction.ERROR, LocalizationHelper.GetString("Notification", LocalizationPaths.General));
                _loggingModel.WriteToLog(Common.LogAction.ERROR, ex.Message);


                MessageBox.Show(LocalizationHelper.GetString("UnexpectedErrorCreDbFile", LocalizationPaths.AppDbCreate), LocalizationHelper.GetString("Error", LocalizationPaths.General), MessageBoxButtons.OK, MessageBoxIcon.Error);
                return false;
            }
        }

        private static void DeleteExistingFile(string fileName)
        {
            if (File.Exists(fileName))
            {
                File.Delete(fileName);
            }
        }

        private void SqliteAutoVacuum()
        {
            if (this.DbConnection == null)
            {
                Error = true;
                _loggingModel.WriteToLog(Common.LogAction.ERROR, LocalizationHelper.GetString("ErrorDbConnection", LocalizationPaths.AppDbCreate));                
                return;
            }

            if (this.DbConnection != null && this.DbConnection.State == ConnectionState.Closed)
            {
                this.OpenDbConnection();
            }

            SQLiteCommand command = new(this.DbConnection)
            {
                CommandText = "pragma auto_vacuum = incremental;"
            };

            try
            {
                command.ExecuteNonQuery();
                _loggingModel.WriteToLog(Common.LogAction.INFORMATION, LocalizationHelper.GetString("SetAutoVacuum", LocalizationPaths.AppDbCreate));
            }
            catch (SQLiteException ex)
            {
                _loggingModel.WriteToLog(Common.LogAction.INFORMATION, LocalizationHelper.GetString("SetAutoVacuumFailed", LocalizationPaths.AppDbCreate));
                _loggingModel.WriteToLog(Common.LogAction.ERROR, LocalizationHelper.GetString("Notification", LocalizationPaths.General));
                _loggingModel.WriteToLog(Common.LogAction.ERROR, ex.Message);

                Error = true;
                this.ErrorMessage = string.Format("Het zetten van de database instelling 'auto_vacuum = incremental' is mislukt.");
            }
            finally
            {
                command.Dispose();
                this.DbConnection?.Close();
            }
        }

        private void SqliteJournalMode()
        {
            if (this.DbConnection == null)
            {
                Error = true;
                _loggingModel.WriteToLog(Common.LogAction.ERROR, LocalizationHelper.GetString("ErrorDbConnection", LocalizationPaths.AppDbCreate));
                return;
            }

            if (this.DbConnection != null && this.DbConnection.State == ConnectionState.Closed)
            {
                this.OpenDbConnection();
            }

            SQLiteCommand command = new(this.DbConnection)
            {
                CommandText = "pragma journal_mode = wal;"
            };

            try
            {
                command.ExecuteNonQuery();
                _loggingModel.WriteToLog(Common.LogAction.INFORMATION, LocalizationHelper.GetString("SetJournalMode", LocalizationPaths.AppDbCreate));
            }
            catch (SQLiteException ex)
            {
                _loggingModel.WriteToLog(Common.LogAction.INFORMATION, LocalizationHelper.GetString("SetJournalModeFailed", LocalizationPaths.AppDbCreate));
                _loggingModel.WriteToLog(Common.LogAction.ERROR, LocalizationHelper.GetString("Notification", LocalizationPaths.General));
                _loggingModel.WriteToLog(Common.LogAction.ERROR, ex.Message);

                Error = true;
                this.ErrorMessage = string.Format("Het zetten van de database instelling 'journal_mode = wal' is mislukt.");
            }
            finally
            {
                command.Dispose();
                this.DbConnection?.Close();
            }
        }

        private void CreateTable(string sqlCreateString, string tableName, string version)
        {
            if (this.DbConnection == null)
            {
                Error = true;
                _loggingModel.WriteToLog(Common.LogAction.ERROR, LocalizationHelper.GetString("ErrorDbConnection", LocalizationPaths.AppDbCreate));
                return;
            }

            if (!Error)
            {
                if (DbConnection != null && this.DbConnection.State == ConnectionState.Closed)
                {
                    this.OpenDbConnection();
                }

                SQLiteCommand command = new(sqlCreateString, this.DbConnection);
                try
                {
                    command.ExecuteNonQuery();

                    _loggingModel.WriteToLog(Common.LogAction.INFORMATION,
                        string.Format(LocalizationHelper.GetString("TableIsCreated", LocalizationPaths.AppDbCreate), tableName, version));

                }
                catch (SQLiteException ex)  //
                {
                    _loggingModel.WriteToLog(Common.LogAction.ERROR,
                        string.Format(LocalizationHelper.GetString("CreateTableFailed", LocalizationPaths.AppDbCreate), tableName, version));
                    _loggingModel.WriteToLog(Common.LogAction.ERROR, LocalizationHelper.GetString("Notification", LocalizationPaths.General));
                    _loggingModel.WriteToLog(Common.LogAction.ERROR, ex.Message);


                    Error = true;
                    ErrorMessage = string.Format("Het aanmaken van de tabel {0} is mislukt. (Versie {1}).", tableName, version);
                }
                finally
                {
                    command.Dispose();
                    this.DbConnection?.Close();
                }
            }
            else
            {
                _loggingModel.WriteToLog(Common.LogAction.ERROR,
                        string.Format(LocalizationHelper.GetString("CreateTableFailed", LocalizationPaths.AppDbCreate), tableName, version));
            }
        }

        private void InsertMeta(string version)
        {
            if (!Error)
            {
                if (this.DbConnection == null)
                {
                    Error = true;
                    _loggingModel.WriteToLog(Common.LogAction.ERROR, LocalizationHelper.GetString("ErrorDbConnection", LocalizationPaths.AppDbCreate));
                    return;
                }

                string insertSQL = string.Format("INSERT INTO {0} (GUID, KEY, VALUE) VALUES(@GUID, @KEY, @VERSION)", SettingsMeta);

                if (DbConnection != null && this.DbConnection.State == ConnectionState.Closed)
                {
                    OpenDbConnection();
                }

                SQLiteCommand command = new(insertSQL, this.DbConnection);
                try
                {
                    command.Parameters.Add(new SQLiteParameter("@GUID", Guid.NewGuid().ToString()));
                    command.Parameters.Add(new SQLiteParameter("@KEY", "VERSION"));
                    command.Parameters.Add(new SQLiteParameter("@VERSION", version));
                    command.Prepare();

                    command.ExecuteNonQuery();
                    _loggingModel.WriteToLog(Common.LogAction.INFORMATION,
                        string.Format(LocalizationHelper.GetString("TableIsUpdatedWithVersion", LocalizationPaths.AppDbCreate), SettingsMeta, version));
                }
                catch (SQLiteException ex)
                {
                    _loggingModel.WriteToLog(Common.LogAction.INFORMATION,
                        string.Format(LocalizationHelper.GetString("UpdateVersionNumberFailed", LocalizationPaths.AppDbCreate), SettingsMeta, version));
                    _loggingModel.WriteToLog(Common.LogAction.ERROR, LocalizationHelper.GetString("Notification", LocalizationPaths.General));
                    _loggingModel.WriteToLog(Common.LogAction.ERROR, ex.Message);


                    Error = true;
                    this.ErrorMessage = string.Format(LocalizationHelper.GetString("UpdateVersionNumberFailed", LocalizationPaths.AppDbCreate), SettingsMeta, version);
                }
                finally
                {
                    command.Dispose();
                    this.DbConnection?.Close();
                }
            }
            else
            {
                this.ErrorMessage = string.Format(LocalizationHelper.GetString("UpdateVersionNumberFailed", LocalizationPaths.AppDbCreate), SettingsMeta, version);
            }
        }

        private void CreateAllTables()
        {
            if (base._dbVersion >= 1 && SelectMeta() == 1)  // Version = 1 
            {
                if (!Error)
                {
                    CreateTable(this.creTblItems, Items, base._dbVersion.ToString());
                }

                if (!Error)
                {
                    CreateTable(this.creTblItemsMemo, ItemsMemo, base._dbVersion.ToString());
                }

                if (!Error)
                {
                    CreateTable(this.creTblRelItems, RelItems, base._dbVersion.ToString());
                }

                if (!Error)
                {
                    UpdateMeta(base._dbVersion.ToString());
                }

                if (!Error)
                {
                    SqliteUserVersion();
                }

                if (!Error)
                {
                    _loggingModel.WriteToLog(Common.LogAction.INFORMATION,
                        string.Format(LocalizationHelper.GetString("CreateAndOrUpdateTableReady", LocalizationPaths.AppDbCreate), base._dbVersion));
                }
            }
            else if (base._dbVersion >= 2 && this.SelectMeta() == 1)
            {
                //

                if (!Error)
                {
                    UpdateMeta(base._dbVersion.ToString());
                }

                if (!Error)
                {
                    SqliteUserVersion();
                }
            }
        }

        public int SelectMeta() // Made public so you can check the version on every application start.
        {
            if (this.DbConnection == null)
            {
                Error = true;
                _loggingModel.WriteToLog(Common.LogAction.ERROR, LocalizationHelper.GetString("ErrorDbConnection", LocalizationPaths.AppDbCreate));
                return -1;
            }

            int sqlLiteMetaVersion = 0;
            string selectSql = string.Format("SELECT VALUE FROM {0} WHERE KEY = 'VERSION'", SettingsMeta);

            _loggingModel.WriteToLog(Common.LogAction.INFORMATION, LocalizationHelper.GetString("CheckAppDbVersion", LocalizationPaths.AppDbCreate));

            if (this.DbConnection != null && this.DbConnection.State == ConnectionState.Closed)
            {
                this.OpenDbConnection();

                SQLiteCommand command = new(selectSql, this.DbConnection);
                try
                {
                    SQLiteDataReader dr = command.ExecuteReader();
                    dr.Read();
                    if (dr.HasRows)
                    {
                        if (!string.IsNullOrEmpty(dr[0].ToString()))
                        {
                            sqlLiteMetaVersion = int.Parse(dr[0].ToString() ?? string.Empty, CultureInfo.InvariantCulture);  // ?? = assign a nullable type to a non-nullable type
                        }
                        else
                        {
                            sqlLiteMetaVersion = -1;

                            LocalizationHelper.GetString("RetrieveDbVersionErrorReturnDefault", LocalizationPaths.AppDbCreate);
                            MessageBox.Show(LocalizationHelper.GetString("RetrieveDbVersionError", LocalizationPaths.AppDbCreate), 
                                LocalizationHelper.GetString("Error", LocalizationPaths.General), MessageBoxButtons.OK, MessageBoxIcon.Error);
                        }
                    }

                    dr.Close();
                }
                catch (SQLiteException ex)
                {
                    _loggingModel.WriteToLog(Common.LogAction.ERROR,
                        string.Format(LocalizationHelper.GetString("RequestMetaVersionFailed", LocalizationPaths.AppDbCreate), base._dbVersion));
                    _loggingModel.WriteToLog(Common.LogAction.ERROR, LocalizationHelper.GetString("Notification", LocalizationPaths.General));
                    _loggingModel.WriteToLog(Common.LogAction.ERROR, ex.Message);

                    Error = true;
                    ErrorMessage = string.Format(LocalizationHelper.GetString("RequestMetaVersionFailed", LocalizationPaths.AppDbCreate), base._dbVersion);
                }
                finally
                {
                    command.Dispose();
                    this.DbConnection?.Close();
                }
            }

            return sqlLiteMetaVersion;
        }

        private void UpdateMeta(string version)
        {
            if (this.DbConnection == null)
            {
                Error = true;
                _loggingModel.WriteToLog(Common.LogAction.ERROR, LocalizationHelper.GetString("ErrorDbConnection", LocalizationPaths.AppDbCreate));
                return;
            }

            if (this.DbConnection != null && this.DbConnection.State == ConnectionState.Closed)
            {
                this.OpenDbConnection();

                using var tr = this.DbConnection.BeginTransaction();
                string updateSQL = string.Format("UPDATE {0} SET VALUE  = @VERSION WHERE KEY = @KEY", SettingsMeta);

                SQLiteCommand command = new(updateSQL, this.DbConnection);
                try
                {
                    command.Parameters.Add(new SQLiteParameter("@VERSION", version));
                    command.Parameters.Add(new SQLiteParameter("@KEY", "VERSION"));
                    command.Prepare();

                    command.ExecuteNonQuery();

                    _loggingModel.WriteToLog(Common.LogAction.INFORMATION,
                        string.Format(LocalizationHelper.GetString("TableIsUpdatedWithVersion", LocalizationPaths.AppDbCreate), SettingsMeta, version));

                    command.Dispose();
                    tr.Commit();
                    DbConnection.Close();
                }
                catch (SQLiteException ex)
                {
                    _loggingModel.WriteToLog(Common.LogAction.ERROR,
                        string.Format(LocalizationHelper.GetString("FailedToUpdateTable", LocalizationPaths.AppDbCreate), SettingsMeta, version));
                    _loggingModel.WriteToLog(Common.LogAction.ERROR, LocalizationHelper.GetString("Notification", LocalizationPaths.General));
                    _loggingModel.WriteToLog(Common.LogAction.ERROR, ex.Message);

                    command.Dispose();
                    tr.Rollback();

                    Error = true;
                    ErrorMessage = string.Format("het wijzigen van de versie in tabel {0} is mislukt. (Versie " + version + ").", SettingsMeta);
                }
            }
        }

        private void SqliteUserVersion()
        {
            if (this.DbConnection != null && this.DbConnection.State == ConnectionState.Closed)
            {
                this.OpenDbConnection();
            }

            SQLiteCommand command = new(this.DbConnection)
            {
                CommandText = string.Format("pragma USER_VERSION = {0};", base._dbVersion)
            };

            try
            {
                command.ExecuteNonQuery();

                _loggingModel.WriteToLog(Common.LogAction.INFORMATION, string.Format(LocalizationHelper.GetString("SetDbUserVersionIsReady", LocalizationPaths.AppDbCreate), base._dbVersion));                
            }
            catch (SQLiteException ex)
            {
                _loggingModel.WriteToLog(Common.LogAction.ERROR, LocalizationHelper.GetString("UpdateDbUserVersionFailed", LocalizationPaths.AppDbCreate));
                _loggingModel.WriteToLog(Common.LogAction.ERROR, LocalizationHelper.GetString("Notification", LocalizationPaths.General));
                _loggingModel.WriteToLog(Common.LogAction.ERROR, ex.Message);

                Error = true;
                this.ErrorMessage = LocalizationHelper.GetString("UpdateDbUserVersionFailed", LocalizationPaths.AppDbCreate);
            }
            finally
            {
                command.Dispose();
                this.DbConnection?.Close();
            }
        }
    }
}

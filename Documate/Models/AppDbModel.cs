using System.Data.SQLite;
using System.Data;
using Documate.Library;

namespace Documate.Models
{
    public class AppDbModel: AppMessage
    {
        // Table names
        protected const string SettingsMeta = "SETTINGS_META";
        protected const string Items = "ITEMS";
        protected const string ItemsMemo = "ITEMS_MEMO";
        protected const string RelItems = "REL_ITEMS";

        protected readonly IAppSettings _appSettings;
        protected readonly LoggingModel _loggingModel;
        protected int _dbVersion;
        protected string? DbDirectory { get; set; } = string.Empty;
        protected string DatabaseName { get; set; } = string.Empty;
        public bool Error { get; protected set; }  // TODO moet dit public blijven?
        public string ErrorMessage { get; protected set; } = string.Empty;  // TODO moet dit public blijven?

        #region Properties
        /// <summary>
        /// Gets or sets the name of the database file location.
        /// </summary>
        protected string? DbLocation { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the name of the database file.
        /// </summary>
        protected string DatabaseFileName { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the SQlite connection.
        /// </summary>
        protected SQLiteConnection? DbConnection { get; set; }

        #endregion Properties

        public AppDbModel(IAppSettings appSettings, LoggingModel loggingModel)
        {
            _appSettings = appSettings;
            _loggingModel = loggingModel;

            DbDirectory = _appSettings.DatabaseDirectory;
            _dbVersion = _appSettings.DatabaseVersion;
        }

        protected void OpenDbConnection()
        {
            if (DbConnection != null && DbConnection.State == ConnectionState.Closed)
            {
                SqliteSetTempStore();      // Before every DbConnection.Open()
                SqliteSetSynchronous();    // Before every DbConnection.Open()
                DbConnection.Open();
            }
        }

        protected void SqliteSetTempStore()
        {
            if (DbConnection != null && DbConnection.State == ConnectionState.Closed)
            {
                DbConnection.Open();
            }


            SQLiteCommand command = new(DbConnection)
            {
                CommandText = "pragma temp_store = Memory;"
            };

            try
            {
                command.ExecuteNonQuery();
            }
            catch (SQLiteException ex)
            {
                AddMessage(MessageType.Error,
                           LocalizationHelper.GetString("FailedSettingTempStore", LocalizationPaths.AppDb));

                _loggingModel.WriteToLog(Common.LogAction.ERROR, LocalizationHelper.GetString("FailedSettingTempStore", LocalizationPaths.AppDb));
                _loggingModel.WriteToLog(Common.LogAction.ERROR, LocalizationHelper.GetString("Notification", LocalizationPaths.AppDb));
                _loggingModel.WriteToLog(Common.LogAction.ERROR, ex.Message);
            }
            finally
            {
                command.Dispose();

                DbConnection?.Close();  // = if (DbConnection != null)
            }
        }

        protected void SqliteSetSynchronous()
        {
            if (DbConnection != null && DbConnection.State == ConnectionState.Closed)
            {
                DbConnection.Open();
            }

            SQLiteCommand command = new(DbConnection)
            {
                CommandText = "pragma synchronous = normal;"
            };

            try
            {
                command.ExecuteNonQuery();
            }
            catch (SQLiteException ex)
            {
                AddMessage(MessageType.Error,
                           LocalizationHelper.GetString("FailedSettingSynchronous", LocalizationPaths.AppDb));

                _loggingModel.WriteToLog(Common.LogAction.ERROR, LocalizationHelper.GetString("FailedSettingSynchronous", LocalizationPaths.AppDb));
                _loggingModel.WriteToLog(Common.LogAction.ERROR, LocalizationHelper.GetString("Notification", LocalizationPaths.AppDb));
                _loggingModel.WriteToLog(Common.LogAction.ERROR, ex.Message);

            }
            finally
            {
                command.Dispose();

                DbConnection?.Close();
            }
        }
    }
}

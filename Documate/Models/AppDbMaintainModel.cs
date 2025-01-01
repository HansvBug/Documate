using Documate.Library;
using Documate.Resources.Logging;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SQLite;
using System.Globalization;
using System.Linq;
using System.Security.Permissions;
using System.Text;
using System.Threading.Tasks;

namespace Documate.Models
{
    public class AppDbMaintainModel: AppDbModel, IAppDbMaintainModel
    {
        public enum CopyType
        {
            START_UP,
            OTHER
        }
        
        public AppDbMaintainModel(IAppSettings appSettings, LoggingModel loggingModel) : base(appSettings, loggingModel)
        {
            //
        }
        public bool CopyDatabaseFile(string databaseName, CopyType type)
        {
            if (String.IsNullOrEmpty(databaseName))
            {
                return false;
            }

            string fileToCopy = databaseName;  // == het volledige pad en bestandsnaam.
            string fileName = Path.GetFileName(databaseName);

            DateTime dateTime = DateTime.UtcNow.Date;
            string currentDate = dateTime.ToString("dd-MM-yyyy", CultureInfo.InvariantCulture);

            
            string newLocation = Path.Combine(Path.GetDirectoryName(databaseName)!, _appSettings.BackUpFolder) + "\\" + currentDate + "_" + fileName;

            bool result = false;

            if (Directory.Exists(Path.Combine(Path.GetDirectoryName(databaseName)!, _appSettings.BackUpFolder)))
            {
                if (File.Exists(fileToCopy))
                {
                    if (type == CopyType.START_UP)
                    {
                        File.Copy(fileToCopy, newLocation, true);  // Overwrite file = true.
                        _loggingModel.WriteToLog(Common.LogAction.INFORMATION, string.Format(LocalizationHelper.GetString("CopyFileReady", LocalizationPaths.AppDbMaintain), databaseName));
                        
                        result = true;
                    }
                    else
                    {
                        if (File.Exists(newLocation))
                        {
                            DialogResult dialogResult = MessageBox.Show(
                                LocalizationHelper.GetString("FileExistOverwrite", LocalizationPaths.AppDbMaintain), 
                                LocalizationHelper.GetString("CopyFile", LocalizationPaths.AppDbMaintain),
                                MessageBoxButtons.YesNo, MessageBoxIcon.Question
                                );
                            if (dialogResult == DialogResult.Yes)
                            {
                                File.Copy(fileToCopy, newLocation, true);  // Overwrite file = true
                                _loggingModel.WriteToLog(Common.LogAction.INFORMATION, string.Format(LocalizationHelper.GetString("CopyFileReady", LocalizationPaths.AppDbMaintain), databaseName));
                                result = true;
                            }
                            else if (dialogResult == DialogResult.No)
                            {
                                _loggingModel.WriteToLog(Common.LogAction.INFORMATION, LocalizationHelper.GetString("CopyFileAborted", LocalizationPaths.AppDbMaintain));
                                result = false;
                            }
                        }
                        else
                        {
                            File.Copy(fileToCopy, newLocation, false);  // Overwrite file = false
                            _loggingModel.WriteToLog(Common.LogAction.INFORMATION, string.Format(LocalizationHelper.GetString("CopyFileReady", LocalizationPaths.AppDbMaintain), databaseName));
                            result = true;
                        }
                    }
                }
                else
                {
                    _loggingModel.WriteToLog(Common.LogAction.INFORMATION, LocalizationHelper.GetString("FileNotPresent", LocalizationPaths.AppDbMaintain));
                    MessageBox.Show(
                        string.Format(LocalizationHelper.GetString("FileNotPresent", LocalizationPaths.AppDbMaintain), databaseName),
                            LocalizationHelper.GetString("CopyFile", LocalizationPaths.AppDbMaintain),
                            MessageBoxButtons.OK, MessageBoxIcon.Error);
                    result = false;
                }
            }
            else
            {
                MessageBox.Show(
                            string.Format(LocalizationHelper.GetString("FolderNotPresent", LocalizationPaths.AppDbMaintain), databaseName),
                            LocalizationHelper.GetString("CopyFile", LocalizationPaths.AppDbMaintain),
                            MessageBoxButtons.OK, MessageBoxIcon.Error);
                result = false;
            }

            return result;
        }

        public void CompressDatabase()
        {
            base.DbConnection = new SQLiteConnection("Data Source=" + DocumateUtils.FileLocationAndName);  // FileLocationAndName is set when a file is opened or created.
            this.DbConnection.Open();
            SQLiteCommand command = new(this.DbConnection)
            {
                CommandText = "vacuum;"
            };
            try
            {
                command.ExecuteNonQuery();
                _loggingModel.WriteToLog(Common.LogAction.INFORMATION, LocalizationHelper.GetString("CompressAppDb", LocalizationPaths.AppDbMaintain));
            }
            catch (SQLiteException ex)
            {
                _loggingModel.WriteToLog(Common.LogAction.ERROR, LocalizationHelper.GetString("CompressAppDbFailed", LocalizationPaths.AppDbMaintain));
                _loggingModel.WriteToLog(Common.LogAction.ERROR, LocalizationHelper.GetString("Notification", LocalizationPaths.General));
                _loggingModel.WriteToLog(Common.LogAction.ERROR, ex.Message);
            }
            finally
            {
                command.Dispose();
                this.DbConnection.Close();
            }
        }

        /// <summary>
        /// Reset all sequences in the appliction databae.
        /// </summary>
        public void ResetAllAutoIncrementFields()
        {
            base.DbConnection = new SQLiteConnection("Data Source=" + DocumateUtils.FileLocationAndName);
            this.DbConnection.Open();
            SQLiteCommand command = new(this.DbConnection);
            command.Prepare();
            command.CommandText = "DELETE FROM sqlite_sequence;";
            try
            {
                command.ExecuteNonQuery();
                _loggingModel.WriteToLog(Common.LogAction.INFORMATION, LocalizationHelper.GetString("ResetAppDbSequence", LocalizationPaths.AppDbMaintain));
            }
            catch (SQLiteException ex)
            {
                _loggingModel.WriteToLog(Common.LogAction.ERROR, LocalizationHelper.GetString("ResetAppDbSequenceFailed", LocalizationPaths.AppDbMaintain)); 
                _loggingModel.WriteToLog(Common.LogAction.ERROR, LocalizationHelper.GetString("Notification", LocalizationPaths.General));
                _loggingModel.WriteToLog(Common.LogAction.ERROR, ex.Message);

            }
            finally
            {
                command.Dispose();
                this.DbConnection.Close();
            }
        }

        public int GetColCount()
        {
            base.DbConnection = new SQLiteConnection("Data Source=" + DocumateUtils.FileLocationAndName);  // TODO; dit moet anders.

            int ColNumber = -1;
            string selectSql = string.Format("SELECT VALUE FROM {0} WHERE KEY = 'Column count'", SettingsMeta);
            //_loggingModel.WriteToLog(Common.LogAction.INFORMATION, LocalizationHelper.GetString("RequestColCount", LocalizationPaths.AppDbMaintain));

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
                            ColNumber = int.Parse(dr[0].ToString() ?? string.Empty, CultureInfo.InvariantCulture);  // ?? = assign a nullable type to a non-nullable type.

                            _loggingModel.WriteToLog(
                                Common.LogAction.INFORMATION,
                                $"{LocalizationHelper.GetString("NumberOfColsIs", LocalizationPaths.AppDbMaintain)} ({ColNumber.ToString()}).");
                        }
                        else  // Never happens.
                        {
                            _loggingModel.WriteToLog(
                                Common.LogAction.ERROR,
                                $"{LocalizationHelper.GetString("NumberOfColsIs", LocalizationPaths.AppDbMaintain)} ({"-"}).");
                        }
                    }

                    dr.Close();
                }
                catch (SQLiteException ex)
                {
                    _loggingModel.WriteToLog(
                                Common.LogAction.ERROR,
                                $"{LocalizationHelper.GetString("RequestColCountFailed", LocalizationPaths.AppDbMaintain)} ({_dbVersion}).");
                    _loggingModel.WriteToLog(Common.LogAction.ERROR, LocalizationHelper.GetString("Notification", LocalizationPaths.General));
                    _loggingModel.WriteToLog(Common.LogAction.ERROR, ex.Message);

                }
                finally
                {
                    command.Dispose();
                    this.DbConnection?.Close();
                }
            }

            return ColNumber;
        }
    }
}

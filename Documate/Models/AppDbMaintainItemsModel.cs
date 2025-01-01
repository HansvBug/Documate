using Documate.Library;
using System.Data;
using System.Data.SQLite;
using static Documate.Library.DmItem;

namespace Documate.Models
{
    public class AppDbMaintainItemsModel: AppDbModel, IAppDbMaintainItemsModel
    {        
        private IDmItems _dmItems;
        private LoggingModel _logging;
        public AppDbMaintainItemsModel(IAppSettings appSettings, LoggingModel loggingModel, IDmItems dmItems) : base(appSettings, loggingModel)  // TODO: nakijken, is in AppDbModel appSettings nodig?
        {
            _dmItems = dmItems;
            _logging = loggingModel;
        }

        public List<DmItem> ReadLevel(int level, DataGridView dgv, bool sorted)
        {
            var itemList = new List<DmItem>();

            if (level < 1 || dgv == null || string.IsNullOrEmpty(DocumateUtils.FileLocationAndName))
            {
                return itemList; // Return empty list on invalid input.
            }

            string SqlText = $"select ID, GUID, LEVEL, NAME from {Items} where LEVEL = @LEVEL";

            if (sorted)
            {
                SqlText += " order by LEVEL, NAME COLLATE NOCASE ASC";  // COLLATE NOCASE ASC is needed otherwise, upper and lower case letters will be sorted incorrectly  
            }

            if (DbConnection != null && this.DbConnection.State == ConnectionState.Closed)
            {
                this.OpenDbConnection();
            }
            else if (DbConnection == null)
            {
                base.DbConnection = new SQLiteConnection("Data Source=" + DocumateUtils.FileLocationAndName);
                this.OpenDbConnection();
            }

            try
            {
                SQLiteCommand command = new(SqlText, this.DbConnection);
                command.Parameters.Add(new SQLiteParameter("@LEVEL", level));
                command.Prepare();

                SQLiteDataReader dr = command.ExecuteReader();

                if (dr.HasRows)
                {
                    if (dgv.DataSource is BindingSource bindingSource)
                    {
                        if (bindingSource.DataSource is DataTable dataTable)
                        {
                            while (dr.Read())
                            {
                                // Create new Item object.
                                var item = new DmItem
                                {
                                    RowId = dr.GetInt32(0),
                                    Guid = dr.GetString(1),
                                    Level = dr.GetInt32(2),
                                    Name = dr.GetString(3),
                                    Action = ItemActions.Read.ToString(),
                                    DgvName = dgv.Name,
                                };
                                itemList.Add(item);

                                DataRow newRow = dataTable.NewRow();
                                newRow[0] = item.Guid;
                                newRow[1] = item.Level;
                                // TODO; hier moeten parent en child nog komen.

                                newRow[4] = item.Name;  // [4] Is the fifth column in the data table.
                                newRow[5] = item;       // The last column holds the item Object.
                                dataTable.Rows.Add(newRow);
                            }

                            dataTable.AcceptChanges();  // Nodig zodat alter wijzigingen gemonitord kunnen worden.
                        }
                    }
                }
            }
            catch (SQLiteException ex)
            {
                _loggingModel.WriteToLog(Common.LogAction.ERROR, LocalizationHelper.GetString("ReadDataError", LocalizationPaths.AppDbMaintainItems));
                _loggingModel.WriteToLog(Common.LogAction.ERROR, LocalizationHelper.GetString("Notification", LocalizationPaths.General));
                _loggingModel.WriteToLog(Common.LogAction.ERROR, ex.Message);
            }

            return itemList; // Return the list of objects.
        }

        public void SaveItems(int level, DataGridView dgv)
        {
            if (DbConnection != null && this.DbConnection.State == ConnectionState.Closed)
            {
                this.OpenDbConnection();
            }
            else if (DbConnection == null)
            {
                base.DbConnection = new SQLiteConnection("Data Source=" + DocumateUtils.FileLocationAndName);
                this.OpenDbConnection();
            }

            int Level = DocumateUtils.ExtractDigets(dgv.Name);

            DeleteItems();
            SaveChanges(Level, dgv);
            DbConnection.Close();
            // TODO, save knop moet uit hierna.
        }

        private void DeleteItems()
        {
            try
            {
                foreach (var item in _dmItems.Items)
                {
                    string deleteQuery = $"delete from {Items} where GUID = @GUID";

                    using (SQLiteCommand deleteCommand = new SQLiteCommand(deleteQuery, DbConnection))
                    {
                        deleteCommand.Parameters.AddWithValue("@GUID", item.Guid);
                        deleteCommand.ExecuteNonQuery();

                        _logging.WriteToLog(Common.LogAction.INFORMATION, $"Record is verwijderd. (Name = {item.Name}");  // TODO; Taal aanpassen.
                    }
                }

                // Lijst leegmaken.
                _dmItems.Items.Clear();
            }
            catch (SQLiteException ex)
            {
                // Specifieke afhandeling voor SQLite-fouten
                _loggingModel.WriteToLog(Common.LogAction.ERROR, "Fout bij het verwijdren van een record."); // TODO:  LocalizationHelper.GetString("ReadDataError", LocalizationPaths.AppDbMaintainItems)
                _loggingModel.WriteToLog(Common.LogAction.ERROR, LocalizationHelper.GetString("Notification", LocalizationPaths.General));
                _loggingModel.WriteToLog(Common.LogAction.ERROR, ex.Message);



                Console.WriteLine($"SQLite error: {ex.Message}");
            }
            catch (Exception ex)
            {
                // Algemene foutafhandeling
                _loggingModel.WriteToLog(Common.LogAction.ERROR, "Fout bij het verwijdren van een record."); // TODO:  LocalizationHelper.GetString("ReadDataError", LocalizationPaths.AppDbMaintainItems)
                _loggingModel.WriteToLog(Common.LogAction.ERROR, LocalizationHelper.GetString("Notification", LocalizationPaths.General));
                _loggingModel.WriteToLog(Common.LogAction.ERROR, ex.Message);
            }
        }

        private void SaveChanges(int level, DataGridView dgv)
        {
            if (dgv.DataSource is BindingSource bindingSource)
            {
                bindingSource.EndEdit();  // Zorg dat wijzigingen van het DataGridView worden toegepast.

                if (bindingSource.DataSource is DataTable dataTable)
                {
                    foreach (DataRow row in dataTable.Rows)
                    {
                        switch (row.RowState)
                        {
                            case DataRowState.Added:
                                string insertQuery = "Insert into " + Items + " (GUID, LEVEL, NAME) values (@GUID, @LEVEL, @NAME)";

                                using (SQLiteCommand insertCommand = new SQLiteCommand(insertQuery, DbConnection))
                                {
                                    insertCommand.Parameters.AddWithValue("@GUID", Guid.NewGuid().ToString());
                                    insertCommand.Parameters.AddWithValue("@LEVEL", level);
                                    insertCommand.Parameters.AddWithValue("@NAME", row["NAME"]);
                                    // TODO; add create date.
                                    insertCommand.ExecuteNonQuery();
                                }
                                break;

                            case DataRowState.Modified:
                                string updateQuery = "update " + Items + " set NAME = @NAME WHERE GUID = @GUID;";

                                using (SQLiteCommand updateCommand = new SQLiteCommand(updateQuery, DbConnection))
                                {
                                    updateCommand.Parameters.AddWithValue("@GUID", row["GUID"]);
                                    updateCommand.Parameters.AddWithValue("@NAME", row["NAME"]);

                                    updateCommand.ExecuteNonQuery();
                                }
                                break;

                            case DataRowState.Deleted: // Komt hier nooit. Deleted zijn al uit de datatable verdwenen door 'private void HandleDelete(object sender)' in DataGridViewModel.
                                string deleteQuery = "delete from " + Items + " WHERE GUID = @GUID;";

                                using (SQLiteCommand deleteCommand = new SQLiteCommand(deleteQuery, DbConnection))
                                {
                                    deleteCommand.Parameters.AddWithValue("@GUID", row["GUID", DataRowVersion.Original]);
                                    deleteCommand.ExecuteNonQuery();
                                }
                                break;
                            case DataRowState.Unchanged:
                                // Ignore unchanged rows.
                                break;
                        }
                    }

                    dataTable.AcceptChanges();
                }
            }
        }

        public void RemoveEmptyRows(DataGridView dgv)
        {
            if (dgv.DataSource is BindingSource bindingSource && bindingSource.DataSource is DataTable dataTable)
            {
                // Loop door de DataTable en verwijder lege rijen
                for (int i = dataTable.Rows.Count - 1; i >= 0; i--)
                {
                    DataRow row = dataTable.Rows[i];
                    if (row.RowState != DataRowState.Deleted &&
                        row.ItemArray.All(field => field == DBNull.Value || string.IsNullOrWhiteSpace(field?.ToString())))
                    {
                        dataTable.Rows.Remove(row);
                    }
                }

                bindingSource.EndEdit(); // Werk de binding bij
            }
            else
            {
                // Verwijder lege rijen direct uit de DataGridView als er geen DataSource is
                for (int i = dgv.Rows.Count - 1; i >= 0; i--)
                {
                    DataGridViewRow row = dgv.Rows[i];
                    if (!row.IsNewRow && row.Cells.Cast<DataGridViewCell>().All(cell => cell.Value == null || string.IsNullOrWhiteSpace(cell.Value?.ToString())))
                    {
                        dgv.Rows.RemoveAt(i);
                    }
                }
            }
        }
    }
}

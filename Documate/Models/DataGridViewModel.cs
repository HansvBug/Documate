using Documate.Library;
using System.Data;
using static Documate.Library.DmItem;

namespace Documate.Models
{
    public class DataGridViewModel: IDataGridViewModel
    {
        public event Action<string> CellClickedEvent;  // // for object data that goes to a textbox in the main view for checking.
        public event Action<bool> CanSaveChangedEvent;
        private IDmItems _dmItems;

        private List<DataGridViewCell> _duplicateDataGridViewCells;        

        public bool CanProcessKey {  get; set; }

        public DataGridViewModel(IDmItems dmItems)
        {
            _dmItems = dmItems;
            //Console.WriteLine($"Nieuwe instantie van DataGridViewModel aangemaakt: {this.GetHashCode()}");
            //string tmp = "";
        }
        
        public void HandleCellValueChanged(object sender, DataGridViewCellEventArgs e)
        {
            if (e.ColumnIndex >= 0 && e.RowIndex >= 0)
            {
                HighlightDuplicateValues((DataGridView)sender, e.ColumnIndex);
            }
        }

        public void HandleRowsAdded(object sender, DataGridViewRowsAddedEventArgs e)
        {
            var dgv = (DataGridView)sender;            

            for (int i = 0; i < dgv.ColumnCount; i++)
            {
                HighlightDuplicateValues(dgv, i);
            }
        }

        public void RowLeave(object sender, DataGridViewCellEventArgs e)
        {
            var dgv = sender as DataGridView;

            if (dgv == null || e.RowIndex < 0 || e.RowIndex >= dgv.Rows.Count)
            {
                return; // Ongeldige index of geen DataGridView.
            }

            if (dgv.DataSource is BindingSource bindingSource && bindingSource.DataSource is DataTable dataTable)
            {
                dgv.EndEdit(); // Eindig actieve bewerkingen.

                var currentRow = dgv.Rows[e.RowIndex];
                if (currentRow.IsNewRow)
                {
                    DataRow row = dataTable.Rows[e.RowIndex - 1];
                    if (row.RowState != DataRowState.Deleted)
                    {
                        if (row["ItemObject"] == DBNull.Value)
                        {
                            var newItem = new DmItem
                            {
                                Guid = Guid.NewGuid().ToString(),
                                Level = DocumateUtils.ExtractDigets(dgv.Name),
                                Name = row["NAME"]?.ToString() ?? string.Empty,
                                Action = ItemActions.Create.ToString(),
                                DgvName = dgv.Name
                            };

                            row["ItemObject"] = newItem;
                        }
                        else
                        {
                            row["ItemObject"] = ""; // Clear before update.

                            var updatedItem = new DmItem
                            {
                                Guid = Guid.NewGuid().ToString(),
                                Level = DocumateUtils.ExtractDigets(dgv.Name),
                                Name = row["NAME"]?.ToString() ?? string.Empty,
                                Action = ItemActions.Update.ToString(),
                                DgvName = dgv.Name
                            };

                            row["ItemObject"] = updatedItem;
                        }
                    }
                }

                // Controleer op geldige rij en status.
                if (e.RowIndex < dataTable.Rows.Count)
                {
                    DataRow row = dataTable.Rows[e.RowIndex];
                    if (row.RowState == DataRowState.Deleted || row.RowState == DataRowState.Detached)
                    {
                        return; // Rij verwijderd of losgekoppeld.
                    }

                    if (!row.Table.Columns.Contains("ItemObject"))
                    {
                        throw new InvalidOperationException("Kolom 'ItemObject' bestaat niet in de DataTable.");
                    }

                    // Verwerk 'ItemObject'.
                    if (row["ItemObject"] == DBNull.Value)
                    {
                        row["ItemObject"] = new DmItem
                        {
                            Guid = Guid.NewGuid().ToString(),
                            Level = DocumateUtils.ExtractDigets(dgv.Name),
                            Name = row["NAME"]?.ToString() ?? string.Empty,
                            Action = ItemActions.Create.ToString(),
                            DgvName = dgv.Name
                        };
                    }
                    else
                    {
                        row["ItemObject"] = ""; // Leegmaken voor update.
                        row["ItemObject"] = new DmItem
                        {
                            Guid = Guid.NewGuid().ToString(),
                            Level = DocumateUtils.ExtractDigets(dgv.Name),
                            Name = row["NAME"]?.ToString() ?? string.Empty,
                            Action = ItemActions.Update.ToString(),
                            DgvName = dgv.Name
                        };
                    }
                }
            }
        }

        public void CellClicked(object sender, DataGridViewCellEventArgs e)
        {
            // Niet meer nodig. is vervangen met: CurrentCellChanged.
            // Nog handhaven waarschijnlijk nodig bij de parent/childs controle.

            /*DataGridView? dgv = sender as DataGridView;

            if (e.RowIndex >= 0 && e.RowIndex < dgv?.Rows.Count)
            {
                // Get the selected row.
                DataGridViewRow row = dgv.Rows[e.RowIndex];

                // Get the ItemData object from the hidden column.
                if (row.DataBoundItem is DataRowView rowView)
                {
                    if (rowView["ItemObject"] is DmItem itemData)  
                    {
                        // Get the object data.
                        string itemName = itemData.Name;
                        string guid = itemData.Guid;
                        int tableId = itemData.RowId;
                        string action = itemData.Action;

                        // Show data.
                        //MessageBox.Show($"ItemName: {itemName} \nGuid: {guid}\nTableID: {tableId} \nAction: {action}");

                        string message = $"ItemName: {itemData.Name}\n Guid: {itemData.Guid}\n TableID: {itemData.RowId}\n Action: {itemData.Action}";

                        if (CellClickedEvent != null)
                        {
                            CellClickedEvent?.Invoke(message); // Call the event.
                        }                        
                    }
                }
            }*/
        }

        public void CurrentCellChanged(object sender, EventArgs e)
        {
            DataGridView? dgv = sender as DataGridView;

            if (dgv?.CurrentCell != null)
            {
                // Get the selected row.
                DataGridViewRow row = dgv.Rows[dgv.CurrentCell.RowIndex];

                if (row.DataBoundItem is DataRowView rowView)
                {
                    if (rowView["ItemObject"] is DmItem itemData)  // TODO Enum voor maken.
                    {
                        // Get the object data.
                        string itemName = itemData.Name;
                        string guid = itemData.Guid;
                        int tableId = itemData.RowId;
                        string action = itemData.Action;

                        // Show data.
                        string message = $"ItemName: {itemData.Name} --> \nGuid: {itemData.Guid} --> \nTableID: {itemData.RowId} --> \nAction: {itemData.Action}";

                        if (CellClickedEvent != null)  // TODO rename CellClickedEvent naar iets beters. Het werkt nu ook als je met TAB of de pijltjes toetsen door de gridview gaat.
                        {
                            CellClickedEvent.Invoke(message);
                        }
                    }
                }
            }
        }

        public void RowValidating(object sender, DataGridViewCellCancelEventArgs e)
        {
            bool canSave = false;
            if (sender is DataGridView dgv)
            {
                if (dgv.IsCurrentRowDirty)
                {
                    if (dgv.DataSource is BindingSource bindingSource)
                    {
                        bindingSource.EndEdit();  // Editing of the data table must be completed before RowValidating can be performed on a new line. = bring datagridview and datatable into sync.
                        
                        // Retrieve the DataTable from the BindingSource.
                        if (bindingSource.DataSource is DataTable dataTable)
                        {
                            // Work with the DataTable (for example validating or adjusting the data).
                            DataRow currentRow = dataTable.Rows[e.RowIndex];


                            if (currentRow.RowState != DataRowState.Deleted)
                            {
                                // Check whether a column is filled in.
                                if (!string.IsNullOrEmpty(currentRow[4]?.ToString()))  // [4] = item Name.
                                {
                                    if (_duplicateDataGridViewCells.Count <= 0 && _duplicateDataGridViewCells != null)
                                    {
                                        canSave = true;
                                    }

                                    // Finish the input and validate.
                                    bindingSource.EndEdit();

                                    if (CanSaveChangedEvent != null)
                                    {
                                        CanSaveChangedEvent?.Invoke(canSave); // Enable/disbale Save button in the mainview.
                                    }
                                }
                                else
                                {
                                    if (CanSaveChangedEvent != null)
                                    {
                                        CanSaveChangedEvent?.Invoke(canSave);
                                    }

                                    MessageBox.Show("Kolom2 moet worden ingevuld.");
                                }
                            }
                            // Add any custom logic for your custom object...
                        }
                    }
                }
            }
        }

        public void KeyDown(object sender, KeyEventArgs e)
        {
            if (CanProcessKey)
            {
                if (sender is DataGridView dgv)
                {
                    switch (e.KeyCode)
                    {
                        case Keys.Delete:
                            HandleDelete(dgv);
                            break;

                        case Keys.I when e.Control:
                            HandleInsert(dgv);  // Voeg bij de actieve datagridview een nieuwe rij toe aan het eind.
                            break;

                        case Keys.Enter:
                            // Controleer of de gebruiker in de laatste cel zit
                            if (dgv.CurrentCell != null &&
                                dgv.CurrentCell.RowIndex == dgv.RowCount - 1 &&
                                dgv.CurrentCell.ColumnIndex == dgv.ColumnCount - 2)
                            {
                                bool canSave = false;
                                // Controleer of de laatste cel inhoud heeft
                                var cellValue = dgv.CurrentCell.Value?.ToString();
                                if (!string.IsNullOrWhiteSpace(cellValue))
                                {
                                    // Voeg een nieuwe rij toe
                                    if (dgv.DataSource is BindingSource bindingSource &&
                                        bindingSource.DataSource is DataTable dataTable)
                                    {
                                        DataRow newRow = dataTable.NewRow();
                                        dataTable.Rows.Add(newRow);
                                        bindingSource.EndEdit();
                                        canSave = true;
                                    }
                                    else
                                    {
                                        dgv.Rows.Add(); // Voeg lege rij toe als er geen DataSource is.Komt hier nooit.
                                        canSave = true;
                                    }

                                    if (CanSaveChangedEvent != null)
                                    {
                                        CanSaveChangedEvent?.Invoke(canSave);
                                    }

                                    e.Handled = true; // Voorkom standaard verwerking van ENTER
                                }
                                else
                                {
                                    // Informeer de gebruiker optioneel over de vereiste inhoud
                                    MessageBox.Show("Vul de laatste cel in voordat een nieuwe rij wordt toegevoegd.",
                                        "Lege cel", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                                }
                            }
                            break;

                        default:
                            break;
                    }
                }
            }
        }


        private void HandleDelete(object sender)
        {
            if (sender is DataGridView dgv)
            {
                // Controleer of er een actieve cel is
                if (dgv.CurrentCell != null)
                {
                    bool canSave = false;

                    // Haal de huidige rij op
                    var currentRow = dgv.CurrentCell.OwningRow;

                    // Controleer of de rij geldig is (niet de nieuwe rij)
                    if (currentRow.IsNewRow) return;

                    // Verkrijg de DataTable en de bijbehorende DataRow via de juiste index
                    if (dgv.DataSource is BindingSource bindingSource && bindingSource.DataSource is DataTable dataTable)
                    {
                        // Vind de gegevensindex van de geselecteerde rij in de DataGridView
                        int dataIndex = bindingSource.Position;

                        if (dataIndex >= 0 && dataIndex < dataTable.Rows.Count)
                        {
                            DataRow dataRow = dataTable.Rows[dataIndex];

                            // de te verwijderen row eerst in een delete lijst zetten. Nodig om te kunnen opslaan want na dataTable.AcceptChanges() zijn de wijzigingen in de datatable doorgevoerd en niet meer beschikbaar tijdens het opslaan.
                            DmItem dmItem = new()
                            {
                                Guid = dataRow[0].ToString(),
                                Level = int.Parse(dataRow[1].ToString()),
                                Name = dataRow[4].ToString()
                            };
                            _dmItems.AddItem(dmItem);

                            // Verwijder de rij uit de DataTable.
                            dataRow.Delete();

                      //      de data moet eerst in een tijdelijke databale worden gezet. zodat bij het opslaan de rijen pas echt worden verwijderd.

                            // Pas wijzigingen toe en verwijder rijen in "Deleted" state
                            dataTable.AcceptChanges();

                            // Synchroniseer de wijzigingen.
                            bindingSource.ResetBindings(false); // Forceer een update van de binding.
                            canSave = true;
                        }
                    }
                    else
                    {
                        // Verwijder de rij direct uit de DataGridView als er geen DataSource is
                        dgv.Rows.Remove(currentRow);
                        canSave = true;
                    }

                    // Update de "Opslaan"-status
                    if (CanSaveChangedEvent != null)
                    {
                        CanSaveChangedEvent?.Invoke(canSave);
                    }
                }
            }
        }

        private void HandleInsert(object sender)
        {
            if (sender is DataGridView dgv)
            {
                if (dgv.DataSource is BindingSource bindingSource && bindingSource.DataSource is DataTable dataTable)
                {
                    // Controleer of er al een lege rij bestaat
                    foreach (DataRow row in dataTable.Rows)
                    {
                        if (row.RowState != DataRowState.Deleted && row.ItemArray.All(field => field == DBNull.Value || string.IsNullOrWhiteSpace(field?.ToString())))
                        {
                            MessageBox.Show("Er bestaat al een lege rij. Vul deze eerst in voordat een nieuwe wordt toegevoegd.",
                                "Lege rij", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                            return;
                        }
                    }

                    bool canSave = false;
                    DataRow newRow = dataTable.NewRow();

                    // Voeg een nieuwe rij toe op de actieve locatie of aan het einde
                    /*
                    int insertIndex = dgv.CurrentRow?.Index ?? dataTable.Rows.Count;
                    if (insertIndex >= dataTable.Rows.Count)
                    {
                        dataTable.Rows.Add(newRow);
                    }
                    else
                    {
                        dataTable.Rows.InsertAt(newRow, insertIndex);
                    }*/

                    // de rij altijd aan het eind toeveogen
                    dataTable.Rows.Add(newRow);

                    bindingSource.EndEdit();
                    canSave = true;

                    if (CanSaveChangedEvent != null)
                    {
                        CanSaveChangedEvent?.Invoke(canSave);
                    }
                }
            }
        }
        private void HighlightDuplicateValues(DataGridView dgv, int columnIndex)
        {
            if (columnIndex == 2)  // 2 = NAME
            {
                //var duplicateCells = new List<DataGridViewCell>();
                _duplicateDataGridViewCells = new List<DataGridViewCell>();
                var cellValues = new Dictionary<string, DataGridViewCell>();

                foreach (DataGridViewRow row in dgv.Rows)
                {
                    if (row.IsNewRow) continue;

                    var cell = row.Cells[columnIndex];
                    var cellValue = cell.Value?.ToString() ?? "";

                    if (cellValues.TryGetValue(cellValue, out DataGridViewCell? value))
                    {
                        // Add the current cell and the original duplicate cell to the list.
                        _duplicateDataGridViewCells.Add(cell);
                        _duplicateDataGridViewCells.Add(value);
                    }
                    else
                    {
                        cellValues[cellValue] = cell;
                    }
                }

                // Reset cells to default color.
                foreach (DataGridViewRow row in dgv.Rows)
                {
                    if (row.IsNewRow) continue;

                    var cell = row.Cells[columnIndex];
                    cell.Style.BackColor = Color.White;
                }

                // Color double cells red.
                foreach (var cell in _duplicateDataGridViewCells)
                {
                    cell.Style.BackColor = Color.Red;
                }

                if (_duplicateDataGridViewCells.Count > 0)
                {
                    CanSaveChangedEvent?.Invoke(false);
                }
                else
                {
                    CanSaveChangedEvent?.Invoke(true);
                }
            }
        }

        private static DataTable? GetDataTableFromDataGridView(DataGridView dgv)
        {
            if (dgv.DataSource is BindingSource bindingSource && bindingSource.DataSource is DataTable dataTable)
            {
                return dataTable;
            }
            return null;
        }
    }
}

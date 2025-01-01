using Documate.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Documate.Models
{
    public interface IDataGridViewModel
    {
        void HandleCellValueChanged(object sender, DataGridViewCellEventArgs e);
        void HandleRowsAdded(object sender, DataGridViewRowsAddedEventArgs e);
        void RowLeave(object sender, DataGridViewCellEventArgs e);
        void CellClicked(object sender, DataGridViewCellEventArgs e);
        void CurrentCellChanged(object sender, EventArgs e);
        void RowValidating(object sender, DataGridViewCellCancelEventArgs e);
        event Action<string> CellClickedEvent;  // for object data that goes to a textbox in the main view for checking.
        event Action<bool> CanSaveChangedEvent;
        void KeyDown(object sender, KeyEventArgs e);  // TODO: kan weg, wordt niet gebruikt.

        bool CanProcessKey { get; set; }

    }
}

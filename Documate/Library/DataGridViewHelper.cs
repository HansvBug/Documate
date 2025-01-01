using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Documate.Library
{
    public static class DataGridViewHelper
    {
        private static readonly List<Control> _allDgvs = [];
        public static IReadOnlyList<Control> AllDgvs => _allDgvs;

        public static void AddDgv(Control dgv)
        {
            if (dgv != null)
            {
                _allDgvs.Add(dgv);
            }
        }

        public static void ClearDgv()
        {
            foreach (DataGridView dgv in _allDgvs)
            {
                if (dgv.DataSource is BindingSource bindingSource && bindingSource.DataSource is DataTable dataTable)
                {
                    dataTable.Clear();
                    bindingSource.DataSource = null;
                    //dgv.DataBindings.Clear();
                }
            }

            _allDgvs.Clear();
        }
    }
}

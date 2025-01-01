using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Documate.Library
{
    public class DmItem
    {
        public enum ItemActions
        {
            Create,
            Read,
            Update,
            Delete
        }
        public string Guid { get; set; }
        public int RowId { get; set; }
        public int Level { get; set; }
        public string Name { get; set; }
        public string ParentGuid { get; set; }
        public string Action { get; set; }
        public string DgvName { get; set; }
    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Documate.Models
{
    public interface ICreateControls
    {
        bool ComponentsCreated { get; set; }
        void CreateComponents(string DatabaseFileName, Panel APanel);
        void RemoveComponents(Panel APanel);
    }
}

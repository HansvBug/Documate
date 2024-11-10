using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Documate.Presenters
{
    public interface IMainPresenter
    {
        /// <summary>
        /// Start the program.
        /// </summary>
        void Run();
        void OnFormShown();

        string GetStaticText(string section, string textKey);
    }
}

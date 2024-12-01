using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Documate.Models
{
    public interface IFormPosition
    {
        void RestoreWindowPosition(Form form, string settingsKeyPrefix);  //, Action setDefaultPosition
        void StoreWindowPosition(Form form, string settingsKeyPrefix);
        void SystemEvents_DisplaySettingsChanged(Form form, string settingsKeyPrefix); //, Action setDefaultPosition
    }
}

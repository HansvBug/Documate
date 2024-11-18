using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static Documate.Models.DirectoryModel;

namespace Documate.Models
{
    public interface IDirectoryModel
    {
        void CreateDirectory(DirectoryOption option, string dirName);
    }
}

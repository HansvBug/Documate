using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Documate.Library
{
    public static class DocumateUtils
    {
        private static string? _fileLocationAndName;
        private static string? _fileName;
        private static bool _loggingIsStarted;
        private static int _colCount;
        public static string FileLocationAndName
        {
            get => _fileLocationAndName;
            set
            {
                _fileLocationAndName = value;
                _fileName = Path.GetFileName(value);
            }
        }

        public static string FileName
        {
            get => _fileName;
        }

        public static bool LoggingIsStarded
        {
            get => _loggingIsStarted;
            set => _loggingIsStarted = value;
        }

        public static int ColCount
        {
            get => _colCount;
            set => _colCount = value;
        }

        private static List<Control> _allDgvs = new();
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
            _allDgvs.Clear();
        }

    }
}

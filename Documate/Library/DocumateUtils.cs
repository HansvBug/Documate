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
        private static int _levelCount;
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

        public static int LevelCount
        {
            get => _levelCount;
            set => _levelCount = value;
        }

        public static int ExtractDigets(string input)
        {
            string output = string.Empty;
            for (int i = 0; i < input.Length; i++)
            {
                if (Char.IsDigit(input[i]))
                    output += input[i];
            }
            return int.Parse(output);
        }
    }
}

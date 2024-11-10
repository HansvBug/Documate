using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Documate.Models
{
    public class LocalizationManagerModel
    {
        // Support for 2 languages.
        public enum LanguageOption
        {
            EN,
            NL
        }

        // Different message types. This is used to determine the title of a message box.
        public enum MessageType
        {
            Information,
            Warning,
            Error,
            None
        }

        //Property to store the loaded INI data.
        public Dictionary<string, Dictionary<string, string>>? LoadedIniData { get; private set; }

        /// <summary>
        /// OnIniDataLoaded is an event that is called when the INI data is loaded. 
        /// It uses an Action delegate that passes a nested dictionary.
        /// This means that when the event is invoked, the data is passed to all subscribers.
        /// </summary>
        public event Action<Dictionary<string, Dictionary<string, string>>>? OnIniDataLoaded;

        public async Task LoadIniFileAsync(string filePath, LanguageOption option)
        {
            filePath = option switch
            {
                LanguageOption.EN => Path.Combine(filePath, "Component.EN"),
                LanguageOption.NL => Path.Combine(filePath, "Component.NL"),
                _ => Path.Combine(filePath, "Component.EN"),
            };


            if (!File.Exists(filePath))
            {
                throw new FileNotFoundException("INI-bestand niet gevonden.", filePath);
            }

            // When the data is loaded, fire the event.
            LoadedIniData = await Task.Run(() => ParseIniFile(filePath));

            // Call event after loading. This adjusts the menu texts.
            OnIniDataLoaded?.Invoke(LoadedIniData);
        }

        // Parsing the INI file.
        private static Dictionary<string, Dictionary<string, string>> ParseIniFile(string filePath)
        {
            var result = new Dictionary<string, Dictionary<string, string>>();
            Dictionary<string, string>? currentSection = null;

            foreach (var line in File.ReadAllLines(filePath))
            {
                string trimmedLine = line.Trim();

                if (string.IsNullOrEmpty(trimmedLine) || trimmedLine.StartsWith(";"))
                    continue;

                if (trimmedLine.StartsWith("[") && trimmedLine.EndsWith("]"))
                {
                    string sectionName = trimmedLine.Trim('[', ']');
                    currentSection = [];
                    result[sectionName] = currentSection;
                }
                else if (currentSection != null)
                {
                    var keyValue = trimmedLine.Split('=');
                    if (keyValue.Length == 2)
                    {
                        // string key = keyValue[0].Trim();
                        // string value = keyValue[1].Trim();
                        // currentSection[key] = value;
                        // replaced by:
                        currentSection[keyValue[0].Trim()] = keyValue[1].Trim();
                    }
                }
            }

            return result;
        }

        public string GetStaticText(string section, string textKey)
        {
            if (LoadedIniData != null)
            {
                if (LoadedIniData.TryGetValue(section, out Dictionary<string, string>? value))
                {
                    foreach (var entry in value)
                    {
                        if (entry.Key == textKey)
                        {
                            return entry.Value;
                        }
                    }
                    return string.Empty;
                }
                else { return string.Empty; }
            }
            else { return string.Empty; }
        }
    }
}

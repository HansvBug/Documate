using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Documate.Library
{
    public class AppMessage
    {
        // Different message types. This is used to determine the title of a message box.
        public enum MessageType
        {
            Information,
            Warning,
            Error,
            None
        }

        public List<AppMessage> Messages { get; private set; }
        public string MsgText { get; set; } = string.Empty;
        public MessageType MsgType { get; set; }

        public AppMessage()
        {
            Messages = [];  // Messages = new List<AppMessage>();
        }
        public void AddMessage(MessageType type, string text)
        {
            Messages.Add(new AppMessage
            {
                MsgType = type,
                MsgText = text
            });
        }
    }
}

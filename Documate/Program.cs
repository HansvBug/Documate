using Documate.Library;

namespace Documate
{
    internal static class Program
    {
        /// <summary>
        ///  The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            // To customize application configuration such as set high DPI settings or default font,
            // see https://aka.ms/applicationconfiguration.
            //ApplicationConfiguration.Initialize();
            //Application.Run(new MainForm());


            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            // Configure dependency injection
            _ = new Startup();
            var serviceProvider = Startup.ConfigureServices();

            // Run the application
            Startup.Run(serviceProvider);
        }
    }
}
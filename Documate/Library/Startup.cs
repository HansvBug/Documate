﻿using Documate.Models;
using Documate.Presenters;
using Documate.Views;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Globalization;

namespace Documate.Library
{
    public class Startup
    {
        /// <summary>
        /// The method ConfigureServices initializes a new ServiceCollection.
        /// Singleton   : Only a single instance of the service is created and shared across the entire application lifetime.
        /// Transient   : A new instance is created each time the service is requested.
        /// Scoped      : An instance is created once per request(typically used in web applications).
        /// </summary>
        /// <returns>ServiceProvider</returns>
        public static ServiceProvider ConfigureServices() // (D)ependency (I)njection
        {
            InitializeLocalization();  // Initializes the language settings.

            return new ServiceCollection()
            .AddSingleton<IMainView, MainForm>()           // Registers MainForm as the implementation for the IMainView interface. This means that whenever IMainView is requested, the application will provide a single, shared instance of MainForm
            .AddSingleton<MainPresenter>()                 // Registers MainPresenter so that a new instance is created every time it’s requested. No specific interface is associated, so it’s registered by its concrete type.
            .AddSingleton<IAppSettings, AppSettings>()     // Register only the interface. If you also register the class, you will still get multiple instances of the object.
            .AddSingleton<DirectoryModel>()
            .AddSingleton<LoggingModel>()
            .AddSingleton<IConfigureView, ConfigureForm>() // Register as Singleton                
            .AddSingleton<ConfigurePresenter>()  
            .AddTransient<FormPositionModel>()             // Register as Transient (Singletons would be ok too)
            .AddSingleton<INewDbView, NewDbForm>()
            .AddSingleton<NewDbPresenter>()
            .AddSingleton<IAppDbCreateModel, AppDbCreateModel>()  
            .AddSingleton<IAppDbMaintainModel, AppDbMaintainModel>()
            .AddSingleton<ICreateControls, CreateControls>()
            .AddSingleton<IAppDbMaintainItemsModel, AppDbMaintainItemsModel>()
            .AddSingleton<IDataGridViewModel, DataGridViewModel>()
            .AddSingleton<IDmItems, DmItems>()

            .BuildServiceProvider();
        }

        public static void Run(ServiceProvider serviceProvider)
        {
            // Get the presenter from the service provider.
            var presenter = serviceProvider.GetService<MainPresenter>();

            // Get the MainForm from the service provider and link the presenter with the view.
            if (serviceProvider.GetService<IMainView>() is MainForm form && presenter != null)
            {
                form.SetPresenter(presenter);

                // Initialize the StatusbarHelper = static class
                StatusStripHelper.Initialize(form);

                // Start the application
                presenter?.Run();
            }
            else if (presenter == null)
            {
                throw new InvalidOperationException("MainPresenter not registered.");
            }
        }

        public static void InitializeLocalization()
        {
            // Laad de taal uit de instellingen of gebruik een standaardwaarde
            string language = Properties.Settings.Default.Language ?? "en-EN";
            CultureInfo culture = new(language);

            // Stel de cultuur in voor de huidige thread
            Thread.CurrentThread.CurrentCulture = culture;
            Thread.CurrentThread.CurrentUICulture = culture;

            // Optioneel: Log de gekozen cultuur voor debugging
            Console.WriteLine($"Language set to: {culture.Name}");

            LocalizationHelper.SetCulture(language);
        }
    }
}
